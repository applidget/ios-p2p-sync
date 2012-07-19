//
//  NodeContextArbiter.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextArbiter.h"
#import "NodeContextElector.h"
#import "NodeContextReplica.h"
#import "NodeContextMaster.h"

#define MAX_TIME_TO_ACTIVE 1.5

@implementation NodeContextArbiter

@synthesize receivedPriorities;

- (void) didLaunchService {
  if(tookTooLongToLaunchService) {
    [self.manager changeToContextType:kContextTypeElector];
  }
}

- (void) activate {  
  [super activateWithServiceType:ARBITER_SERVICE andName:@"arbiter"];
  
  tookTooLongToLaunchService = YES;
  [self performSelector:@selector(didLaunchService) withObject:nil afterDelay:MAX_TIME_TO_ACTIVE];
}

- (void) announceNewMaster {
  NSInteger highestPrio = 0;
  for (NSString *prio in self.receivedPriorities) {
    NSInteger currentPrio = [prio intValue];
    if(currentPrio > highestPrio) {
      highestPrio = currentPrio;
    }
  }

  if(highestPrio > self.manager.priority) {
    Packet *prioPacket = [Packet packetWithId:kPriorityPacket andContent:[NSString stringWithFormat:@"%i", highestPrio]];
    [self pushData:[prioPacket convertToData] withTimeout:DEFAULT_TIMEOUT];
    [self.manager changeToContextType:kContextTypeReplica];
  }
  else { //Arbiter has highest prio, becomes master
    [self.manager changeToContextType:kContextTypeMaster];
  }
}

#pragma mark - NSNetServiceDelegate protocol
- (void) netServiceDidPublish:(NSNetService *)sender {
  //Succeded to be arbiter, cancelling timer
  tookTooLongToLaunchService = NO;
  NSMutableArray *_receivedPriorities = [[NSMutableArray alloc] init];
  self.receivedPriorities = _receivedPriorities;
  [_receivedPriorities release];
  [self performSelector:@selector(announceNewMaster) withObject:nil afterDelay:ELECTION_TIME];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
  //an other arbiter service is already launched
  [self.manager changeToContextType:kContextTypeElector];
}

#pragma mark GCDAsyncSocketDelegate protocol
- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  Packet *readPacket = [Packet packetFromData:data];
  
  if(!readPacket) {
    NSLog(@"data damaged");
    [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
    return;
  }
  
  if([readPacket.packetId isEqualToString:kClientPacket]) {
    NSLog(@"arbiter: received client SHOULDNOT");
    
  }
  else if([readPacket.packetId isEqualToString:kPriorityPacket]) {
    NSLog(@"arbiter: prio packet");
    
    NSString *strPriority = readPacket.packetContent;
    [self.receivedPriorities addObject:strPriority];
  }
  else if([readPacket.packetId isEqualToString:kHeartBeatPacket]) {
    NSLog(@"arbiter: received heartbeat SHOULDNOT");
    
  }
  else {
    NSLog(@"arbiter: unknown packet");
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  
}

#pragma mark - memory management
- (void) dealloc {
  [receivedPriorities release];
  [super dealloc];
}

@end
