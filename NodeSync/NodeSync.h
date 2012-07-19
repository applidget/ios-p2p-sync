//
//  NodeSync.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Packet.h"

//Network information
#define MASTER_SERVICE @"_master_service._tcp."
#define ARBITER_SERVICE @"_arbiter_service._tcp."
#define DEFAULT_PORT 6320
#define DEFAULT_SESSION_ID @"_default_session"
#define SERVICE_DOMAIN @"local."

#define ERROR_DOMAIN @"nodesync.error"

typedef enum {
  kContextTypeReplica,
  kContextTypeMaster,
  kContextTypeArbiter,
  kContextTypeElector
} kContextType;


@class NodeSync, NodeContext;

@protocol NodeSyncDelegateProtocol <NSObject>

- (void) nodeSync:(NodeSync *)nodeSync didRead:(id) objectRead forId:(NSString *) ide;

@optional
- (void) nodeSyncDidWriteData:(NodeSync *)nodeSync;
- (void) nodeSync:(NodeSync *)nodeSync didChangeContextType:(kContextType)newContext;

@end

@interface NodeSync : NSObject {
@private
  id<NodeSyncDelegateProtocol> delegate;
  NodeContext *context;
  NSMutableArray *sessionMap;
  NSInteger port;
  NSInteger priority;
  NSString *sessionId;
}

@property (nonatomic, assign) id<NodeSyncDelegateProtocol> delegate;
@property (nonatomic, retain) NSMutableArray *sessionMap;
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
- (void) changeToContextType:(kContextType) newContext;
- (void) didReadClientPacket:(Packet *) packet;
- (void) didWriteDataWithTag:(long)tag;

@end
