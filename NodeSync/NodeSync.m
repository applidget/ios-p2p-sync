//
//  NodeSync.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeSync.h"
#import "NodeContext.h"
#import "NodeContextMaster.h"
#import "NodeContextReplica.h"
#import "NodeContextArbiter.h"
#import "NodeContextElector.h"

@implementation NodeSync

@synthesize delegate, context, port, priority;

#pragma mark - Constructors
- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>) _delegate {
  if(self = [super init]) {
    self.delegate = _delegate;
    //Random priority
    self.priority = arc4random() % 10000;
  }
  return self;
}

- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate port:(NSInteger) _port {
  if(self = [self initWithDelegate:_delegate]) {
    self.port = _port;
  }
  return self;
}

#pragma mark - Context
- (void) changeToContextType:(kContextType) newContext {
  [self.context unactivate];
  
  NodeContext *_context;
  
  switch (newContext) {
    case kContextTypeReplica:
      _context = [[NodeContextReplica alloc] initWithManager:self];
      break;
    case kContextTypeMaster:
      _context = [[NodeContextMaster alloc] initWithManager:self];
      break;
    case kContextTypeArbiter:
      _context = [[NodeContextArbiter alloc] initWithManager:self];
      break;
    case kContextTypeElector:
      _context = [[NodeContextElector alloc] initWithManager:self];
    default:
      break;
  }
  
  self.context = _context;
  [_context release];
  [self.context activate];
  
  if([self.delegate respondsToSelector:@selector(nodeSync:didChangeContextType:)]) {
    [self.delegate nodeSync:self didChangeContextType:newContext];
  }
}


- (void) didReadData:(NSData *) data withTag:(long)tag {
  if([self.delegate respondsToSelector:@selector(nodeSync:didReadData:withTag:)]) {
    [self.delegate nodeSync:self didReadData:data withTag:tag];
  }
}

- (void) didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  if([self.delegate respondsToSelector:@selector(nodeSync:didReadPartialDataOfLength:tag:)]) {
    [self.delegate nodeSync:self didReadPartialDataOfLength:partialLength tag:tag];
  }
}

- (void) didWriteDataWithTag:(long)tag {
  if([self.delegate respondsToSelector:@selector(nodeSync:didWriteDataWithTag:)]) {
    [self.delegate nodeSync:self didWriteDataWithTag:tag];
  }
}

- (void) didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  if([self.delegate respondsToSelector:@selector(nodeSync:didWritePartialDataOfLength:tag:)]) {
    [self.delegate nodeSync:self didWritePartialDataOfLength:partialLength tag:tag];
  }
}


#pragma mark - Client
- (void) startSessionWithContextType:(kContextType)contextType {
  //Set default values if needed
  if(!self.port) {
    self.port = DEFAULT_PORT;
  }
  
  //Activate the appropriate context
  [self changeToContextType:contextType];
}

- (void) pushData:(NSData *)data withTimeout:(NSTimeInterval)interval tag:(long)tag {
  [self.context pushData:data withTimeout:interval tag:tag];
}

- (void) startMaster {
  [self changeToContext:kContextTypeMaster];
}



@end
