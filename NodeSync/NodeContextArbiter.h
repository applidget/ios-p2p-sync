//
//  NodeContextArbiter.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextPrimary.h"

@interface NodeContextArbiter : NodeContextPrimary {
@private
  NSMutableArray *receivedPriorities;
}

@property (nonatomic, retain) NSMutableArray *receivedPriorities;

- (void) announceNewMaster;

@end
