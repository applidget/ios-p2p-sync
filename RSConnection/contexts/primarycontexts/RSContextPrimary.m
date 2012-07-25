//
//  NodeContextPrimary.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSContextPrimary.h"

@implementation RSContextPrimary

@synthesize connectedReplicas, netService;

- (void) activateWithServiceType:(NSString *) type andName:(NSString *) name {
  GCDAsyncSocket *contextSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
  self.socket = contextSocket;
  [contextSocket release];
  
  NSError *error = nil;
  if (![self.socket acceptOnPort:self.manager.port error:&error]) {
    NSLog(@"Failed to launch server: %@", error);
  }
  self.socket.delegate = self;
  
  self.connectedReplicas = [NSMutableArray array];
  
  NSNetService *contextService = [[NSNetService alloc] initWithDomain:SERVICE_DOMAIN type:type name:name port:self.manager.port];
  self.netService = contextService;
  [contextService release];
  self.netService.delegate = self;
  [self.netService publish];
}

- (void) unactivate {
  [self.netService stop];
  for(GCDAsyncSocket *sock in self.connectedReplicas) {
    [sock setDelegate:nil delegateQueue:NULL];
    [sock disconnectAfterWriting];
  }
  [self.connectedReplicas removeAllObjects];
  [self.socket setDelegate:nil delegateQueue:NULL];
  [self.socket disconnect];
}

- (void) writeData:(NSData *)data {
  for (GCDAsyncSocket *replicaSocket in self.connectedReplicas) {
    [replicaSocket writeData:data withTimeout:DEFAULT_TIMEOUT tag:0];
  }
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
  newSocket.delegate = self;
  [newSocket readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
  [self.connectedReplicas addObject:newSocket];
} 

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  [sock setDelegate:nil delegateQueue:NULL];
  [self.connectedReplicas removeObject:sock];
}

#pragma mark - memory management
- (void) dealloc {
  [connectedReplicas release];
  [netService release];
  [super dealloc];
}

@end
