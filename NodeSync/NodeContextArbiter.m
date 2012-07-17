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
    NSData *priority = [[NSString stringWithFormat:@"%i", highestPrio] dataUsingEncoding:NSUTF8StringEncoding];
    [self pushData:priority withTimeout:DEFAULT_TIMEOUT tag:PRIORITY_PACKET_TAG];
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
  if(tag == PRIORITY_PACKET_TAG) {
    NSString *strPriority = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.receivedPriorities addObject:strPriority];
    [strPriority release];
  }
  [super socket:sock didReadData:(NSData *)data withTag:tag];
}

#pragma mark - GCDAsyncSocketDelegate protocol
- (void) dealloc {
  [receivedPriorities release];
  [super dealloc];
}

@end
