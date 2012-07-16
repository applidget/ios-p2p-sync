//
//  NodeContextMaster.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextMaster.h"

@implementation NodeContextMaster

- (void) activate {  
  [super activateWithServiceType:MASTER_SERVICE andName:@"master"];
}

@end
