//
//  NodeContext.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSContext.h"

@implementation RSContext

@synthesize manager, socket;

- (id) initWithManager:(RSConnection *)contextManager {
  if(self = [super init]) {
    self.manager = contextManager;
  }
  return self;
}

#warning abstract methods implemented in subclasses
- (void) activate {}
- (void) unactivate {}
- (void) writeData:(NSData *)data {}

#pragma mark - GCDAsyncSocketDelegateProtcol
- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {}

#pragma mark - memory management
- (void) dealloc {
  [socket release];
  [super dealloc];
}

@end
