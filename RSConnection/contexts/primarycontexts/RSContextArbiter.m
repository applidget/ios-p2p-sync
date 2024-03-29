//
//  NodeContextArbiter.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSContextArbiter.h"
#import "RSContextElector.h"
#import "RSContextReplica.h"
#import "RSContextMaster.h"

#define MAX_TIME_TO_ACTIVE 1.5

@interface RSContextArbiter()

///Arbiter will receive electors priorities and stock it into an array
@property (nonatomic, retain) NSMutableArray *receivedPriorities;   
///If the arbiter can't be launched within a certain interval, it means that one already exists
@property (nonatomic, assign) BOOL tookTooLongToLaunchService;      
///Arbiter's own priority
@property (nonatomic, assign) NSInteger priorityForElection;        

/** Method called when the election time is elapsed */
- (void) announceNewMaster;

@end

@implementation RSContextArbiter

@synthesize receivedPriorities=_receivedPriorities, tookTooLongToLaunchService=_tookTooLongToLaunchService, priorityForElection=_priorityForElection;

- (void) didLaunchService {
  if(self.tookTooLongToLaunchService) {
    [self.manager changeContextWithNewContextType:kContextTypeElector];
  }
}

- (void) activate {  
  [super activateWithServiceType:[NSString stringWithFormat:@"%@%@", self.manager.replicaSetName ,ARBITER_SERVICE] andName:@"arbiter"];
  
  self.tookTooLongToLaunchService = YES;
  [self performSelector:@selector(didLaunchService) withObject:nil afterDelay:MAX_TIME_TO_ACTIVE];
  [self.manager didUpdateStateInto:kConnectionStateFightingToBeArbiter];
}

- (void) announceNewMaster {
  
  [self.manager numberOfParticipantsForLastElection:self.receivedPriorities.count+1];
  
  NSInteger highestPrio = 0;
  for (NSString *prio in self.receivedPriorities) {
    NSInteger currentPrio = [prio intValue];
    if(currentPrio > highestPrio) {
      highestPrio = currentPrio;
    }
  }

  if(highestPrio > self.priorityForElection) {
    RSPacket *prioPacket = [RSPacket packetWithContent:[NSString stringWithFormat:@"%i", highestPrio]
                                             onChannel:kPriorityChannel
                                          emittingHost:self.socket.localHost];

    [self writeData:[prioPacket representingData]];
    [self.manager changeContextWithNewContextType:kContextTypeReplica];
  }
  else { //Arbiter has highest prio, becomes master
    RSPacket *prioPacket = [RSPacket packetWithContent:[NSString stringWithFormat:@"%i", self.priorityForElection]
                                             onChannel:kPriorityChannel
                                          emittingHost:self.socket.localHost];
    [self writeData:[prioPacket representingData]];
    [self.manager changeContextWithNewContextType:kContextTypeMaster];
  }
  [self.receivedPriorities removeAllObjects];
}

#pragma mark - NSNetServiceDelegate protocol
- (void) netServiceDidPublish:(NSNetService *)sender {
  
  if(self.delegateAlreadyAwareOfCurrentState) return;
  
  //Succeded to be arbiter, cancelling timer
  self.tookTooLongToLaunchService = NO;
  NSMutableArray *contextReceivedPriorities = [[NSMutableArray alloc] init];
  self.receivedPriorities = contextReceivedPriorities;
  [contextReceivedPriorities release];
  [self performSelector:@selector(announceNewMaster) withObject:nil afterDelay:ELECTION_TIME];
  [self.manager didUpdateStateInto:kConnectionStateArbiter];
  self.priorityForElection = [self.manager getPriorityOfElector];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
  if([[errorDict objectForKey:NSNetServicesErrorCode] intValue] == NSNetServicesCollisionError) {
    [self.manager changeContextWithNewContextType:kContextTypeElector];
  }
}

#pragma mark GCDAsyncSocketDelegate protocol
- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  RSPacket *receivedPacket = [RSPacket packetFromData:data];
  
  if([self.waitingConnections containsObject:sock] && ![receivedPacket.channel isEqualToString:kPasswordChannel]) {
    //Received a packet from a not yet authorized device
    NSLog(@"not allowed");
    return;
  }
  
  if([receivedPacket.channel isEqualToString:kPriorityChannel]) {
    NSString *strPriority = receivedPacket.content;
    [self.receivedPriorities addObject:strPriority];
    NSLog(@"received prio");
  }
  else if([receivedPacket.channel isEqualToString:kPasswordChannel]) {
    NSLog(@"received pass");
    if([receivedPacket.content isEqualToString:[self.manager requestPassword]]) {
      [self socketAnsweredPasswordSuccessfully:sock];
    }
    else {
      [sock disconnect];
      [self.waitingConnections removeObject:sock];
    }
  }
  else {
    [NSException raise:kUnknownPacketException format:@"Arbiter received a packet from an unknown channel %@", receivedPacket.channel];
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];

}

#pragma mark - memory management
- (void) dealloc {
  [self.receivedPriorities release];
  [super dealloc];
}

@end
