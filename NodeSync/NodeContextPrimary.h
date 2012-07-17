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

#import "NodeContext.h"

@interface NodeContextPrimary : NodeContext {
@protected
  NSMutableArray *connectedNodes;
  NSNetService *netService;
}

@property (nonatomic, retain) NSMutableArray *connectedNodes;
@property (nonatomic, retain) NSNetService *netService;

- (void) activateWithServiceType:(NSString *) type andName:(NSString *) name;

@end
