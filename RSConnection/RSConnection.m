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

@synthesize delegate, port, replicaSetName, context, currentContextType;

#pragma mark - Context
- (void) activateContext:(RSContext *) newContext {
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

- (void) didReceivedPacket:(RSPacket *)packet {
  RSPacket *originalPacket = packet.content;
  if([packet.channel isEqualToString:kClientPacket]) {
    [self.delegate connection:self didReceivedObject:originalPacket.content onChannel:originalPacket.channel];
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

- (BOOL) shouldAcceptNewReplicaWithIp:(NSString *)ip {
  if([self.delegate respondsToSelector:@selector(connection:shouldAcceptNewReplicaWithIp:)]) {
    return [self.delegate connection:self shouldAcceptNewReplicaWithIp:ip];
  }
  else {
    //Accept by default
    return YES;
  }
}

- (void) replicaDidDisconnect {
  if([self.delegate respondsToSelector:@selector(connectionReplicaDidDisconnect:)]) {
    [self.delegate connectionReplicaDidDisconnect:self];
  }
}

- (void) numberOfElectorsForLastElection:(NSInteger)numberOfElectors {
  if([self.delegate respondsToSelector:@selector(connection:numberOfElectorsForLastElection:)]) {
    [self.delegate connection:self numberOfElectorsForLastElection:numberOfElectors];
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

- (void) sendObject:(id)object onChannel:(NSString *)channelName {
  //Write operation
  RSPacket *clientPacket = [RSPacket packetWithContent:object onChannel:channelName emittingHost:self.context.socket.localHost];
  
  //Wrapping original packet to use it within the library
  RSPacket *internalPacket = [RSPacket packetWithContent:clientPacket onChannel:kClientPacket emittingHost:self.context.socket.localHost];
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
  
  if(![self.context isKindOfClass:[RSContextReplica class]]) {
    [NSException raise:kBadContextException format:@"needUpdateSince:onChannel not accessible only available in kContextReplica"];
  }
  
  RSPacket *requestPacket = [RSPacket packetWithContent:[NSNumber numberWithDouble:timeStamp]
                                              onChannel:channelName 
                                           emittingHost:self.context.socket.localHost];
  
  RSPacket *internalPacket = [RSPacket packetWithContent:requestPacket onChannel:kUpdateRequestPacket emittingHost:self.context.socket.localHost];
  
  [self.context writeData:[internalPacket representingData]];
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
