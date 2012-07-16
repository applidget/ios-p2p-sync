//
//  PeerData.h
//  NodeSync
//
//  Created by Robin on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NodeSync.h"

@interface NodeData : NSObject {
@private
  NSString *identifier;
  kContextType contextType;
  NSDate *connectionTime;
  
}

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, assign) kContextType contextType;
@property (nonatomic, retain) NSDate *connectionTime;

- (id) initWithIdentifier:(NSString *)_identifier contextType:(kContextType) _contextType;

@end
