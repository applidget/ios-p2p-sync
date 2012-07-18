//
//  NSDictionary+util.m
//  NodeSync
//
//  Created by Robin on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+util.h"

@implementation NSDictionary (util)

+ (NSDictionary *) dictionaryWithPriorityPacket:(NSString *) priority {
  return [NSDictionary dictionaryWithObject:priority forKey:PRIO_PACKET_KEY];
}

+ (NSDictionary *) dictionaryWithHeartBeatPacket:(NSArray *) heartBeat {
  return [NSDictionary dictionaryWithObject:heartBeat forKey:HEARTBEAT_PACKET_KEY];
}

+ (NSDictionary *) dictionaryWithClientPacket:(NSData *) data {
  return [NSDictionary dictionaryWithObject:data forKey:CLIENT_PACKET_KEY];
}


+ (NSDictionary *) dictionaryFromData:(NSData *) data {
  @try {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dictionary = [[unarchiver decodeObjectForKey:DEFAULT_ARCHIVER_KEY] retain];
    [unarchiver finishDecoding];
    [unarchiver release];
    return dictionary;
  }
  @catch (NSException *exception) {
    return nil;
  }
}

- (NSData *) convertToData {
  NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [archiver encodeObject:self forKey:DEFAULT_ARCHIVER_KEY];
  [archiver finishEncoding];
  [archiver release];
  return data;
}

- (NSString *) packetKey {
  NSAssert([self allKeys].count == 1, @"The dictionary is not a valid packet");
  return [[self allKeys] objectAtIndex:0];
}


@end
