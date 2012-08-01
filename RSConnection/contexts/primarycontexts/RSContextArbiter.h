//
//  NodeContextArbiter.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 Arbiter context is launched automatically by all replicas which lost master connection. Only one will succeed to become arbiter. 
*/

#import "RSContextPrimary.h"

/** 
 Define the election time in seconds. This can be shorter if the number of device in the replica set is low. 
 @warning : if the connection uses password, election time might need to be higher. This need to be tested but 7 seconds was
 widely enough for 12 devices.
*/
#define ELECTION_TIME 7 

@interface RSContextArbiter : RSContextPrimary {
@private
  NSMutableArray *_receivedPriorities;
  BOOL _tookTooLongToLaunchService;
  NSInteger _priorityForElection;
}

@end
