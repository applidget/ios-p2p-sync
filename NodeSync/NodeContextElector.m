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
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
  NSData *priority = [[NSString stringWithFormat:@"%i", self.manager.priority] dataUsingEncoding:NSUTF8StringEncoding];
  [self.socket writeData:priority withTimeout:0 tag:PRIORITY_PACKET_TAG];
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  //No more connected arbiter shut down
  kContextType newContext = hasWonTheElection ? kContextTypeMaster : kContextTypeReplica;
  [self.manager changeToContextType:newContext];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  if(tag == PRIORITY_PACKET_TAG) {
    NSString *strPriority = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSInteger priority = [strPriority intValue];
    [strPriority release];
    hasWonTheElection = (priority == self.manager.priority);
  }
}


@end
