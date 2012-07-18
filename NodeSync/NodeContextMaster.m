//
//  NodeContextMaster.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextMaster.h"

@implementation NodeContextMaster

- (NSMutableArray *) generateSetMap {
  NSMutableArray *setMap = [NSMutableArray arrayWithCapacity:self.connectedNodes.count + 1];
  for(GCDAsyncSocket *node in self.connectedNodes) {
    [setMap addObject:[NSDictionary dictionaryWithObject:@"replica" forKey:node.connectedHost]];
  }
  [setMap addObject:[NSDictionary dictionaryWithObject:@"master" forKey:self.socket.localHost]];
  return setMap;
}

- (void) sendHeartBeat {
  
  self.manager.setMap = [self generateSetMap];
  
  NSDictionary *dict = [NSDictionary dictionaryWithHeartBeatPacket:self.manager.setMap];
  [self pushData:[dict convertToData] withTimeout:DEFAULT_TIMEOUT];
}


- (void) activate {  
  [super activateWithServiceType:MASTER_SERVICE andName:@"master"];
  [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:YES];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  NSDictionary *receivedDict = [NSDictionary dictionaryFromData:data];
  
  if(!receivedDict) {
    NSLog(@"data damaged");
    return;
  }
  
  NSString *packetId = [receivedDict packetKey];
  
  if([packetId isEqualToString:CLIENT_PACKET_KEY]) {
    NSLog(@"master: received client");
    [self.manager didReadData:data withTag:tag];
  }
  else if([packetId isEqualToString:PRIO_PACKET_KEY]) {
    NSLog(@"master: prio packet SHOULDNOT");

  }
  else if([packetId isEqualToString:HEARTBEAT_PACKET_KEY]) {
    NSLog(@"MASTER: received heartbeat SHOULDNOT");
    
  }
  else {
    NSLog(@"master: unknown packet");
  }
  [sock readDataWithTimeout:DEFAULT_TIMEOUT tag:0];
}

@end
