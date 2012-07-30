//
//  RSConnection.h
//  RSConnection
//
//  Created by Robin on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//Network information
#define MASTER_SERVICE @"M._tcp."
#define ARBITER_SERVICE @"A._tcp."
#define DEFAULT_PORT 6320
#define DEFAULT_REPLICA_SET_NAME @"_DS"
#define SERVICE_DOMAIN @"local."

/**
 * Exceptions *
 
 * kNoDelegateException : Trying to join a replica set without delegate
 * kUnknownPacketException : This one was used internally and should never be raised within the delegate
 * kBadContextException : Trying to perform an operation which is impossible in the current context
 * kBadChannelNameException : Using a channel which is used internally by the libray. You shouldn't use channel starting by '_Private'
 * kObjectNotConformToNSCodingProtocol : trying to send an object which is not conform to the NSCoding protocol
 * kReceivedBadDataException : was not able to unarchive packet
*/

static NSString *kNoDelegateException = @"NoDelegateSetException";
static NSString *kUnknownPacketException = @"UnknownPacketException"; //never happens, uses internally
static NSString *kBadContextException = @"BadContextException";
static NSString *kBadChannelNameException = @"BadChannelNameException";
static NSString *kObjectNotConformToNSCodingProtocolException = @"ObjectNotConformToNSCodingProtocolException";
static NSString *kReceivedBadDataException = @"ReceivedBadDataException";

/**
 * Contexts *

 The library uses a state transition pattern. The main class of the library RSConnection have a RSContext ivar. RSContext class is subclassed by 4 concretes classes:
 * RSContextArbiter
 * RSContextMaster
 * RSContextElector
 * RSContextReplica
 
 Then the RSConnection class will use the current context to perform a given operation. This 4 contexts are represented by the kContextType enum.
*/

typedef enum {
  kContextTypeReplica,
  kContextTypeMaster,
  kContextTypeArbiter,
  kContextTypeElector
} kContextType;

/**
 * Connection states *
 
 Connection states will give information on the context as well as the state of the connection.
*/
typedef enum {
  kConnectionStateMaster,                 ///the connection is master, 0 or * replicas are connected to it. A replica that join the same replica set will connect to it automatically 
  kConnectionStateArbiter,                ///the connection is arbiter, an election is running, the device acts as a communication bridge during the election
  kConnectionStateFightingToBeArbiter,    ///master just became unavailable, every replicas connected to it try to become arbiter. Only one will succeed
  kConnectionStateReplicaSearching,       ///replica just joined the replica set. It's looking for the master (not yet connected to it)
  kConnectionStateReplicaConnected,       ///replica has just connect to the master and can now communicate with it
  kConnectionStateElectorSearching,       ///this device just failed to become arbiter (normal behavior), it's now looking for the arbiter
  kConnectionStateElectorConnected        ///the elector is now connected to the arbiter and can will soon send its priority to become master
} kConnectionState;

@class RSConnection, RSContext, RSPacket;

/** RSConnectionDelegateProtocol */
@protocol RSConnectionDelegateProtocol <NSObject>

/** The connection just updatet its state (see kConnectionState) */
- (void) connection:(RSConnection *)connection didUpdateStateInto:(kConnectionState)newState;

/** The connection just received an object on the channel 'channel' */
- (void) connection:(RSConnection *)connection didReceiveObject:(id)objectRead onChannel:(NSString *)channel;

/** An election is running, the priority of the device is needed (highest priority will become master) */
- (NSInteger) connectionRequestsPriorityOfElector:(RSConnection *)connection;

/** The device is master, a replica want update since timestamp */
- (void) connection:(RSConnection *)connection hasBeenAskedForUpdateSince:(NSTimeInterval)timeStamp onChannel:(NSString*)channel;

/** Something went wrong opening a socket (generated by GCDAsyncSocket class) */
- (void) connection:(RSConnection *)connection failedToOpenSocketWithError:(NSError *)error;

/** If an object can't be send during an election, it's returned */
- (void) connection:(RSConnection *)connection wasUnableToSendObjectDuringElection:(id)objectToSend onChannel:(NSString*)channelName;

/** Give the number of elector during the last election */
- (void) connection:(RSConnection *)connection numberOfParticipantsForLastElection:(NSInteger)numberOfParticipants;

/** A replica just disconnect from the master */
- (void) connection:(RSConnection *)connection replicaDidDisconnectWithError:(NSError *)error;

/** If the closeConnectionWhenBackgrounded is set to YES, this method must returns the context type to use when the app exit background (repllica context by default) */
- (kContextType) connectionContextTypeToUseAfterBackground:(RSConnection *)connection;

/** If the usePasswordForConnection is set to YES, this method must return the password to use for connecting */ 
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
///RSConnection delegate. Must be set before joining a rpelica set
@property (nonatomic, assign) id<RSConnectionDelegateProtocol> delegate; 
///Port to use. Default is 6320
@property (nonatomic, assign) NSInteger port;                             
///Name of the replica set. Default is _DS
/** @warning *Important:* repllcaSetName MUST start with _ and contains no more than 12 letters, without space or special characters */
@property (nonatomic, retain) NSString *replicaSetName;                   
///Current context type
@property (nonatomic, readonly) kContextType currentContextType;          
///Number of connection (0 to * for master or arbiter, 0 to 1 for replica or elector)
@property (nonatomic, assign) NSInteger nbConnections;                   
///Set to yes if you want the connection to be closed when the app is in background
@property (nonatomic, assign) BOOL closeConnectionWhenBackgrounded;      
///Set to yes if you want to use a password protected connection
@property (nonatomic, assign) BOOL usePasswordForConnection;              

/** Make the connection join the replica set. This will connect the device with others */
- (void) joinReplicaSetWithContextType:(kContextType) contextType;

/** Send an object on a given channel. 
 
 - If currentContextType is kContextTypeReplica, this will send the object to the master. 
 - If currentContextType is kContextTypeMaster, this will send the object to all connected replicas.
*/
- (void) sendObject:(id)object onChannel:(NSString *)channelName;

/** Will ask to the master to provide update since 'timeStamp' */
- (void) needUpdateSince:(NSTimeInterval)timeStamp onChannel:(NSString *)channelName;

/** Launch a new election */
- (void) forceNewElection;


/** Internally used */
- (void) changeContextWithNewContextType:(kContextType)newContext;
- (void) didUpdateStateInto:(kConnectionState)newState;
- (NSInteger) getPriorityOfElector;
- (void) didReceivePacket:(RSPacket *)packet;
- (void) failedToOpenSocketWithError:(NSError *)error;
- (void) numberOfParticipantsForLastElection:(NSInteger)numberOfElectors;
- (void) replicaDidDisconnectWithError:(NSError *)error;
- (kContextType) contextTypeToUseAfterBackground;
- (NSString *) requestPassword;

/** Just used for testing */
- (void) startMaster;

@end
