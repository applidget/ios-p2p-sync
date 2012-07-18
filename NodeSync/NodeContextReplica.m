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
  [super activateWithServiceType:MASTER_SERVICE];
}

#pragma mark - GCDAsyncSocketDelegate protocol
- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {  
  //Lost connection to master -> trying to launch arbiter context
  [self.manager changeToContextType:kContextTypeArbiter];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  NSDictionary *receivedDict = [NSDictionary dictionaryFromData:data];
  
  if(!receivedDict) {
    NSLog(@"data damaged");
    return;
  }
  
  NSString *packetId = [receivedDict packetKey];
  
  if([packetId isEqualToString:CLIENT_PACKET_KEY]) {
    NSLog(@"replica: received client");
    [self.manager didReadData:data withTag:tag];
  }
  else if([packetId isEqualToString:PRIO_PACKET_KEY]) {
    NSLog(@"replica: prio packet SHOULDNOT");
    
  }
  else if([packetId isEqualToString:HEARTBEAT_PACKET_KEY]) {
    NSLog(@"replica: received heartbeat");
    NSDictionary *dict = [NSDictionary dictionaryFromData:data];
    self.manager.setMap = [dict objectForKey:[dict packetKey]];
  }
  else {
    NSLog(@"replica: unknown packet");
  }
  [sock readDataWithTimeout:DEFAULT_TIMEOUT tag:0];
}



@end
