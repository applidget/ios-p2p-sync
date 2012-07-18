//
//  NodeContextArbiter.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 Arbiter context got incoming connection from device in elector context. This context is only used to allow devices to
 communicate when the previous master device crashed. Its role is to manage the election of the new master. For that, 
 every elector devices that connect send their priority. The arbiter stores each priority in the reiceivedPriority array.
 When ELECTION_TIME has been elapsed:
 - if arbiter has the highest priority, it becomes the master (change its context to master)
 - else it sends to every elector the winning priority and change its context to replica.
*/

#import "NodeContextPrimary.h"

#define ELECTION_TIME 7

@interface NodeContextArbiter : NodeContextPrimary {
@private
  NSMutableArray *receivedPriorities;
  BOOL tookTooLongToLaunchService;
}

@property (nonatomic, retain) NSMutableArray *receivedPriorities;

- (void) announceNewMaster;

@end
