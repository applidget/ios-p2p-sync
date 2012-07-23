//
//  NodeSync.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Packet.h"
#import "OplogEntry.h"

//Network information
#define MASTER_SERVICE @"M._tcp."
#define ARBITER_SERVICE @"A._tcp."
#define DEFAULT_PORT 6320
#define DEFAULT_SESSION_ID @"_DS"
#define SERVICE_DOMAIN @"local."

#define ERROR_DOMAIN @"nodesync.error"

typedef enum {
  kContextTypeReplica,
  kContextTypeMaster,
  kContextTypeArbiter,
  kContextTypeElector
} kContextType;

typedef enum {
  kNodeStateMaster,
  kNodeStateArbiter,
  kNodeStateFightingToBeArbiter,
  kNodeStateReplicaSearching,
  kNodeStateReplicaConnected,
  kNodeStateElectorSearching,
  kNodeStateElectorConnected
} kNodeState;

@class NodeSync, NodeContext;

@protocol NodeSyncDelegateProtocol <NSObject>

- (void) nodeSync:(NodeSync *)nodeSync didRead:(id)objectRead identifier:(NSString *)identifier time:(NSDate *)time;

@optional
- (void) nodeSyncDidWriteData:(NodeSync *)nodeSync;
- (void) nodeSync:(NodeSync *)nodeSync didChangeState:(kNodeState)newState;


@end

@interface NodeSync : NSObject {
@private
  id<NodeSyncDelegateProtocol> delegate;
  NodeContext *context;
  NSMutableArray *sessionMap;
  NSMutableArray *oplog;
  NSInteger port;
  NSInteger priority;
  NSString *sessionId;
}

@property (nonatomic, assign) id<NodeSyncDelegateProtocol> delegate;
@property (nonatomic, retain) NSMutableArray *sessionMap;
@property (nonatomic, retain) NSMutableArray *oplog;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, retain) NSString *sessionId;

- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate;
- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate port:(NSInteger) _port;
- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate port:(NSInteger) _port sessionId:(NSString *)_sessionId;

//Client
- (void) startSessionWithContextType:(kContextType) contextType;
- (void) startMaster;
- (void) push:(id) object forId:(NSString *) objId withTimeout:(NSTimeInterval)interval;

//Context
- (void) didChangetState:(kNodeState) newState;
- (void) changeToContextType:(kContextType) newContext;
- (void) didWriteDataWithTag:(long)tag;
- (void) didAddOplogEntry:(OplogEntry *)entry;
- (BOOL) oplogContainsEntry:(NSString *)entry;

@end
