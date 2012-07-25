//
//  NodeContextMaster.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSContextMaster.h"

#define HEART_BEAT_FREQUENCY 2

@implementation RSContextMaster

- (void) activate {  
  [super activateWithServiceType:[NSString stringWithFormat:@"%@%@", self.manager.replicaSetName, MASTER_SERVICE] andName:@"master"];
}

#pragma mark - NSNetServiceDelegate protocol
- (void) netServiceDidPublish:(NSNetService *)sender {  
  [self.manager didUpdateStateInto:kConnectionStateMaster];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
  //maybe another master service already exist (a tie in the election ??)
  [self.manager changeContextWithNewContextType:kContextTypeReplica];
}

#pragma mark - GCDAsyncSocket delegate
- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  RSPacket *receivedPacket = [RSPacket packetFromData:data];
  
  NSLog(@"master received packet on channel: %@", receivedPacket.channel);
  
  if([receivedPacket.channel isEqualToString:kClientPacket]) {
    [self.manager didReceivedPacket:receivedPacket];
  }
  else if([receivedPacket.channel isEqualToString:kUpdateRequestPacket]) {
    [self.manager didReceivedPacket:receivedPacket];
  }
  else {
    NSAssert(NO ,@"Master received a packet on a channel he shouldn't");
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}

@end
