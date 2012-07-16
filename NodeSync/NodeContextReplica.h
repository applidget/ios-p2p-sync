//
//  NodeContextReplica.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContext.h"

@interface NodeContextReplica : NodeContext <NSNetServiceDelegate, NSNetServiceBrowserDelegate> {
@private
  NSNetServiceBrowser *serviceBrowser;
  NSNetService *foundService;
  
}

@property (nonatomic, retain) NSNetServiceBrowser *serviceBrowser;
@property (nonatomic, retain) NSNetService *foundService;

@end
