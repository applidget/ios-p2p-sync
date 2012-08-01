//
//  NodeContextPrimary.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSContextPrimary.h"

@implementation RSContextPrimary

@synthesize connectedReplicas=_connectedReplicas, netService=_netService, delegateAlreadyAwareOfCurrentState=_delegateAlreadyAwareOfCurrentState, waitingConnections=_waitingConnections;

- (void) activateWithServiceType:(NSString *) type andName:(NSString *) name {
  GCDAsyncSocket *contextSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
  self.socket = contextSocket;
  [contextSocket release];
  
  NSError *error = nil;
  if (![self.socket acceptOnPort:self.manager.port error:&error]) {
    [self.manager failedToOpenSocketWithError:error];
  }
  self.socket.delegate = self;
  
  self.connectedReplicas = [NSMutableArray array];
  
  self.delegateAlreadyAwareOfCurrentState = NO;
  
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

- (void) socketAnsweredPasswordSuccessfully:(GCDAsyncSocket *)sock {
  [self.connectedReplicas addObject:sock];
  [self.waitingConnections removeObject:sock];
  self.manager.nbConnections = self.connectedReplicas.count;
  RSPacket *connectionACK = [RSPacket packetWithContent:kPasswordSuccess onChannel:kPasswordChannel emittingHost:self.socket.localHost];
  [sock writeData:[connectionACK representingData] withTimeout:DEFAULT_TIMEOUT tag:0];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
  newSocket.delegate = self;
  [newSocket readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
  if(self.manager.usePasswordForConnection) {
    [self.waitingConnections addObject:newSocket];
  }
  else {
    [self.connectedReplicas addObject:newSocket];
    self.manager.nbConnections = self.connectedReplicas.count;
  }

} 

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
  [sock setDelegate:nil delegateQueue:NULL];
  [self.connectedReplicas removeObject:sock];
  self.manager.nbConnections = self.connectedReplicas.count;
}

#pragma mark - backgrounding management
- (void) appDidEnterBackground {
  if(self.manager.closeConnectionWhenBackgrounded) {
    [self unactivate];
  }
}

- (void) appLeftBackground {
  if(self.manager.closeConnectionWhenBackgrounded) {
    [self.manager changeContextWithNewContextType:[self.manager contextTypeToUseAfterBackground]];
  }
  else {
    self.delegateAlreadyAwareOfCurrentState = YES; //No need to tell the delegate
    /*
     need delay because the delegate must have the time to call the method that indicate that the service stopped published when the app
     went in background. Otherwise, it crashes
     */
    [self.netService performSelector:@selector(publish) withObject:nil afterDelay:0.1];
  }
}

#pragma mark - memory management
- (void) dealloc {
  [_connectedReplicas release];
  [_waitingConnections release];
  [_netService release];
  [super dealloc];
}

@end
