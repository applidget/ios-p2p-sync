//
//  NodeContext.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NodeSync.h"
#import "GCDAsyncSocket.h"
#import "NodeData.h"

#define DEFAULT_TIMEOUT 5

@interface NodeContext : NSObject <GCDAsyncSocketDelegate> {
@protected
  NodeSync *manager;
  GCDAsyncSocket *socket;
  
}

@property (nonatomic, assign) NodeSync *manager;
@property (nonatomic, retain) GCDAsyncSocket *socket;

- (id) initWithManager:(NodeSync *) _manager;
- (void) activate;
- (void) unactivate;
- (void) pushData:(NSData *) data;

@end
