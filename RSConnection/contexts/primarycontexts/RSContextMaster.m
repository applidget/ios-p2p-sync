//
//  NodeContextMaster.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSContextMaster.h"

@implementation RSContextMaster

- (void) activate {  
  [super activateWithServiceType:[NSString stringWithFormat:@"%@%@", self.manager.replicaSetName, MASTER_SERVICE] andName:@"master"];
}

#pragma mark - NSNetServiceDelegate protocol
- (void) netServiceDidPublish:(NSNetService *)sender {  
  if(self.delegateAlreadyAwareOfCurrentState) return;
  [self.manager didUpdateStateInto:kConnectionStateMaster];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
  //maybe another master service already exist (a tie in the election ??)
  if([[errorDict objectForKey:NSNetServicesErrorCode] intValue] == NSNetServicesCollisionError) {
    if(!self.delegateAlreadyAwareOfCurrentState) {
      //someone launched a master service while real master was sleeping. DO not disconnect everyone !!
      [self.manager changeContextWithNewContextType:kContextTypeReplica];
    }
  }
}

#pragma mark - GCDAsyncSocket delegate
- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  [super socketDidDisconnect:sock withError:err];
  [self.manager replicaDidDisconnectWithError:err];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  RSPacket *receivedPacket = [RSPacket packetFromData:data];
    
  if([receivedPacket.channel isEqualToString:kClientChannel]) {
    [self.manager didReceivePacket:receivedPacket];
  }
  else if([receivedPacket.channel isEqualToString:kUpdateRequestChannel]) {
    [self.manager didReceivePacket:receivedPacket];
  }
  else if([receivedPacket.channel isEqualToString:kForceNewElectionChannel]) {
    [self.manager changeContextWithNewContextType:kContextTypeArbiter];
  }
  else {
    [NSException raise:kUnknownPacketException format:@"Master received a packet from an unknown channel %@", receivedPacket.channel];
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}

@end
