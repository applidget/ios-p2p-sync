//
//  NodeContextSecondary.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 A secondary context represents a context where a device is connected to a primary device. It looks for the appropriate
 Bonjour service and connect to it when if finds it.
*/

#import "RSContext.h"

@interface RSContextSecondary : RSContext <NSNetServiceBrowserDelegate> {
@protected
  NSNetServiceBrowser *serviceBrowser;
  NSNetService *foundService;
  NSString *searchedServiceType;
}

///Used to search for Bonjour services on the network
@property (nonatomic, retain) NSNetServiceBrowser *serviceBrowser;    
///Last service found by the serviceBrowser
@property (nonatomic, retain) NSNetService *foundService;             
///Type of the service searched (based on wether it's looking for master or arbiter service and also based on the replica set name)
@property (nonatomic, retain) NSString *searchedServiceType;          

/** Activate context by launching a search of service with type 'type' */
- (void) activateWithServiceType:(NSString *) type;

@end
