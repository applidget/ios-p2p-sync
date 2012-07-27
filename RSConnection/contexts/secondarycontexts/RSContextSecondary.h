//
//  NodeContextSecondary.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 A secondary context represents a context where a device is connected to a primary device. It looks for the appropriate
 Bonjour service and connect to it when found.
*/

#import "RSContext.h"

@interface RSContextSecondary : RSContext <NSNetServiceBrowserDelegate> {
@protected
  NSNetServiceBrowser *serviceBrowser;
  NSNetService *foundService;
  NSString *searchedServiceType;
}

@property (nonatomic, retain) NSNetServiceBrowser *serviceBrowser;
@property (nonatomic, retain) NSNetService *foundService;
@property (nonatomic, retain) NSString *searchedServiceType;

- (void) activateWithServiceType:(NSString *) type;

@end
