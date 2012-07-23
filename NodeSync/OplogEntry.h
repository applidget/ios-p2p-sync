//
//  OplogEntry.h
//  NodeSync
//
//  Created by Robin on 23/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Packet.h"

@interface OplogEntry : NSObject <NSCoding> {
@private
  Packet *packet;
  NSString *identifier;
  NSDate *operationTime;
}

@property (nonatomic, retain) Packet *packet;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSDate *operationTime;

- (id) initWithPacket:(Packet *)_packet;

+ (id) oplogEntryWithPacket:(Packet *)_packet;

@end
