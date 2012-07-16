//
//  NodeContextMaster.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextMaster.h"

@implementation NodeContextMaster

@synthesize netService;

- (void) activate {
  //Opening listening socket
  GCDAsyncSocket *_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
  self.socket = _socket;
  [_socket release];
  
  NSError *error = nil;
  if (![self.socket acceptOnPort:self.manager.port error:&error]) {
    NSLog(@"Failed to launch server: %@", error);
  }
  self.socket.delegate = self;
  
  //Publishing Bonjour service
  NSNetService *_service = [[NSNetService alloc] initWithDomain:self.manager.sessionId type:MASTER_SERVICE name:nil port:self.manager.port];
  self.netService = _service;
  [_service release];
  [self.netService publish];
  self.netService.delegate = self;
  
  //Adding the master
  NodeData *nodeData = [[NodeData alloc] initWithIdentifier:socket.localHost contextType:kContextTypeMaster];
  [self.manager sessionStateChangeForNode:nodeData];
}

- (void) unactivate {
  [self.netService stop];
  [self.socket disconnect];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
  NSLog(@"incoming connection from: %@", newSocket.connectedHost);
  NodeData *nodeData = [[NodeData alloc] initWithIdentifier:newSocket.connectedHost contextType:kContextTypeReplica];
  [self.manager sessionStateChangeForNode:nodeData];
}

#pragma mark - NSNetServiceDelegate
- (void)netServiceWillPublish:(NSNetService *)sender {
  NSLog(@"Master publishing service");
}

- (void)netServiceDidPublish:(NSNetService *)sender {
  NSLog(@"Master service published service");
}

- (void) netServiceDidStop:(NSNetService *)sender {
  NSLog(@"Master service stopped");
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
  NSLog(@"Master service failed to publish: %@", [errorDict objectForKey:NSNetServicesErrorCode]);
  /*
   typedef enum {
   NSNetServicesUnknownError = -72000,
   NSNetServicesCollisionError = -72001,
   NSNetServicesNotFoundError    = -72002,
   NSNetServicesActivityInProgress = -72003,
   NSNetServicesBadArgumentError = -72004,
   NSNetServicesCancelledError = -72005,
   NSNetServicesInvalidError = -72006,
   NSNetServicesTimeoutError = -72007,
   } NSNetServicesError;
   */  
}

#pragma mark - memory management
- (void) dealloc {
  [netService release];
  [super dealloc];
}

@end
