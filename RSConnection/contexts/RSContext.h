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
#import "RSConnection.h"
#import "GCDAsyncSocket.h"
#import "RSPacket.h"

#define DEFAULT_TIMEOUT -1

@interface RSContext : NSObject <GCDAsyncSocketDelegate, NSNetServiceDelegate> {
@protected
  RSConnection *manager;
  GCDAsyncSocket *socket;
}

@property (nonatomic, assign) RSConnection *manager;
@property (nonatomic, retain) GCDAsyncSocket *socket;

- (id) initWithManager:(RSConnection *) contextManager;
- (void) activate;
- (void) unactivate;
- (void) writeData:(NSData *)data;

@end
