//
//  NodeSync.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//Network information
#define MASTER_SERVICE @"_master_service._tcp."
#define ARBITER_SERVICE @"_arbiter_service._tcp."
#define DEFAULT_PORT 6320
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

@optional
- (void) nodeSync:(NodeSync *)nodeSync didWritePartialDataOfLength:(NSUInteger)partialLength;
- (void) nodeSyncDidWriteData:(NodeSync *)nodeSync;
- (void) nodeSync:(NodeSync *)nodeSync didReadData:(NSData *)data;
- (void) nodeSync:(NodeSync *)nodeSync didReadPartialDataOfLength:(NSUInteger)partialLength;

- (void) nodeSync:(NodeSync *)nodeSync didChangeContextType:(kContextType)newContext;

@end

@interface NodeSync : NSObject {
@private
  id<NodeSyncDelegateProtocol> delegate;
  NodeContext *context;
  NSMutableArray *setMap;
  NSInteger port;
  NSInteger priority;
}

@property (nonatomic, assign) id<NodeSyncDelegateProtocol> delegate;
@property (nonatomic, retain) NodeContext *context;
@property (nonatomic, retain) NSMutableArray *setMap;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, assign) NSInteger priority;

- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate;
- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate port:(NSInteger) _port;

//Client
- (void) startSessionWithContextType:(kContextType) contextType;
- (void) pushData:(NSData *)data withTimeout:(NSTimeInterval)interval;
- (void) startMaster;

//Context
- (void) changeToContextType:(kContextType) newContext;

- (void) didReadData:(NSData *) data withTag:(long)tag;
- (void) didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
- (void) didWriteDataWithTag:(long)tag;
- (void) didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;


@end
