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
    NSLog(@"a repllicas won");
        
    NSData *priority = [[NSString stringWithFormat:@"%i", highestPrio] dataUsingEncoding:NSUTF8StringEncoding];
    [self pushData:priority withTimeout:-1 tag:PRIORITY_PACKET_TAG];
    
    NodeContextReplica *_context = [[NodeContextReplica alloc] initWithManager:self.manager];
    [self.manager changeToContext:_context];
    [_context release];
  }
  else { //Arbiter has highest prio, becomes master
    NodeContextMaster *_context = [[NodeContextMaster alloc] initWithManager:self.manager]; 
    [self.manager changeToContext:_context];
    [_context release];
  }
}

#pragma mark - NSNetServiceDelegate protocol
- (void) netServiceDidPublish:(NSNetService *)sender {
  //Officially became arbiter
  self.receivedPriorities = [NSMutableArray array];
  [self performSelector:@selector(announceNewMaster) withObject:nil afterDelay:ELECTION_TIME];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
  NSLog(@"Arbiter service failed to publish: %@", [errorDict objectForKey:NSNetServicesErrorCode]);
  //an other arbiter service is already launched
  NodeContextElector *_context = [[NodeContextElector alloc] initWithManager:self.manager];
  [self.manager changeToContext:_context];
  [_context release];
}

#pragma mark GCDAsyncSocketDelegate protocol
- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  if(tag == PRIORITY_PACKET_TAG) {
    NSString *strPriority = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.receivedPriorities addObject:strPriority];
    [strPriority release];
  }
}

#pragma mark - GCDAsyncSocketDelegate protocol
- (void) dealloc {
  [receivedPriorities release];
  [super dealloc];
}

@end
