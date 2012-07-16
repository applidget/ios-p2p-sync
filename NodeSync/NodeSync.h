//
//  NodeSync.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MASTER_SERVICE @"_master_service._tcp."
#define DEFAULT_PORT 62320

#define ERROR_DOMAIN @"nodesync.error"

typedef enum {
  kContextTypeReplica,
  kContextTypeMaster
} kContextType;

typedef enum {
  kSessionStateConnect,
  kSessionStateDisconnect
} kSessionState;

@class NodeSync, NodeContext, NodeData;

@protocol NodeSyncDelegateProtocol <NSObject>

- (void) nodeSync:(NodeSync *)_nodeSync sessionStateChangeForNode:(NodeData *) node;
- (void) nodeSync:(NodeSync *)_nodeSync didReadData:(NSData *) data;

@end

@interface NodeSync : NSObject {
@private
  id<NodeSyncDelegateProtocol> delegate;
  NodeContext *context;
  NSString *sessionId;
  NSInteger port;
  NSMutableArray *nodesInSession;
  
}

@property (nonatomic, assign) id<NodeSyncDelegateProtocol> delegate;
@property (nonatomic, retain) NodeContext *context;
@property (nonatomic, retain) NSString *sessionId;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, retain) NSMutableArray *nodesInSession;

- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate;
- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate sessionId:(NSString *) _sessionId;
- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate sessionId:(NSString *)_sessionId port:(NSInteger) _port;

//Client
- (void) startSessionWithContextType:(kContextType) contextType;
- (void) pushData:(NSData *) data;

//Context
- (void) sessionStateChangeForNode:(NodeData *) node;
- (void) didReadData:(NSData *) data;

@end
