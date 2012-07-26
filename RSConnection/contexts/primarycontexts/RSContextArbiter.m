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

@property (nonatomic, retain) NSMutableArray *receivedPriorities;
@property (nonatomic, assign) BOOL tookTooLongToLaunchService;

- (void) announceNewMaster;

@end

@implementation RSContextArbiter

@synthesize receivedPriorities, tookTooLongToLaunchService;

- (void) didLaunchService {
  if(self.tookTooLongToLaunchService) {
    [self.manager changeContextWithNewContextType:kContextTypeElector];
  }
}

- (void) activate {  
  [super activateWithServiceType:[NSString stringWithFormat:@"%@%@", self.manager.replicaSetName ,ARBITER_SERVICE] andName:@"arbiter"];
  
  tookTooLongToLaunchService = YES;
  [self performSelector:@selector(didLaunchService) withObject:nil afterDelay:MAX_TIME_TO_ACTIVE];
  [self.manager didUpdateStateInto:kConnectionStateFightingToBeArbiter];
}

- (void) announceNewMaster {
  
  [self.manager numberOfElectorsForLastElection:self.receivedPriorities.count];
  
  NSInteger highestPrio = 0;
  for (NSString *prio in self.receivedPriorities) {
    NSInteger currentPrio = [prio intValue];
    if(currentPrio > highestPrio) {
      highestPrio = currentPrio;
    }
  }

  if(highestPrio > priorityForElection) {
    RSPacket *prioPacket = [RSPacket packetWithContent:[NSString stringWithFormat:@"%i", highestPrio]
                                             onChannel:kPriorityPacket
                                          emittingHost:self.socket.localHost];

    [self writeData:[prioPacket representingData]];
    [self.manager changeContextWithNewContextType:kContextTypeReplica];
  }
  else { //Arbiter has highest prio, becomes master
    RSPacket *prioPacket = [RSPacket packetWithContent:[NSString stringWithFormat:@"%i", priorityForElection]
                                             onChannel:kPriorityPacket
                                          emittingHost:self.socket.localHost];
    [self writeData:[prioPacket representingData]];
    [self.manager changeContextWithNewContextType:kContextTypeMaster];
  }
  [self.receivedPriorities removeAllObjects];
}

#pragma mark - NSNetServiceDelegate protocol
- (void) netServiceDidPublish:(NSNetService *)sender {
  //Succeded to be arbiter, cancelling timer
  tookTooLongToLaunchService = NO;
  NSMutableArray *contextReceivedPriorities = [[NSMutableArray alloc] init];
  self.receivedPriorities = contextReceivedPriorities;
  [contextReceivedPriorities release];
  [self performSelector:@selector(announceNewMaster) withObject:nil afterDelay:ELECTION_TIME];
  [self.manager didUpdateStateInto:kConnectionStateArbiter];
  priorityForElection = [self.manager getPriorityOfElector];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
  //an other arbiter service is already launched
  [self.manager changeContextWithNewContextType:kContextTypeElector];
}

#pragma mark GCDAsyncSocketDelegate protocol
- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  RSPacket *receivedPacket = [RSPacket packetFromData:data];
  
  if([receivedPacket.channel isEqualToString:kPriorityPacket]) {
    NSString *strPriority = receivedPacket.content;
    [self.receivedPriorities addObject:strPriority];
  }
  else {
    [NSException raise:kUnknownPacketException format:@"Arbiter received a packet from an unknown channel %@", receivedPacket.channel];
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}

#pragma mark - memory management
- (void) dealloc {
  [receivedPriorities release];
  [super dealloc];
}

@end
