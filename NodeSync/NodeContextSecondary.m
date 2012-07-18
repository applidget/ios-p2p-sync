//
//  NodeContextSecondary.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextSecondary.h"

@implementation NodeContextSecondary

@synthesize serviceBrowser, foundService;

- (void) activateWithServiceType:(NSString *) type {
  NSNetServiceBrowser *_serviceBrowser = [[NSNetServiceBrowser alloc] init];
  self.serviceBrowser = _serviceBrowser;
  [_serviceBrowser release];
  self.serviceBrowser.delegate = self;
  [self.serviceBrowser searchForServicesOfType:type inDomain:SERVICE_DOMAIN];  
}

- (void) unactivate {
  [self.serviceBrowser stop];
  [self.socket disconnect];
}

- (void) pushData:(NSData *)data withTimeout:(NSTimeInterval)interval {
  [self.socket writeData:data withTimeout:interval tag:0];
}

#pragma mark - GCDAsynSocketDelegate
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port {
  [self.socket readDataToData:END_PACKET withTimeout:DEFAULT_TIMEOUT tag:0];
}

#pragma mark - NSNetServiceBrowserDelegate
- (void) netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreComing {
  self.foundService = netService;
  self.foundService.delegate = self;
  [self.foundService resolveWithTimeout:0];
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {}

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {}

#pragma mark - NSNetServiceDelegate
- (void) netServiceDidResolveAddress:(NSNetService *)netService {
  GCDAsyncSocket *_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
  self.socket = _socket;
  [_socket release];
  self.socket.delegate = self;
  NSError *err = nil;
  if (![socket connectToHost:netService.hostName onPort:netService.port error:&err]) {
    NSLog(@"Error replica connecting to master: %@", err);
  }
}



#pragma mark - memory management
- (void) dealloc {
  [serviceBrowser release];
  [foundService release];
  [super dealloc];
}

@end
