//
//  NodeContextArbiter.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextArbiter.h"
#import "NodeContextElector.h"
#import "NodeContextReplica.h"
#import "NodeContextMaster.h"

@implementation NodeContextArbiter

@synthesize receivedPriorities;

- (void) activate {  
  [super activateWithServiceType:ARBITER_SERVICE andName:@"arbiter"];
}

- (void) announceNewMaster {
  NSInteger highestPrio = 0;
  for (NSString *prio in self.receivedPriorities) {
    NSInteger currentPrio = [prio intValue];
    if(currentPrio > highestPrio) {
      highestPrio = currentPrio;
    }
  }

  if(highestPrio > self.manager.priority) {
    NSDictionary *prioPacket = [NSDictionary dictionaryWithPriorityPacket:[NSString stringWithFormat:@"%i", highestPrio]];
    [self pushData:[prioPacket convertToData] withTimeout:DEFAULT_TIMEOUT];
    [self.manager changeToContextType:kContextTypeReplica];
  }
  else { //Arbiter has highest prio, becomes master
    [self.manager changeToContextType:kContextTypeMaster];
  }
}

#pragma mark - NSNetServiceDelegate protocol
- (void) netServiceDidPublish:(NSNetService *)sender {
  NSMutableArray *_receivedPriorities = [[NSMutableArray alloc] init];
  self.receivedPriorities = _receivedPriorities;
  [_receivedPriorities release];
  [self performSelector:@selector(announceNewMaster) withObject:nil afterDelay:ELECTION_TIME];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
  //an other arbiter service is already launched
  [self.manager changeToContextType:kContextTypeElector];
}

#pragma mark GCDAsyncSocketDelegate protocol
- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  NSDictionary *receivedDict = [NSDictionary dictionaryFromData:data];
  
  if(!receivedDict) {
    NSLog(@"data damaged");
    [sock readDataToData:END_PACKET withTimeout:DEFAULT_TIMEOUT tag:0];
    return;
  }
  
  NSString *packetId = [receivedDict packetKey];
  
  if([packetId isEqualToString:CLIENT_PACKET_KEY]) {
    NSLog(@"arbiter: received client SHOULDNOT");
    
  }
  else if([packetId isEqualToString:PRIO_PACKET_KEY]) {
    NSLog(@"arbiter: prio packet");
    
    NSString *strPriority = [receivedDict objectForKey:packetId];
    [self.receivedPriorities addObject:strPriority];
  }
  else if([packetId isEqualToString:HEARTBEAT_PACKET_KEY]) {
    NSLog(@"arbiter: received heartbeat SHOULDNOT");
    
  }
  else {
    NSLog(@"arbiter: unknown packet");
  }
  [sock readDataToData:END_PACKET withTimeout:DEFAULT_TIMEOUT tag:0];
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  
}

#pragma mark - memory management
- (void) dealloc {
  [receivedPriorities release];
  [super dealloc];
}

@end
