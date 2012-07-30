//
//  NodeContextReplica.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSContextReplica.h"
#import "RSContextArbiter.h"

@implementation RSContextReplica

- (void) activate {
  [super activateWithServiceType:[NSString stringWithFormat:@"%@%@", self.manager.replicaSetName, MASTER_SERVICE]];
}

#pragma mark - NSNetServiceBrowserDelegate
- (void) netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser {
  [self.manager didUpdateStateInto:kConnectionStateReplicaSearching];
}

#pragma mark - GCDAsyncSocketDelegate protocol
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port {
  [super socket:sender didConnectToHost:host port:port];
  if(self.manager.usePasswordForConnection) {
    [self.manager didUpdateStateInto:kConnectionStateReplicaConnected];
  }
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {  
  [self.socket setDelegate:nil delegateQueue:NULL];
  self.manager.nbConnections --;
  [self.manager changeContextWithNewContextType:kContextTypeArbiter];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  RSPacket *receivedPacket = [RSPacket packetFromData:data];
  
  if([receivedPacket.channel isEqualToString:kClientChannel]) {
    [self.manager didReceivePacket:receivedPacket];
  }
  else if([receivedPacket.channel isEqualToString:kPasswordChannel]) {
    //check success
    if([receivedPacket.content isEqualToString:kPasswordSuccess]) {
      [self.manager didUpdateStateInto:kConnectionStateReplicaConnected];
    }
  }
  else {
    [NSException raise:kUnknownPacketException format:@"Replica received a packet from an unknown channel %@", receivedPacket.channel];
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}



@end
