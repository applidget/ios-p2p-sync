//
//  NodeContextMaster.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextMaster.h"
#import "OplogEntry.h"

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
  NSData *data = [[Packet packetWithIdentifier:kHeartBeatPacket content:self.manager.sessionMap emittingHost:self.socket.localHost] convertToData];
  [self pushData:data withTimeout:DEFAULT_TIMEOUT];
}

- (void) sendOplog {
  NSData *data = [[Packet packetWithIdentifier:kOplogPacket content:self.manager.oplog emittingHost:self.socket.localHost] convertToData];
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
  
  //Periodically send oplogs aswell
  [NSTimer scheduledTimerWithTimeInterval:HEART_BEAT_FREQUENCY target:self selector:@selector(sendOplog) userInfo:nil repeats:YES];
  
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
  
  if([readPacket.identifier isEqualToString:kClientPacket]) {
    //Reiceived a client packet from a replica (forwarded)
    //Updating oplog
    OplogEntry *newEntry = [OplogEntry oplogEntryWithPacket:readPacket];
    [self.manager.oplog addObject:newEntry];
    [self.manager didAddOplogEntry:newEntry];
  }
  else if([readPacket.identifier isEqualToString:kPriorityPacket]) {
    NSLog(@"master: prio packet SHOULDNOT");

  }
  else if([readPacket.identifier isEqualToString:kHeartBeatPacket]) {
    NSLog(@"MASTER: received heartbeat SHOULDNOT");
    
  }
  else {
    NSLog(@"master: unknown packet");
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}

@end
