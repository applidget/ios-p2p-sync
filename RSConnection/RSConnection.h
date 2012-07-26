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
static NSString *kUnknownPacketException = @"UnknownPacketException"; //never happens, uses internally
static NSString *kBadContextException = @"BadContextException";
static NSString *kBadChannelNameException = @"BadChannelNameException";
static NSString *kObjectNotConformToNSCodingProtocol = @"ObjectNotConformToNSCodingProtocol";

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
- (void) connection:(RSConnection *)connection didReceiveObject:(id)objectRead onChannel:(NSString *)channel;
- (NSInteger) connectionRequestsPriorityOfElector:(RSConnection *)connection;
- (void) connection:(RSConnection *)connection hasBeenAskedForUpdateSince:(NSTimeInterval)timeStamp onChannel:(NSString*)channel;
- (void) connection:(RSConnection *)connection failedToOpenSocketWithError:(NSError *)error;
- (void) connection:(RSConnection *)connection wasUnableToSendObjectDuringElection:(id)objectToSend onChannel:(NSString*)channelName;
- (void) connectionReplicaDidDisconnect:(RSConnection *)connection withError:(NSError *)error;
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
- (void) forceNewElection;

//Context
- (void) changeContextWithNewContextType:(kContextType)newContext;
- (void) didUpdateStateInto:(kConnectionState)newState;
- (NSInteger) getPriorityOfElector;
- (void) didReceivePacket:(RSPacket *)packet;
- (void) failedToOpenSocketWithError:(NSError *)error;
- (void) replicaDidDisconnectWithError:(NSError *)error;
- (void) numberOfElectorsForLastElection:(NSInteger)numberOfElectors;

//Garbage
- (void) startMaster;

@end
