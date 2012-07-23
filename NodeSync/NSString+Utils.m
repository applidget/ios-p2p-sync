//
//  NSString+Utils.m
//  NodeSync
//
//  Created by Robin on 23/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

#define ASCII_GLOBAL_OFFSET 48
#define ASCII_UPPERCASE_OFFSET 65
#define ASCII_LOWERCASE_OFFSET 97
#define NUMBER_OF_INT 10
#define NUMBER_OF_LETTER 26
#define GUEST_CATEGORY_SECTION 0
#define NUMBER_OF_TABEL_VIEW_SECTION 2

static char getRandomChar() {
	int random = arc4random() % (2 * NUMBER_OF_LETTER + NUMBER_OF_INT);
	char res;
	if (random < NUMBER_OF_INT)
	{
		res = random + ASCII_GLOBAL_OFFSET;
	} else if (random - NUMBER_OF_INT < NUMBER_OF_LETTER ) {
		res = random - NUMBER_OF_INT + ASCII_UPPERCASE_OFFSET ;
	} else {
		res = random - NUMBER_OF_INT - NUMBER_OF_LETTER + ASCII_LOWERCASE_OFFSET;
	}
	return res;
} 

+ (NSString *) stringWithGeneratedUid {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSString *newUid = @"";
  for (int i = 0; i < 10; ++i) {
    char randChar = getRandomChar();
    newUid = [newUid stringByAppendingString: [NSString stringWithFormat:@"%c", randChar]];
  }
  NSString *res = [[NSString alloc] initWithString:newUid];
  [pool release];
  return [res autorelease];
}

@end
