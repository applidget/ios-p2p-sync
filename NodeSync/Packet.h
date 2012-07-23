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
#define kHeartBeatPacket @"heart_beat_packet"
#define kClientPacket @"client_packet"
#define kOplogPacket @"oplog_packet"

@interface Packet : NSObject <NSCoding> {
@private
  NSString *identifier;
  id<NSCoding> content;
  NSString *emittingHost;
}

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) id content;
@property (nonatomic, retain) NSString *emittingHost;

//Constructor
- (id) initWithIdentifier:(NSString *)_identifier content:(id) _content emittingHost:(NSString *)_emittingHost;

//Static initializer
+ (Packet *) packetWithIdentifier:(NSString *) _identifier content:(id) _content emittingHost:(NSString *)_emittingHost;
+ (Packet *) packetFromData:(NSData *) data;

- (NSData *) convertToData;

@end
