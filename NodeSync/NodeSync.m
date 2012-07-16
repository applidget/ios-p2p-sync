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

@implementation NodeSync

@synthesize delegate, context, sessionId, port, nodesInSession;

#pragma mark - Constructors
- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>) _delegate {
  if(self = [super init]) {
    self.delegate = _delegate;
    self.nodesInSession = [NSMutableArray array];
  }
  return self;
}

- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate sessionId:(NSString *) _sessionId {
  if(self = [self initWithDelegate:_delegate]) {
    self.sessionId = _sessionId;
  }
  return self;
}

- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate sessionId:(NSString *)_sessionId port:(NSInteger) _port {
  if(self = [self initWithDelegate:_delegate sessionId:_sessionId]) {
    self.port = _port;
  }
  return self;
}

#pragma mark - Context
- (void) sessionStateChangeForNode:(NodeData *) node {
  [self.nodesInSession addObject:node];
  if([self.delegate respondsToSelector:@selector(nodeSync:sessionStateChangeForNode:)]) {
    [self.delegate nodeSync:self sessionStateChangeForNode:node];
  }
}

- (void) didReadData:(NSData *) data {
  
}

#pragma mark - Client
- (void) startSessionWithContextType:(kContextType)contextType {
  //Set default values if needed
  if(!self.sessionId) {
    self.sessionId = @"default_session";
  }
  if(!self.port) {
    self.port = DEFAULT_PORT;
  }
  
  //Activate the appropriate context
  switch (contextType) {
    case kContextTypeMaster:
      
      break;
    case kContextTypeReplica:
      
      break;
    default:
      break;
  }
}

- (void) pushData:(NSData *) data {
  
}



@end
