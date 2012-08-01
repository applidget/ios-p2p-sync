//
//  Packet.h
//  NodeSync
//
//  Created by Robin on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 Data used to separate packets. @warning: if you send data finishing or starting with the exact same data as the packet separator, their might a lost of data.
 You can change this separator to your convenience.
*/
#define kPacketSeparator [@"|||" dataUsingEncoding:NSUTF8StringEncoding]

/**
 Private channels, internally used by the library. Delegate shouldn't use it.
*/
#define kPrivateChannelPrefix @"_Private"
#define kPriorityChannel @"_Private_prio"
#define kClientChannel @"_Private_client"
#define kUpdateRequestChannel @"_Private_update"
#define kForceNewElectionChannel @"_Private_election"
#define kPasswordChannel @"_Private_pass"

/** Password correct packet content */
#define kPasswordSuccess @"pass-success"

@interface RSPacket : NSObject <NSCoding> {
@private
  NSString *_channel;
  id _content;
  NSString *_emittingHost;
}

///Name of the channel the packet is sent on
@property (nonatomic, retain) NSString *channel;    
///Content of the packet. This object must implement the NSCoding protocol
@property (nonatomic, retain) id content; 
///Ip address of the host sending this packet
@property (nonatomic, retain) NSString *emittingHost; 

/** Builds a new packet */
- (id) initWithContent:(id)packetContent onChannel:(NSString*)packetChannel emittingHost:(NSString *)packetEmittingHost;


/** Builds a new packet */
+ (RSPacket *) packetWithContent:(id)packetContent onChannel:(NSString*)packetChannel emittingHost:(NSString *)packetEmittingHost;

/** Extract packet from the given data */
+ (RSPacket *) packetFromData:(NSData *) data;

/** Convert packet into data */
- (NSData *) representingData;

@end
