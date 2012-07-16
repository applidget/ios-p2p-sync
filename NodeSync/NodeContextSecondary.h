//
//  NodeContextSecondary.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContext.h"

@interface NodeContextSecondary : NodeContext <NSNetServiceBrowserDelegate> {
@protected
  NSNetServiceBrowser *serviceBriowser;
  NSNetService *foundService;
}

@property (nonatomic, retain) NSNetServiceBrowser *serviceBrowser;
@property (nonatomic, retain) NSNetService *foundService;

- (void) activateWithServiceType:(NSString *) type;

@end
