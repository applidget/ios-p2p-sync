//
//  OplogEntry.m
//  NodeSync
//
//  Created by Robin on 23/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OplogEntry.h"
#import "NSString+Utils.h"

#define kPacketKey @"packet_key"
#define kIdentifierKey @"identifier_key"
#define kOperationTimeKey @"operation_time_key"

@implementation OplogEntry

@synthesize packet, identifier, operationTime;

- (id) initWithPacket:(Packet *)_packet {
  if(self = [super init]) {
    self.packet = _packet;
    self.identifier = [NSString stringWithGeneratedUid];
    self.operationTime = [NSDate date];
  }
  return self;
}

+ (id) oplogEntryWithPacket:(Packet *)_packet {
  return [[self alloc] initWithPacket:_packet];
}

#pragma mark - NSCoding protocol
- (void) encodeWithCoder:(NSCoder*)encoder {
  [encoder encodeObject:self.packet forKey:kPacketKey];
  [encoder encodeObject:self.identifier forKey:kIdentifierKey];
  [encoder encodeObject:self.operationTime forKey:kOperationTimeKey];
}

- (id) initWithCoder:(NSCoder*)decoder {
  if (self = [super init]) {
    self.packet = [decoder decodeObjectForKey:kPacketKey];
    self.identifier = [decoder decodeObjectForKey:kIdentifierKey];
    self.operationTime = [decoder decodeObjectForKey:kOperationTimeKey];
  }
  return self;
}

#pragma mark - memory management
- (void) dealloc {
  [packet release];
  [operationTime release];
  [identifier release];
  [super dealloc];
}

@end
