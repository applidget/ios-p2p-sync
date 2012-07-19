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

#define ELECTOR_TIMEOUT 20

@implementation NodeContextElector

- (void) electorContextTimedOut {
  //Manage the case where the network was shut down for a sec but the master didn't crash
  [self.manager changeToContextType:kContextTypeReplica];
}

- (void) activate {
  [super activateWithServiceType:[NSString stringWithFormat:@"%@%@", self.manager.sessionId, ARBITER_SERVICE]];
  electionResult = kElectionResultUnknown;
  timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:ELECTOR_TIMEOUT target:self selector:@selector(electorContextTimedOut) userInfo:nil repeats:NO];
}

#pragma mark - NSNetServiceBrowserDelegate
- (void) netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser {
  [self.manager didChangetState:kNodeStateElectorSearching];
}

#pragma mark - GCDAsyncSocketDelegate protocol
- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  //No more connected arbiter shut down
  kContextType newContextType;
  switch (electionResult) {
    case kElectionResultWon:
      newContextType = kContextTypeMaster;
      break;
    case kElectionResultLost:
      newContextType = kContextTypeReplica;
      break;
    case kElectionResultUnknown:
      newContextType = kContextTypeArbiter; //disconnected without result, arbiter crashed, need a new election
      break;
    default:
      break;
  }
  [self.manager changeToContextType:newContextType];
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
  [super socket:sock didConnectToHost:host port:port];
  [timeOutTimer invalidate];
  [self.manager didChangetState:kNodeStateElectorConnected];
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
    if (priority == self.manager.priority) {
      electionResult = kElectionResultWon;
    }
    else {
      electionResult = kElectionResultLost;
    }
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
