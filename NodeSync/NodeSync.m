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
#import "NSDictionary+util.h"

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
 // [self.setMap removeAllObjects];
  
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
  [self.context performSelector:@selector(activate) withObject:nil afterDelay:0.2];
  
  if([self.delegate respondsToSelector:@selector(nodeSync:didChangeContextType:)]) {
    [self.delegate nodeSync:self didChangeContextType:newContext];
  }
}


- (void) didReadData:(NSData *) data withTag:(long)tag {
  if([self.delegate respondsToSelector:@selector(nodeSync:didReadData:)]) {
    //Remove the extra header packet
    NSDictionary *dict = [NSDictionary dictionaryFromData:data];
    NSData *originalData = [dict objectForKey:[dict packetKey]];
    [self.delegate nodeSync:self didReadData:originalData];
  }
}

- (void) didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  if([self.delegate respondsToSelector:@selector(nodeSync:didReadPartialDataOfLength:)]) {
    [self.delegate nodeSync:self didReadPartialDataOfLength:partialLength ];
  }
}

- (void) didWriteDataWithTag:(long)tag {
  if([self.delegate respondsToSelector:@selector(nodeSyncDidWriteData:)]) {
    [self.delegate nodeSyncDidWriteData:self];
  }
}

- (void) didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  if([self.delegate respondsToSelector:@selector(nodeSync:didWritePartialDataOfLength:)]) {
    [self.delegate nodeSync:self didWritePartialDataOfLength:partialLength];
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

- (void) pushData:(NSData *)data withTimeout:(NSTimeInterval)interval {
  //Encapsulate the data      
  NSDictionary *clientPacket = [NSDictionary dictionaryWithClientPacket:data];
  [self.context pushData:[clientPacket convertToData] withTimeout:interval];
}

- (void) startMaster {
  [self changeToContextType:kContextTypeMaster];
}



@end
