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
#define kEmittingHostKey @"packet_emitting_host"

@implementation Packet

@synthesize identifier, content, emittingHost;

- (id) initWithIdentifier:(NSString *)_identifier content:(id) _content emittingHost:(NSString *)_emittingHost {
  if(self = [super init]) {
    NSAssert([_content respondsToSelector:@selector(encodeWithCoder:)], @"packet content object must implement the NSCoding protocol");
    NSAssert([_content respondsToSelector:@selector(initWithCoder:)], @"packet content object must implement the NSCoding protocol");
    self.identifier = _identifier;
    self.content = _content;
    self.emittingHost = _emittingHost;
  }
  return self;
}

+ (Packet *) packetWithIdentifier:(NSString *)_identifier content:(id)_content emittingHost:(NSString *)_emittingHost {
  return [[self alloc] initWithIdentifier:_identifier content:_content emittingHost:_emittingHost];
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
  [encoder encodeObject:self.identifier forKey:kIdKey];
  [encoder encodeObject:self.content forKey:kContentKey];
  [encoder encodeObject:self.emittingHost forKey:kEmittingHostKey];
}

- (id) initWithCoder:(NSCoder*)decoder {
  if (self = [super init]) {
    self.identifier = [decoder decodeObjectForKey:kIdKey];
    self.content = [decoder decodeObjectForKey:kContentKey];
    self.emittingHost = [decoder decodeObjectForKey:kEmittingHostKey];
  }
  return self;
}

#pragma mark - memory management
- (void) dealloc {
  [identifier release];
  [emittingHost release];
  [super dealloc];
}

@end
