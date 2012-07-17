//
//  NodeContextMaster.m
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeContextMaster.h"

@implementation NodeContextMaster

- (void) sendHeartBeat {
  NSData *beat = [@"beat" dataUsingEncoding:NSUTF8StringEncoding];
  [self pushData:beat withTimeout:-1 tag:0];
}

- (void) activate {  
  [super activateWithServiceType:MASTER_SERVICE andName:@"master"];
  [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:YES];
}

@end
