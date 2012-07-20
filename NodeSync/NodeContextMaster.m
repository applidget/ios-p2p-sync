//
//  NodeContextMaster.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextMaster.h"

#define HEART_BEAT_FREQUENCY 2

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
  
  self.manager.sessionMap = [self generateSetMap];
  
  NSData *data = [[Packet packetWithId:kHeartBeatPacket andContent:self.manager.sessionMap emittingHost:self.socket.localHost] convertToData];
  
  [self pushData:data withTimeout:DEFAULT_TIMEOUT];
}


- (void) activate {  
  [super activateWithServiceType:[NSString stringWithFormat:@"%@%@", self.manager.sessionId ,MASTER_SERVICE] andName:@"master"];
  NSLog(@"activated master");
}

#pragma mark - NSNetServiceDelegate protocol
- (void) netServiceDidPublish:(NSNetService *)sender {
  //Succeded to be master, start heartbeat
  [NSTimer scheduledTimerWithTimeInterval:HEART_BEAT_FREQUENCY target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:YES];
  [self.manager didChangetState:kNodeStateMaster];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
  //maybe another master service already exist (a tie in the election ??)
  [super netService:sender didNotPublish:errorDict];
  [self.manager changeToContextType:kContextTypeReplica];
}

#pragma mark - GCDAsyncSocket delegate
- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  Packet *readPacket = [Packet packetFromData:data];
  
  if(!readPacket) {
    NSLog(@"data damaged");
    [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
    return;
  }
  
  if([readPacket.packetId isEqualToString:kClientPacket]) {
    [self.manager didReadClientPacket:readPacket];
    //Forward the packet to every other nodes
    [self pushData:data withTimeout:DEFAULT_TIMEOUT];
  }
  else if([readPacket.packetId isEqualToString:kPriorityPacket]) {
    NSLog(@"master: prio packet SHOULDNOT");

  }
  else if([readPacket.packetId isEqualToString:kHeartBeatPacket]) {
    NSLog(@"MASTER: received heartbeat SHOULDNOT");
    
  }
  else {
    NSLog(@"master: unknown packet");
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}

@end
