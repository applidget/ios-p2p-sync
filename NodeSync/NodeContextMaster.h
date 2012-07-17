//
//  NodeContextMaster.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 Master context got incoming connection from devices in a replica context
 It sends an heartbeat every 2 seconds to every replicas connected to it.
*/

#import "NodeContextPrimary.h"

@interface NodeContextMaster : NodeContextPrimary

@end
