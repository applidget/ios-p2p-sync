//
//  NodeContextElector.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextElector.h"
#import "NodeContextReplica.h"
#import "NodeContextMaster.h"

@implementation NodeContextElector

- (void) activate {
  [super activateWithServiceType:ARBITER_SERVICE];
  hasWonTheElection = NO;
}

#pragma mark - GCDAsyncSocketDelegate protocol
- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  //No more connected arbiter shut down
  kContextType newContext = hasWonTheElection ? kContextTypeMaster : kContextTypeReplica;
  [self.manager changeToContextType:newContext];
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
  [super socket:sock didConnectToHost:host port:port];
  Packet *prioPacket = [Packet packetWithId:kPriorityPacket andContent:[NSString stringWithFormat:@"%i", self.manager.priority]];
  [self pushData:[prioPacket convertToData] withTimeout:DEFAULT_TIMEOUT];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  Packet *readPacket = [Packet packetFromData:data];
  
  if(!readPacket) {
    NSLog(@"data damaged");
    [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
    return;
  }
  
  if([readPacket.packetId isEqualToString:kClientPacket]) {
    NSLog(@"elector: received client SHOULDNOT");
    
  }
  else if([readPacket.packetId isEqualToString:kPriorityPacket]) {
    NSLog(@"elector: prio packet");
    NSString *strPriority = readPacket.packetContent;
    NSInteger priority = [strPriority intValue];
    hasWonTheElection = (priority == self.manager.priority);
  }
  else if([readPacket.packetId isEqualToString:kHeartBeatPacket]) {
    NSLog(@"elector: received heartbeat SHOULDNOT");
    
  }
  else {
    NSLog(@"elector: unknown packet");
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}

@end
