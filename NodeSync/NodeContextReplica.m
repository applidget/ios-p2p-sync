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
  NodeContextArbiter *_context = [[NodeContextArbiter alloc] initWithManager:self.manager];
  [self.manager changeToContext:_context];
  [_context release];
}


@end
