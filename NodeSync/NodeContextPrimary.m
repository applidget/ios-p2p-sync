//
//  NodeContextPrimary.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextPrimary.h"

@implementation NodeContextPrimary

@synthesize connectedNodes, netService;

- (void) activateWithServiceType:(NSString *) type andName:(NSString *) name {
  GCDAsyncSocket *_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
  self.socket = _socket;
  [_socket release];
  
  NSError *error = nil;
  if (![self.socket acceptOnPort:self.manager.port error:&error]) {
    NSLog(@"Failed to launch server: %@", error);
  }
  self.socket.delegate = self;
  
  self.connectedNodes = [NSMutableArray array];
  
  NSNetService *_service = [[NSNetService alloc] initWithDomain:SERVICE_DOMAIN type:type name:name port:self.manager.port];
  self.netService = _service;
  [_service release];
  self.netService.delegate = self;
  [self.netService publish];
}

- (void) unactivate {
  [self.netService stop];
  for(GCDAsyncSocket *sock in self.connectedNodes) {
    [sock disconnect];
  }
  [self.connectedNodes removeAllObjects];
  [self.socket disconnect];
}

- (void) pushData:(NSData *)data withTimeout:(NSTimeInterval)interval {
  for (GCDAsyncSocket *nodeSocket in self.connectedNodes) {
    [nodeSocket writeData:data withTimeout:interval tag:0];
  }
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
  newSocket.delegate = self;
  [newSocket readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
  [self.connectedNodes addObject:newSocket];
} 

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  [self.connectedNodes removeObject:sock];
  NSLog(@"socket disconnected: %@", sock.connectedHost);
}

#pragma mark - NSNetServiceDelegate
- (void)netServiceWillPublish:(NSNetService *)sender {}

- (void)netServiceDidPublish:(NSNetService *)sender {}

- (void) netServiceDidStop:(NSNetService *)sender {}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
  NSLog(@"%@", errorDict);
  NSLog(@"bad session name. Use _xxxxxxxx");
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
  [connectedNodes release];
  [netService release];
  [super dealloc];
}

@end
