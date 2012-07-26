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

//Errors exception
#define ERROR_DOMAIN @"rsconnection.error"

static NSString *kNoDelegateException = @"NoDelegateSetException";
static NSString *kUnknownPacketException = @"UnknownPacketException";
static NSString *kBadContextException = @"BadContextException";

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
- (void) connection:(RSConnection *)connection failedToOpenSocketWithError:(NSError *)error;
- (void) connection:(RSConnection *)connection wasUnableToSendObjectDuringElection:(id)objectToSend onChannel:(NSString*)channelName;
- (BOOL) connection:(RSConnection *)connection shouldAcceptNewReplicaWithIp:(NSString *)ip; 
- (void) connectionReplicaDidDisconnect:(RSConnection *)connection;
- (void) connection:(RSConnection *)connection numberOfElectorsForLastElection:(NSInteger)numberOfElectors;


@end


@interface RSConnection : NSObject {
@private
  id<RSConnectionDelegateProtocol> delegate;
  RSContext *context;
  NSInteger port;
  NSString *replicaSetName;
  kContextType currentContextType;
}

@property (nonatomic, assign) id<RSConnectionDelegateProtocol> delegate;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, retain) NSString *replicaSetName;
@property (nonatomic, readonly) kContextType currentContextType;

//Client
- (void) joinReplicaSetWithContextType:(kContextType) contextType;
- (void) sendObject:(id)object onChannel:(NSString *)channelName;
- (void) needUpdateSince:(NSTimeInterval)timeStamp onChannel:(NSString *)channelName;

//Context
- (void) changeContextWithNewContextType:(kContextType)newContext;
- (void) didUpdateStateInto:(kConnectionState)newState;
- (NSInteger) getPriorityOfElector;
- (void) didReceivedPacket:(RSPacket *)packet;
- (void) failedToOpenSocketWithError:(NSError *)error;
- (BOOL) shouldAcceptNewReplicaWithIp:(NSString *)ip; 
- (void) replicaDidDisconnect;
- (void) numberOfElectorsForLastElection:(NSInteger)numberOfElectors;

//Garbage
- (void) startMaster;

@end
