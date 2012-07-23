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

- (BOOL) oplogContainsEntry:(NSString *) entry {
  BOOL found = NO;
  for(OplogEntry *oplogEntry in self.manager.oplog) {
    found = [oplogEntry.identifier isEqualToString:entry];
    if(found) {
      break;
    }
  }
  return found;
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  Packet *readPacket = [Packet packetFromData:data];
  
  if(!readPacket) {
    NSLog(@"data damaged");
    [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
    return;
  }
  
  if([readPacket.packetId isEqualToString:kClientPacket]) {
    NSLog(@"replica: received client SHOULDNOT, every client packet are forwarded to master");
  }
  else if ([readPacket.packetId isEqualToString:kOplogPacket]) {
    NSLog(@"replica get oplog change from master");
    //Compare own oplog with master's
    NSArray *masterOplog = readPacket.packetContent;
    for(OplogEntry *oplogEntry in masterOplog) {
      NSLog(@"packet id = %@", oplogEntry.packet.packetId);
      if(![self oplogContainsEntry:oplogEntry.identifier]) {
        [self.manager.oplog addObject:oplogEntry];
        [self.manager didReadPacket:oplogEntry.packet];
      }
    }
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
