//
//  NodeContextElector.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextElector.h"
#import "NodeContextReplica.h"
#import "NodeContextMaster.h"

@implementation NodeContextElector

- (void) activate {
  [super activateWithServiceType:ARBITER_SERVICE];
  hasWonTheElection = NO;
}

#pragma mark - GCDAsyncSocketDelegate protocol
- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  //No more connected arbiter shut down
  kContextType newContext = hasWonTheElection ? kContextTypeMaster : kContextTypeReplica;
  [self.manager changeToContextType:newContext];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  NSDictionary *receivedDict = [NSDictionary dictionaryFromData:data];
  NSString *packetId = [receivedDict packetKey];
  
  if([packetId isEqualToString:CLIENT_PACKET_KEY]) {
    NSLog(@"elector: received client SHOULDNOT");
    
  }
  else if([packetId isEqualToString:PRIO_PACKET_KEY]) {
    NSLog(@"elector: prio packet");
    NSString *strPriority = [receivedDict objectForKey:packetId];
    NSInteger priority = [strPriority intValue];
    hasWonTheElection = (priority == self.manager.priority);
  }
  else if([packetId isEqualToString:HEARTBEAT_PACKET_KEY]) {
    NSLog(@"elector: received heartbeat SHOULDNOT");
    
  }
  else {
    NSLog(@"elector: unknown packet");
  }
  [sock readDataWithTimeout:DEFAULT_TIMEOUT tag:0];
}

@end
