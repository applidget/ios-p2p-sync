//
//  NodeContext.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 "Abstract" class used to gather every possible contexts. Shouldn't be instanciated.
 Each context have a socket, and is linked to a manager, an instance of NodeSync which is manage the different
 context changes and which is used by a client.
*/

#import <Foundation/Foundation.h>
#import "NodeSync.h"
#import "GCDAsyncSocket.h"
#import "Packet.h"

#define DEFAULT_TIMEOUT -1

@interface NodeContext : NSObject <GCDAsyncSocketDelegate, NSNetServiceDelegate> {
@protected
  NodeSync *manager;
  GCDAsyncSocket *socket;
}

@property (nonatomic, assign) NodeSync *manager;
@property (nonatomic, retain) GCDAsyncSocket *socket;

- (id) initWithManager:(NodeSync *) _manager;
- (void) activate;
- (void) unactivate;
- (void) pushData:(NSData *)data withTimeout:(NSTimeInterval)interval;

@end
