//
//  NodeContextPrimary.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
