//
//  NodeSync.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeSync.h"
#import "NodeContext.h"
#import "NodeContextMaster.h"
#import "NodeContextReplica.h"
#import "NodeContextArbiter.h"
#import "NodeContextElector.h"

@interface NodeSync()

@property (nonatomic, retain) NodeContext *context;

@end

@implementation NodeSync

@synthesize delegate, context, sessionMap, port, priority, sessionId;

#pragma mark - Constructors
- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>) _delegate {
  if(self = [super init]) {
    self.delegate = _delegate;
    self.sessionMap = [NSMutableArray array];
    //Random priority
    self.priority = arc4random() % 10000;
  }
  return self;
}

- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate port:(NSInteger) _port {
  if(self = [self initWithDelegate:_delegate]) {
    self.port = _port;
  }
  return self;
}

- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>)_delegate port:(NSInteger)_port sessionId:(NSString *)_sessionId {
  if(self = [self initWithDelegate:_delegate port:_port]) {
    self.sessionId = _sessionId;
  }
  return self;
}

- (void) activateContext:(NodeContext *) newContext {
  self.context = newContext;
  [self.context activate];
}

#pragma mark - Context
- (void) changeToContextType:(kContextType) newContext {
  [self.context unactivate];
  
  NodeContext *_context;
  
  switch (newContext) {
    case kContextTypeReplica:
      _context = [[NodeContextReplica alloc] initWithManager:self];
      break;
    case kContextTypeMaster:
      _context = [[NodeContextMaster alloc] initWithManager:self];
      break;
    case kContextTypeArbiter:
      _context = [[NodeContextArbiter alloc] initWithManager:self];
      break;
    case kContextTypeElector:
      _context = [[NodeContextElector alloc] initWithManager:self];
    default:
      break;
  }
  
  
  [self performSelector:@selector(activateContext:) withObject:_context afterDelay:0.5];
  [_context release];
}

- (void) didChangetState:(kNodeState) newState {
  if([self.delegate respondsToSelector:@selector(nodeSync:didChangeState:)]) {
    [self.delegate nodeSync:self didChangeState:newState];
  }
}

- (void) didReadClientPacket:(Packet *) packet {
  if([self.delegate respondsToSelector:@selector(nodeSync:didRead:forId:)]) {
    Packet *clientPacket = packet.packetContent;
    [self.delegate nodeSync:self didRead:clientPacket.packetContent forId:clientPacket.packetId];
  }
}

- (void) didWriteDataWithTag:(long)tag {
  if([self.delegate respondsToSelector:@selector(nodeSyncDidWriteData:)]) {
    [self.delegate nodeSyncDidWriteData:self];
  }
}


#pragma mark - Client
- (void) startSessionWithContextType:(kContextType)contextType {
  if(!self.port) {
    self.port = DEFAULT_PORT;
  }
  if(!self.sessionId) {
    self.sessionId = DEFAULT_SESSION_ID;
  }
  [self changeToContextType:contextType];
}

- (void) push:(id) object forId:(NSString *) objId withTimeout:(NSTimeInterval)interval {
  
  if([self.context isKindOfClass:[NodeContextArbiter class]] || [self.context isKindOfClass:[NodeContextElector class]]) {
    NSLog(@"not in a context that allow client to push data");
    return;
  }
  Packet *clientPacket = [Packet packetWithId:objId andContent:object];
  Packet *internalPacket = [Packet packetWithId:kClientPacket andContent:clientPacket];
  if([self.context isKindOfClass:[NodeContextMaster class]]) {
    [self didReadClientPacket:internalPacket]; //write on master, master manage the packet for itself
  }
  NSData *internalPacketData = [internalPacket convertToData];
  [self.context pushData:internalPacketData withTimeout:interval];
}

- (void) startMaster {
  [self changeToContextType:kContextTypeMaster];
}

#pragma mark - memory management
- (void) dealloc {
  [sessionId release];
  [sessionMap release];
  [context release];
  [super dealloc];
}


@end
