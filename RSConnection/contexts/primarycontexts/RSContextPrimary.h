//
//  NodeContextPrimary.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 Primary contexts are used by master and arbiter. They publish a Bonjour service associated with a listening socket to allow secondary context
 to connect to it.
*/

#import "RSContext.h"

@interface RSContextPrimary : RSContext {
@protected
  NSMutableArray *connectedReplicas;
  NSMutableArray *waitingConnections;
  NSNetService *netService;
  BOOL delegateAlreadyAwareOfCurrentState;
}

///Array of socket allowed to send data
@property (nonatomic, retain) NSMutableArray *connectedReplicas;          
///Array of socket that are not yet allowed to send data (if usePasswordForConnection is set to YES)
@property (nonatomic, retain) NSMutableArray *waitingConnections;         
///The bonjour service
@property (nonatomic, retain) NSNetService *netService;                   
///A boolean used to controll that a state change is not send twice (when the app leaves background)
@property (nonatomic, assign) BOOL delegateAlreadyAwareOfCurrentState;    

/** Used by RSContextArbiter and RSContextMaster to activate */
- (void) activateWithServiceType:(NSString *)type andName:(NSString *) name;

/** The usePasswordForConnection is used, a secondary device gives the good password */
- (void) socketAnsweredPasswordSuccessfully:(GCDAsyncSocket *)sock;

@end
