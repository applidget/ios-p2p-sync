//
//  NodeContextReplica.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 In a replica context, a device looks for the master service. When a replica is disconnected from the master,
 it changes its context to the arbiter context (since master is done, we need a new leader). If it fails to launch the
 arbiter service, it means that someone already succeed, so it switches fro arbiter to elector.
*/

#import "NodeContextSecondary.h"

@interface NodeContextReplica : NodeContextSecondary


@end
