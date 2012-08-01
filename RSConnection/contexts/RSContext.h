//
//  NodeContext.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 Abstract class that represents a RSContext.

*/

#import <Foundation/Foundation.h>
#import "RSConnection.h"
#import "GCDAsyncSocket.h"
#import "RSPacket.h"

/** Using negative timeout in GCDAsyncSocket will use no timeout */
#define DEFAULT_TIMEOUT -1

@interface RSContext : NSObject <GCDAsyncSocketDelegate, NSNetServiceDelegate> {
@protected
  RSConnection *_manager;
  GCDAsyncSocket *_socket;
}

///Context manager, RSConnection instance
@property (nonatomic, assign) RSConnection *manager;    
///Socket. Might be a listening socket if context is Primary
@property (nonatomic, retain) GCDAsyncSocket *socket;   

/** Initialize a context with the given manager */
- (id) initWithManager:(RSConnection *) contextManager;

/** Activate the context. Context will be "useless" before this method is performed */
- (void) activate;

/** Kill the context (close all the connection, and Bonjour services) */
- (void) unactivate;

/** Write data on the socket. If socket is a listening socket,  it will write data on each socket listening socket accepted */
- (void) writeData:(NSData *)data;

/** Called when the app enters background */
- (void) appDidEnterBackground;

/** Called when the app left background */
- (void) appLeftBackground;

@end
