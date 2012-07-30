//
//  NodeContextElector.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSContextElector.h"
#import "RSContextReplica.h"
#import "RSContextMaster.h"

#define ELECTOR_TIMEOUT 20

@interface RSContextElector()

///Result of the election
@property (nonatomic, assign) kElectionResult electionResult;   
///If no result within 30 seconds, the elector becomes replica
@property (nonatomic, retain) NSTimer *timeOutTimer;            
///Priority of self for the election
@property (nonatomic, assign) NSInteger priorityForElection;    

@end

@implementation RSContextElector

@synthesize electionResult, timeOutTimer, priorityForElection;

- (void) electorContextTimedOut {
  //Manage the case where the network was shut down for a sec but the master didn't crash
  [self.manager changeContextWithNewContextType:kContextTypeReplica];
}

- (void) activate {
  [super activateWithServiceType:[NSString stringWithFormat:@"%@%@", self.manager.replicaSetName, ARBITER_SERVICE]];
  self.electionResult = kElectionResultUnknown;
  self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:ELECTOR_TIMEOUT target:self selector:@selector(electorContextTimedOut) userInfo:nil repeats:NO];
}

#pragma mark - NSNetServiceBrowserDelegate
- (void) netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser {
  [self.manager didUpdateStateInto:kConnectionStateElectorSearching];
}

#pragma mark - GCDAsyncSocketDelegate protocol
- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {

  [self.socket setDelegate:nil delegateQueue:NULL];
  kContextType newContextType;
  switch (self.electionResult) {
    case kElectionResultWon:
      newContextType = kContextTypeMaster;
      break;
    case kElectionResultLost:
      newContextType = kContextTypeReplica;
      break;
    case kElectionResultUnknown:
      newContextType = kContextTypeArbiter; //disconnected without result, arbiter crashed, need a new election
      break;
    default:
      break;
  }
  self.manager.nbConnections --;
  [self.manager changeContextWithNewContextType:newContextType];
}

- (void) sendPriorityPacket {
  RSPacket *prioPacket = [RSPacket packetWithContent:[NSString stringWithFormat:@"%i", priorityForElection]
                                           onChannel:kPriorityChannel
                                        emittingHost:self.socket.localHost];
  
  [self writeData:[prioPacket representingData]];
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
  [super socket:sock didConnectToHost:host port:port];
  [self.timeOutTimer invalidate];
  if(!self.manager.usePasswordForConnection) {
    [self.manager didUpdateStateInto:kConnectionStateElectorConnected];
  }
  
  self.priorityForElection = [self.manager getPriorityOfElector];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  
  RSPacket *receivedPacket = [RSPacket packetFromData:data];
  
  if([receivedPacket.channel isEqualToString:kPriorityChannel]) {
    NSString *strPriority = receivedPacket.content;
    NSInteger priority = [strPriority intValue];
    if (priority == priorityForElection) {
      self.electionResult = kElectionResultWon;
    }
    else {
      self.electionResult = kElectionResultLost;
    }
  }
  else if([receivedPacket.channel isEqualToString:kPasswordChannel]) {
    //check success
    if([receivedPacket.content isEqualToString:kPasswordSuccess]) {
      [self.manager didUpdateStateInto:kConnectionStateElectorConnected];
    }
  }
  else {
    [NSException raise:kUnknownPacketException format:@"Elector received a packet from an unknown channel %@", receivedPacket.channel];
  }
  [sock readDataToData:kPacketSeparator withTimeout:DEFAULT_TIMEOUT tag:0];
}

#pragma mark -memory management
- (void) dealloc {
  [timeOutTimer release];
  [super dealloc];
}

@end
