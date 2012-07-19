//
//  NodeContextReplica.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextReplica.h"
#import "NodeContextArbiter.h"

@implementation NodeContextReplica

- (void) activate {
  [super activateWithServiceType:[NSString stringWithFormat:@"%@%@", self.manager.sessionId ,MASTER_SERVICE]];
}

#pragma mark - NSNetServiceBrowserDelegate
- (void) netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser {
  [self.manager didChangetState:kNodeStateReplicaSearching];
}

#pragma mark - GCDAsyncSocketDelegate protocol
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port {
  [super socket:sender didConnectToHost:host port:port];
  [self.manager didChangetState:kNodeStateReplicaConnected];
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {  
  //Lost connection to master -> trying to launch arbiter context
  NSLog(@"disconnected !!");
  [self.manager changeToContextType:kContextTypeArbiter];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  Packet *readPacket = [Packet packetFromData:data];
  
  if(!readPacket) {
    NSLog(@"data damaged");
    [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
    return;
  }
  
  if([readPacket.packetId isEqualToString:kClientPacket]) {
    NSLog(@"replica: received client");
    [self.manager didReadClientPacket:readPacket];
  }
  else if([readPacket.packetId isEqualToString:kPriorityPacket]) {
    NSLog(@"replica: prio packet SHOULDNOT");
    
  }
  else if([readPacket.packetId isEqualToString:kHeartBeatPacket]) {
    NSLog(@"replica: received heartbeat");
    self.manager.sessionMap = readPacket.packetContent;
  }
  else {
    NSLog(@"replica: unknown packet");
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}



@end
