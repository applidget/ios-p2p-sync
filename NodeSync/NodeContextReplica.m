//
//  NodeContextReplica.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextReplica.h"
#import "NodeContextArbiter.h"
#import "OplogEntry.h"

@implementation NodeContextReplica

- (void) activate {
  [super activateWithServiceType:[NSString stringWithFormat:@"%@%@", self.manager.sessionId ,MASTER_SERVICE]];
  NSLog(@"activated replica");
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
  self.socket.delegate = nil;
  [self.manager changeToContextType:kContextTypeArbiter];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  Packet *readPacket = [Packet packetFromData:data];
  
  if(!readPacket) {
    NSLog(@"data damaged");
    [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
    return;
  }
  
  if([readPacket.identifier isEqualToString:kClientPacket]) {
    NSLog(@"replica: received client SHOULDNOT, every client packet are forwarded to master");
  }
  else if ([readPacket.identifier isEqualToString:kOplogPacket]) {
    NSLog(@"replica get oplog change from master");
    //Compare own oplog with master's
    NSArray *masterOplog = readPacket.content;
    for(OplogEntry *oplogEntry in masterOplog) {
      NSLog(@"packet id = %@", oplogEntry.packet.identifier);
      if(![self.manager oplogContainsEntry:oplogEntry.identifier]) {
        [self.manager.oplog addObject:oplogEntry];
        [self.manager didAddOplogEntry:oplogEntry];
      }
    }
  }
  
  else if([readPacket.identifier isEqualToString:kPriorityPacket]) {
    NSLog(@"replica: prio packet SHOULDNOT");
    
  }
  else if([readPacket.identifier isEqualToString:kHeartBeatPacket]) {
    NSLog(@"replica: received heartbeat");
    self.manager.sessionMap = readPacket.content;
  }
  else {
    NSLog(@"replica: unknown packet");
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}



@end
