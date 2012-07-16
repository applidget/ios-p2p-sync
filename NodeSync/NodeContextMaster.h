//
//  NodeContextMaster.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContext.h"

@interface NodeContextMaster : NodeContext <NSNetServiceDelegate> {
@private
  NSNetService *netService;
  
}

@property (nonatomic, retain) NSNetService *netService;

@end
