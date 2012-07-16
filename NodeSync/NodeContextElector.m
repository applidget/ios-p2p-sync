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
}

#pragma mark - GCDAsyncSocketDelegate protocol
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
  //Just connected to an arbiter, announce priority
  NSData *priority = [[NSString stringWithFormat:@"%i", self.manager.priority] dataUsingEncoding:NSUTF8StringEncoding];
  [self.socket writeData:priority withTimeout:0 tag:PRIORITY_PACKET_TAG];
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  //No more connected arbiter shut down
  NodeContextReplica *_context = [[NodeContextReplica alloc] initWithManager:self.manager];
  [self.manager changeToContext:_context];
  [_context release];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  if(tag == PRIORITY_PACKET_TAG) {
    NSString *strPriority = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSInteger priority = [strPriority intValue];
    [strPriority release];
    if(priority == self.manager.priority) {
      //Won the election
      NodeContextMaster *_context = [[NodeContextMaster alloc] initWithManager:self.manager];
      [self.manager changeToContext:_context];
      [_context release];
    }
  }
}


@end
