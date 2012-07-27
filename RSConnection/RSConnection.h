//
//  RSConnection.h
//  RSConnection
//
//  Created by Robin on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RSPacket.h"

//Network information
#define MASTER_SERVICE @"M._tcp."
#define ARBITER_SERVICE @"A._tcp."
#define DEFAULT_PORT 6320
#define DEFAULT_REPLICA_SET_NAME @"_DS"
#define SERVICE_DOMAIN @"local."

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
- (void) connection:(RSConnection *)connection numberOfParticipantsForLastElection:(NSInteger)numberOfParticipants;
- (void) connection:(RSConnection *)connection replicaDidDisconnectWithError:(NSError *)error;
- (kContextType) connectionContextTypeToUseAfterBackground:(RSConnection *)connection;
- (NSString *) connectionRequestsPassword:(RSConnection *)connection;

@end


@interface RSConnection : NSObject {
@private
  id<RSConnectionDelegateProtocol> delegate;
  RSContext *context;
  NSInteger port;
  NSString *replicaSetName;
  kContextType currentContextType;
  NSInteger nbConnections;
  BOOL closeConnectionWhenBackgrounded;
  BOOL usePasswordForConnection;
}

@property (nonatomic, assign) id<RSConnectionDelegateProtocol> delegate;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, retain) NSString *replicaSetName;
@property (nonatomic, readonly) kContextType currentContextType;
@property (nonatomic, assign) NSInteger nbConnections;
@property (nonatomic, assign) BOOL closeConnectionWhenBackgrounded;
@property (nonatomic, assign) BOOL usePasswordForConnection;

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
- (void) numberOfParticipantsForLastElection:(NSInteger)numberOfElectors;
- (void) replicaDidDisconnectWithError:(NSError *)error;
- (kContextType) contextTypeToUseAfterBackground;
- (NSString *) requestPassword;

//Garbage
- (void) startMaster;

@end
