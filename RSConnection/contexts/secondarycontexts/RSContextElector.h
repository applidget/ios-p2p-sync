//
//  NodeContextElector.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 Elector context
*/

#import "RSContextSecondary.h"

/** Enum containing the result of the election, from the point of view of self */
typedef enum {
  kElectionResultWon,
  kElectionResultLost,
  kElectionResultUnknown
}kElectionResult;

@interface RSContextElector : RSContextSecondary {
@private
  kElectionResult _electionResult;
  NSTimer *_timeOutTimer;
  NSInteger _priorityForElection;
}

@end
