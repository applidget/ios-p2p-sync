//
//  Packet.m
//  NodeSync
//
//  Created by Robin on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSPacket.h"
#import "RSConnection.h"

#define kArchiveKey @"archive_key"
#define kChannelKey @"packet_channel_key"
#define kContentKey @"packet_content_key"
#define kEmittingHostKey @"packet_emitting_host"

@implementation RSPacket

@synthesize channel, content, emittingHost;

//Constructor
- (id) initWithContent:(id)packetContent onChannel:(NSString*)packetChannel emittingHost:(NSString *)packetEmittingHost {
  if(self = [super init]) {
    if(![packetContent conformsToProtocol:@protocol(NSCoding)]) {
      [NSException raise:kObjectNotConformToNSCodingProtocolException format:@"object send must implement the NSCoding protocol"];
    }
    self.channel = packetChannel;
    self.content = packetContent;
    self.emittingHost = packetEmittingHost;
  }
  return self;
}


//Static initializer
+ (RSPacket *) packetWithContent:(id)packetContent onChannel:(NSString*)packetChannel emittingHost:(NSString *)packetEmittingHost {
  return [[[self alloc] initWithContent:packetContent onChannel:packetChannel emittingHost:packetEmittingHost] autorelease];
}

+ (RSPacket *) packetFromData:(NSData *) data {
  //Remove data separator
  @try {
    NSMutableData *mutableData = [NSMutableData dataWithData:data];
    [mutableData setLength:(data.length - kPacketSeparator.length)];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:mutableData];
    RSPacket *packet = [[unarchiver decodeObjectForKey:kArchiveKey] retain];
    [unarchiver finishDecoding];
    [unarchiver release];
    return packet;
  }
  @catch (NSException *exception) {
    [NSException raise:kReceivedBadDataException format:@"Received a packet that can't be unarchived"];
  }
}

- (NSData *) representingData {
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
  [encoder encodeObject:self.channel forKey:kChannelKey];
  [encoder encodeObject:self.content forKey:kContentKey];
  [encoder encodeObject:self.emittingHost forKey:kEmittingHostKey];
}

- (id) initWithCoder:(NSCoder*)decoder {
  if (self = [super init]) {
    self.channel = [decoder decodeObjectForKey:kChannelKey];
    self.content = [decoder decodeObjectForKey:kContentKey];
    self.emittingHost = [decoder decodeObjectForKey:kEmittingHostKey];
  }
  return self;
}

#pragma mark - memory management
- (void) dealloc {
  [channel release];
  [emittingHost release];
  [super dealloc];
}

@end
