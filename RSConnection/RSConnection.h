//
//  RSConnection.h
//  RSConnection
//
//  Created by Robin on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSPacket.h"

//Network information
#define MASTER_SERVICE @"M._tcp."
#define ARBITER_SERVICE @"A._tcp."
#define DEFAULT_PORT 6320
#define DEFAULT_REPLICA_SET_NAME @"_DS"
#define SERVICE_DOMAIN @"local."

#define DEFAULT_PACKET_QUEUE_SIZE 30

#define ERROR_DOMAIN @"rsconnection.error"

typedef enum {
  kContextTypeReplica,
  kContextTypeMaster,
  kContextTypeArbiter,
  kContextTypeElector
} kContextType;

typedef enum {
  kConnectionStateMaster,
  kConnectionStateArbiter,
  kConnectionStateFightingToBeArbiter,
  kConnectionStateReplicaSearching,
  kConnectionStateReplicaConnected,
  kConnectionStateElectorSearching,
  kConnectionStateElectorConnected
} kConnectionState;

@class RSConnection, RSContext;

@protocol RSConnectionDelegateProtocol <NSObject>

- (void) connection:(RSConnection *)connection didUpdateStateInto:(kConnectionState)newState;
- (void) connection:(RSConnection *)connection didReceivedObject:(id)objectRead onChannel:(NSString *)channel;
- (NSInteger) connectionRequestsPriorityOfElector:(RSConnection *)connection;
- (void) connection:(RSConnection *)connection hasBeenAskedForUpdateSince:(NSTimeInterval)timeStamp onChannel:(NSString*)channel;

@end


@interface RSConnection : NSObject {
@private
  id<RSConnectionDelegateProtocol> delegate;
  RSContext *context;
  NSInteger port;
  NSString *replicaSetName;
}

@property (nonatomic, assign) id<RSConnectionDelegateProtocol> delegate;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, retain) NSString *replicaSetName;
@property (nonatomic, retain) RSContext *context;

//Client
- (void) startSessionWithContextType:(kContextType) contextType;
- (void) sendObject:(id)object onChannel:(NSString *)channelName;
- (void) needUpdateSince:(NSTimeInterval) timeStamp forChannel:(NSString *)channelName;


//Context
- (void) changeContextWithNewContext:(kContextType)newContext;
- (void) didUpdateStateInto:(kConnectionState)newState;
- (NSInteger) getPriorityOfElector;
- (void) didReceivedPacket:(RSPacket *)packet;

//Garbage
- (void) startMaster;

@end
