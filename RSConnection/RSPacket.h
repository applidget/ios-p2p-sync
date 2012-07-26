//
//  Packet.h
//  NodeSync
//
//  Created by Robin on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPacketSeparator [@"|||" dataUsingEncoding:NSUTF8StringEncoding]

#define kPrivateChannelPrefix @"_Private"
#define kPriorityChannel @"_Private_prio"
#define kClientChannel @"_Private_client"
#define kUpdateRequestChannel @"_Private_update"
#define kForceNewElectionChannel @"_Private_election"

@interface RSPacket : NSObject <NSCoding> {
@private
  NSString *channel;
  id content;
  NSString *emittingHost;
}

@property (nonatomic, retain) NSString *channel;
@property (nonatomic, retain) id content;
@property (nonatomic, retain) NSString *emittingHost;

//Constructor
- (id) initWithContent:(id)packetContent onChannel:(NSString*)packetChannel emittingHost:(NSString *)packetEmittingHost;


//Static initializer
+ (RSPacket *) packetWithContent:(id)packetContent onChannel:(NSString*)packetChannel emittingHost:(NSString *)packetEmittingHost;
+ (RSPacket *) packetFromData:(NSData *) data;

- (NSData *) representingData;

@end
