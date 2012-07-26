//
//  NodeContextSecondary.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSContextSecondary.h"

@implementation RSContextSecondary

@synthesize serviceBrowser, foundService;

- (void) activateWithServiceType:(NSString *)type {
  NSNetServiceBrowser *contextServiceBrowser = [[NSNetServiceBrowser alloc] init];
  self.serviceBrowser = contextServiceBrowser;
  [contextServiceBrowser release];
  self.serviceBrowser.delegate = self;
  [self.serviceBrowser searchForServicesOfType:type inDomain:SERVICE_DOMAIN];  
}

- (void) unactivate {
  [self.serviceBrowser stop];
  [self.socket setDelegate:nil delegateQueue:NULL];
  [self.socket disconnect];
}

- (void) writeData:(NSData *)data {
  [self.socket writeData:data withTimeout:DEFAULT_TIMEOUT tag:0];
}

#pragma mark - GCDAsynSocketDelegate
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port {
  [self.serviceBrowser stop];
  [self.socket readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
  self.manager.nbConnections ++;

}

#pragma mark - NSNetServiceBrowserDelegate
- (void) netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreComing {
  self.foundService = netService;
  self.foundService.delegate = self;
  [self.foundService resolveWithTimeout:0];
}

#pragma mark - NSNetServiceDelegate
- (void) netServiceDidResolveAddress:(NSNetService *)netService {
  GCDAsyncSocket *contextSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
  self.socket = contextSocket;
  [contextSocket release];
  self.socket.delegate = self;
  NSError *error = nil;
  if (![socket connectToHost:netService.hostName onPort:netService.port error:&error]) {
    [self.manager failedToOpenSocketWithError:error];
  }
}

#pragma mark - memory management
- (void) dealloc {
  [serviceBrowser release];
  [foundService release];
  [super dealloc];
}

@end
