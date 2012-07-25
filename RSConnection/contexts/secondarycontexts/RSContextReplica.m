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
  [self.manager didUpdateStateInto:kConnectionStateReplicaConnected];
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {  
  //Lost connection to master -> trying to launch arbiter context
  [self.socket setDelegate:nil delegateQueue:NULL];
  [self.manager changeContextWithNewContextType:kContextTypeArbiter];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  RSPacket *receivedPacket = [RSPacket packetFromData:data];

    NSLog(@"replica received packet on channel: %@", receivedPacket.channel);
  
  if([receivedPacket.channel isEqualToString:kClientPacket]) {
    [self.manager didReceivedPacket:receivedPacket];
  }
  else {
    NSAssert(NO ,@"Replica received a packet on a channel he shouldn't");
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}



@end
