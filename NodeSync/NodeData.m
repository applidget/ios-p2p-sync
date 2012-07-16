//
//  PeerData.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeData.h"

@implementation NodeData

@synthesize identifier, contextType, connectionTime;

- (id) initWithIdentifier:(NSString *)_identifier contextType:(kContextType) _contextType {
  if(self = [super init]) {
    self.identifier = _identifier;
    self.contextType = _contextType;
    self.connectionTime = [NSDate date];
  }
  return self;
}

#pragma mark - memory management
- (void) dealloc {
  [identifier release];
  [connectionTime release];
  [super dealloc];
}

@end
