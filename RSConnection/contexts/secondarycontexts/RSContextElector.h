//
//  NodeContextElector.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 Elector is the context where devices send their priority to become master to an arbiter. Once they connect to
 the arbiter they immediately send their priority. 
 - If the connection with the arbiter get cut, it means that the arbiter won the election so they switch to the replica context.
 - else if they received a priority packet:
  - if the priority is equal to their own priority: won the election, switch to master context
  - else, another elector won the election, switch to replica context
*/

#import "RSContextSecondary.h"

typedef enum {
  kElectionResultWon,
  kElectionResultLost,
  kElectionResultUnknown
}kElectionResult;

@interface RSContextElector : RSContextSecondary {
@private
  kElectionResult electionResult;
  NSTimer *timeOutTimer;
}

@end
