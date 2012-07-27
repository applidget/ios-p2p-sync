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

    if(&UIApplicationDidEnterBackgroundNotification != nil) {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    if(&UIApplicationWillEnterForegroundNotification != nil) {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLeftBackground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
  }
  return self;
}

#warning abstract methods implemented in subclasses
- (void) activate {}
- (void) unactivate {}
- (void) writeData:(NSData *)data {}
- (void) appDidEnterBackground {}
- (void) appLeftBackground {}

#pragma mark - GCDAsyncSocketDelegateProtcol
- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {}

- (void) socketDidSecure:(GCDAsyncSocket *)sock {
  NSLog(@"secured socket");
}

#pragma mark - memory management
- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [socket release];
  [super dealloc];
}

@end
