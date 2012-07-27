//
//  NodeContextPrimary.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 When a device is in a primary context, it means that other devices (in a secondary context) connect to it.
 In a primary context, devices have a listening socket which wait for incoming connection. They advertise this
 socket using a Bonjour service (hence the netService property). When there is an incoming connection, a new socket
 is spawned and added kept in an array (connectedNodes)
*/

#import "RSContext.h"

@interface RSContextPrimary : RSContext {
@protected
  NSMutableArray *connectedReplicas;
  NSMutableArray *waitingConnections;
  NSNetService *netService;
  BOOL delegateAlreadyAwareOfCurrentState;
}

@property (nonatomic, retain) NSMutableArray *connectedReplicas;
@property (nonatomic, retain) NSMutableArray *waitingConnections;
@property (nonatomic, retain) NSNetService *netService;
@property (nonatomic, assign) BOOL delegateAlreadyAwareOfCurrentState;

- (void) activateWithServiceType:(NSString *)type andName:(NSString *) name;
- (void) socketAnsweredPasswordSuccessfully:(GCDAsyncSocket *)sock;

@end
