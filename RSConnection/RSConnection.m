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

@implementation RSConnection

@synthesize delegate, port, replicaSetName, context, packetQueue, packetQueueMaxSize;

#pragma mark - Context
- (void) flushPacketQueue {
  if([self.context isKindOfClass:[RSContextArbiter class]] || [self.context isKindOfClass:[RSContextElector class]]) {
    return;
  }
  for (RSPacket *packet in self.packetQueue) {
    [self.context writeData:[packet representingData]];
  }
  [self.packetQueue removeAllObjects];
}

- (void) activateContext:(RSContext *) newContext {
  self.context = newContext;
  [self.context activate];
  //Try to flush packet queue
  [self flushPacketQueue];
}

- (void) changeContextWithNewContext:(kContextType)newContextType {
  [self.context unactivate];
  
  RSContext *newContext;
  
  switch (newContextType) {
    case kContextTypeReplica:
      newContext = [[RSContextReplica alloc] initWithManager:self];
      break;
    case kContextTypeMaster:
      newContext = [[RSContextMaster alloc] initWithManager:self];
      break;
    case kContextTypeArbiter:
      newContext = [[RSContextArbiter alloc] initWithManager:self];
      break;
    case kContextTypeElector:
      newContext = [[RSContextElector alloc] initWithManager:self];
    default:
      break;
  }
  
  [self performSelector:@selector(activateContext:) withObject:newContext afterDelay:0.5];
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

#pragma mark - client
- (void) startSessionWithContextType:(kContextType)contextType {
  if(!self.delegate) {
    NSAssert(NO, @"RSConnection: delegate is mandatory");
  }
  if(!self.port) {
    self.port = DEFAULT_PORT;
  }
  if(!self.replicaSetName) {
    self.replicaSetName = DEFAULT_REPLICA_SET_NAME;
  }
  if(!self.packetQueueMaxSize) {
    self.packetQueueMaxSize = DEFAULT_PACKET_QUEUE_SIZE;
  }
  self.packetQueue = [NSMutableArray array];
  [self changeContextWithNewContext:contextType];
}

- (void) sendObject:(id)object onChannel:(NSString *)channelName {
  //Write operation
  RSPacket *clientPacket = [RSPacket packetWithContent:object onChannel:channelName emittingHost:self.context.socket.localHost];
  
  //Wrapping original packet to use it within the library
  RSPacket *internalPacket = [RSPacket packetWithContent:clientPacket onChannel:kClientPacket emittingHost:self.context.socket.localHost];
  if([self.context isKindOfClass:[RSContextArbiter class]] || [self.context isKindOfClass:[RSContextElector class]]) {
    if(self.packetQueue.count >= self.packetQueueMaxSize) {
      [self.packetQueue removeObjectAtIndex:0];
    }
    [self.packetQueue addObject:internalPacket];
  }
  else {
    [self.context writeData:[internalPacket representingData]];
  }
  
}

- (void) needUpdateSince:(NSTimeInterval) timeStamp forChannel:(NSString *)channelName {
  NSAssert([self.context isKindOfClass:[RSContextReplica class]],@"needUpdateSince is only accessible by replica");
  RSPacket *requestPacket = [RSPacket packetWithContent:[NSNumber numberWithDouble:timeStamp]
                                              onChannel:channelName 
                                           emittingHost:self.context.socket.localHost];
  
  RSPacket *internalPacket = [RSPacket packetWithContent:requestPacket onChannel:kUpdateRequestPacket emittingHost:self.context.socket.localHost];
  
  [self.context writeData:[internalPacket representingData]];
}

- (void) dealloc {
  [replicaSetName release];
  [context unactivate];
  [context release];
  [packetQueue release];
  [super dealloc];
}

@end
