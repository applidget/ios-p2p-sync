//
//  Packet.m
//  NodeSync
//
//  Created by Robin on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Packet.h"

#define kArchiveKey @"archive_key"
#define kIdKey @"packet_id_key"
#define kContentKey @"packet_content_key"

@implementation Packet

@synthesize packetId, packetContent;

- (id) initWithPacketId:(NSString *) _packetId andContent:(id) _packetContent {
  if(self = [super init]) {
    NSAssert([_packetContent respondsToSelector:@selector(encodeWithCoder:)], @"packet content object must implement the NSCoding protocol");
    NSAssert([_packetContent respondsToSelector:@selector(initWithCoder:)], @"packet content object must implement the NSCoding protocol");
    self.packetId = _packetId;
    self.packetContent = _packetContent;
  }
  return self;
}

+ (Packet *) packetWithId:(NSString *) packetId andContent:(id) content {
  return [[self alloc] initWithPacketId:packetId andContent:content];
}

+ (Packet *) packetFromData:(NSData *) data {
  @try {
    //Remove data separator
    NSMutableData *mutableData = [NSMutableData dataWithData:data];
    [mutableData setLength:(data.length - kPacketSeparator.length)];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:mutableData];
    Packet *packet = [[unarchiver decodeObjectForKey:kArchiveKey] retain];
    [unarchiver finishDecoding];
    [unarchiver release];
    return packet;
  }
  @catch (NSException *exception) {
    return nil;
  }
}

- (NSData *) convertToData {
  NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [archiver encodeObject:self forKey:kArchiveKey];
  [archiver finishEncoding];
  [archiver release];
  //Set the data separator
  [data appendData:kPacketSeparator];
  return data;
}

#pragma mark - NSCoding protocol
- (void) encodeWithCoder:(NSCoder*)encoder {
  [encoder encodeObject:self.packetId forKey:kIdKey];
  [encoder encodeObject:self.packetContent forKey:kContentKey];
}

- (id) initWithCoder:(NSCoder*)decoder {
  if (self = [super init]) {
    self.packetId = [decoder decodeObjectForKey:kIdKey];
    self.packetContent = [decoder decodeObjectForKey:kContentKey];
  }
  return self;
}

@end
