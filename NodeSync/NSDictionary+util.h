//
//  NSDictionary+util.h
//  NodeSync
//
//  Created by Robin on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PRIO_PACKET_KEY @"prio_packet"
#define HEARTBEAT_PACKET_KEY @"heart_beat_packet"
#define CLIENT_PACKET_KEY @"client_packet"

#define DEFAULT_ARCHIVER_KEY @"default_key"

@interface NSDictionary (util)

+ (NSDictionary *) dictionaryWithPriorityPacket:(NSString *) priority;
+ (NSDictionary *) dictionaryWithHeartBeatPacket:(NSArray *) heartBeat;
+ (NSDictionary *) dictionaryWithClientPacket:(NSData *) data;
+ (NSDictionary *) dictionaryFromData:(NSData *) data;
- (NSData *) convertToData;
- (NSString *) packetKey;

@end
