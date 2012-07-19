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

@synthesize delegate, context, setMap, port, priority;

#pragma mark - Constructors
- (id) initWithDelegate:(id<NodeSyncDelegateProtocol>) _delegate {
  if(self = [super init]) {
    self.delegate = _delegate;
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
  
  self.context = _context;
  [_context release];
  [self.context performSelector:@selector(activate) withObject:nil afterDelay:0.1];
  
  if([self.delegate respondsToSelector:@selector(nodeSync:didChangeContextType:)]) {
    [self.delegate nodeSync:self didChangeContextType:newContext];
  }
}

- (void) didReadClientPacket:(Packet *) packet {
  if([self.delegate respondsToSelector:@selector(nodeSync:didRead:forId:)]) {
    Packet *clientPacket = (Packet*)packet.packetContent;
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
  //Set default values if needed
  if(!self.port) {
    self.port = DEFAULT_PORT;
  }
  [self changeToContextType:contextType];
}

- (void) push:(id) object forId:(NSString *) objId withTimeout:(NSTimeInterval)interval {
  Packet *clientPacket = [Packet packetWithId:objId andContent:object];
  NSData *internalPacketData = [[Packet packetWithId:kClientPacket andContent:clientPacket] convertToData];
  [self.context pushData:internalPacketData withTimeout:interval];
}

- (void) startMaster {
  [self changeToContextType:kContextTypeMaster];
}

#pragma mark - memory management
- (void) dealloc {
  [setMap release];
  [context release];
  [super dealloc];
}


@end
