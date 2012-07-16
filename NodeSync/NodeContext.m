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

- (void) activate {

}

- (void) unactivate {
  
}

- (void) pushData:(NSData *)data {
  [self.socket writeData:data withTimeout:DEFAULT_TIMEOUT tag:0];
}

#pragma mark - GCDAsyncSocketDelegateProtcol
- (void) socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  NSLog(@"writting data");
}

- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
  NSLog(@"data wrote");
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  NSLog(@"Data read");
  [self.manager didReadData:data];
}

- (void) socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  NSLog(@"is reading data");
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  NSLog(@"socket disconnected");
}

#pragma mark - memory management
- (void) dealloc {
  [manager release];
  [socket release];
  [super dealloc];
}

@end
