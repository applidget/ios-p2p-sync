//
//  RSConnection.m
//  RSConnection
//
//  Created by Robin on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSConnection.h"
#import "RSContextArbiter.h"
#import "RSContextElector.h"
#import "RSContextMaster.h"
#import "RSContextReplica.h"

@interface RSConnection()

@property (nonatomic, retain) RSContext *context;

@end

@implementation RSConnection

@synthesize delegate, port, replicaSetName, context, currentContextType, nbConnections;

#pragma mark - Context
- (void) activateContext:(RSContext *) newContext {
  self.nbConnections = 0;
  self.context = newContext;
  [self.context activate];
}

- (void) changeContextWithNewContextType:(kContextType)newContextType {
  [self.context unactivate];
  
  RSContext *newContext;
  
  switch (newContextType) {
    case kContextTypeReplica:
      currentContextType = kContextTypeReplica;
      newContext = [[RSContextReplica alloc] initWithManager:self];
      break;
    case kContextTypeMaster:
      currentContextType = kContextTypeMaster;
      newContext = [[RSContextMaster alloc] initWithManager:self];
      break;
    case kContextTypeArbiter:
      currentContextType = kContextTypeArbiter;
      newContext = [[RSContextArbiter alloc] initWithManager:self];
      break;
    case kContextTypeElector:
      currentContextType = kContextTypeElector;
      newContext = [[RSContextElector alloc] initWithManager:self];
    default:
      break;
  }

  [self performSelector:@selector(activateContext:) withObject:newContext afterDelay:0.2]; //Timeout needed here otherwise from arbiter to master will crash (server close is asynchronous)
  [newContext release];
}

- (void) didUpdateStateInto:(kConnectionState)newState {
  if([self.delegate respondsToSelector:@selector(connection:didUpdateStateInto:)]){
    [self.delegate connection:self didUpdateStateInto:newState];
  }
}

- (NSInteger) getPriorityOfElector {
  return [self.delegate connectionRequestsPriorityOfElector:self];
}

- (void) didReceivePacket:(RSPacket *)packet {
  RSPacket *originalPacket = packet.content;
  if([packet.channel isEqualToString:kClientChannel]) {
    [self.delegate connection:self didReceiveObject:originalPacket.content onChannel:originalPacket.channel];
  }
  else {
    [self.delegate connection:self hasBeenAskedForUpdateSince:[originalPacket.content doubleValue] onChannel:originalPacket.channel];
  }
}

- (void) failedToOpenSocketWithError:(NSError *)error {
  if([self.delegate respondsToSelector:@selector(connection:failedToOpenSocketWithError:)]) {
    [self.delegate connection:self failedToOpenSocketWithError:error];
  }
}

- (void) numberOfElectorsForLastElection:(NSInteger)numberOfElectors {
  if([self.delegate respondsToSelector:@selector(connection:numberOfElectorsForLastElection:)]) {
    [self.delegate connection:self numberOfElectorsForLastElection:numberOfElectors];
  }
}

- (void) replicaDidDisconnectWithError:(NSError *)error {
  if([self.delegate respondsToSelector:@selector(connection:replicaDidDisconnectWithError:)]){
    [self.delegate connection:self replicaDidDisconnectWithError:error];
  }
}



#pragma mark - client
- (void) joinReplicaSetWithContextType:(kContextType)contextType {
  if(!self.delegate) {
    [NSException raise:kNoDelegateException format:@"Can't join a replica set without delegate"];
  }
  if(!self.port) {
    self.port = DEFAULT_PORT;
  }
  if(!self.replicaSetName) {
    self.replicaSetName = DEFAULT_REPLICA_SET_NAME;
  }
  
  [self changeContextWithNewContextType:contextType];
}

- (BOOL) isChannelNameValid:(NSString *)channelName {
  //Some channels are private (reserved for library uses)
  NSRange range = [channelName rangeOfString:kPrivateChannelPrefix];
  return range.location != 0;
}

- (void) sendObject:(id)object onChannel:(NSString *)channelName {
  
  if(![self isChannelNameValid:channelName]) {
    [NSException raise:kBadChannelNameException format:@"channel shouldn't start with %@", kPrivateChannelPrefix];
  }
  
  //Write operation
  RSPacket *clientPacket = [RSPacket packetWithContent:object onChannel:channelName emittingHost:self.context.socket.localHost];
  
  //Wrapping original packet to use it within the library
  RSPacket *internalPacket = [RSPacket packetWithContent:clientPacket onChannel:kClientChannel emittingHost:self.context.socket.localHost];
  if([self.context isKindOfClass:[RSContextArbiter class]] || [self.context isKindOfClass:[RSContextElector class]]) {
    if([self.delegate respondsToSelector:@selector(connection:wasUnableToSendObjectDuringElection:onChannel:)]) {
      [self.delegate connection:self wasUnableToSendObjectDuringElection:object onChannel:channelName];
    }
  }
  else {
    [self.context writeData:[internalPacket representingData]];
  }
  
}

- (void) needUpdateSince:(NSTimeInterval) timeStamp onChannel:(NSString *)channelName {
  
  if(![self isChannelNameValid:channelName]) {
    [NSException raise:kBadChannelNameException format:@"channel shouldn't start with %@", kPrivateChannelPrefix];
  }
  
  if(![self.context isKindOfClass:[RSContextReplica class]]) {
    [NSException raise:kBadContextException format:@"needUpdateSince:onChannel not accessible only available in kContextReplica"];
  }
  
  RSPacket *requestPacket = [RSPacket packetWithContent:[NSNumber numberWithDouble:timeStamp]
                                              onChannel:channelName 
                                           emittingHost:self.context.socket.localHost];
  
  RSPacket *internalPacket = [RSPacket packetWithContent:requestPacket onChannel:kUpdateRequestChannel emittingHost:self.context.socket.localHost];
  
  [self.context writeData:[internalPacket representingData]];
}

- (void) forceNewElection {
  if([self.context isKindOfClass:[RSContextElector class]] || [self.context isKindOfClass:[RSContextArbiter class]]) {
    [NSException raise:kBadContextException format:@"forceNewElection not accessible only available in kContextMaster / Replica"];
  }
  
  if([self.context isKindOfClass:[RSContextMaster class]]) {
    //Master wants a new election, just make it arbiter of the election
    [self changeContextWithNewContextType:kContextTypeArbiter];
  }
  else {
    //Replica context, ask the master to kill himself
    RSPacket *forceElectionPacket = [RSPacket packetWithContent:@"unused" onChannel:kForceNewElectionChannel emittingHost:self.context.socket.localHost];
    [self.context writeData:[forceElectionPacket representingData]];
  }
  
}

//Garbage
- (void) startMaster {
  [self changeContextWithNewContextType:kContextTypeMaster];
}

- (void) dealloc {
  [replicaSetName release];
  [context unactivate];
  [context release];
  [super dealloc];
}

@end
