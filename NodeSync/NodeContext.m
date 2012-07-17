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

#pragma mark - GCDAsyncSocketDelegateProtcol
- (void) socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  [self.manager didWritePartialDataOfLength:partialLength tag:tag];
}

- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
  [self.manager didWriteDataWithTag:tag];
  NSLog(@"wrote data");
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  NSLog(@"read data");
  [self.socket readDataWithTimeout:-1 tag:0];
  [self.manager didReadData:data withTag:tag];
}

- (void) socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  [self.manager didReadPartialDataOfLength:partialLength tag:tag];
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  NSLog(@"socket did disconnect");
}

- (void) socketDidCloseReadStream:(GCDAsyncSocket *)sock {
  NSLog(@"lost read stream");
}

#pragma mark - memory management
- (void) dealloc {
  [manager release];
  [socket release];
  [super dealloc];
}

@end
