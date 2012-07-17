//
//  NodeContext.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContext.h"

@implementation NodeContext

@synthesize manager, socket;

- (id) initWithManager:(NodeSync *) _manager {
  if(self = [super init]) {
    self.manager = _manager;
  }
  return self;
}

#warning abstract methods managed by subclasses
- (void) activate {}
- (void) unactivate {}
- (void) pushData:(NSData *)data withTimeout:(NSTimeInterval)interval tag:(long)tag {}

#pragma mark - GCDAsyncSocketDelegateProtcol
- (void) socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  [self.manager didWritePartialDataOfLength:partialLength tag:tag];
}

- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
  [self.manager didWriteDataWithTag:tag];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  [sock readDataWithTimeout:-1 tag:0];
  [self.manager didReadData:data withTag:tag];
}

- (void) socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  [self.manager didReadPartialDataOfLength:partialLength tag:tag];
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {}

- (void) socketDidCloseReadStream:(GCDAsyncSocket *)sock {}

#pragma mark - memory management
- (void) dealloc {
  [socket release];
  [super dealloc];
}

@end
