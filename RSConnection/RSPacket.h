//
//  Packet.h
//  NodeSync
//
//  Created by Robin on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPacketSeparator [@"|||" dataUsingEncoding:NSUTF8StringEncoding]

#define kPriorityPacket @"prio_packet"
#define kClientPacket @"client_packet"
#define kUpdateRequestPacket @"update_request_packet"

@interface RSPacket : NSObject <NSCoding> {
@private
  NSString *channel;
  id<NSCoding> content;
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
