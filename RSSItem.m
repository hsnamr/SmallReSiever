//
//  RSSItem.m
//  SmallReSiever
//

#import "RSSItem.h"

@implementation RSSItem
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize title;
@synthesize link;
@synthesize itemDescription;
@synthesize content;
@synthesize author;
@synthesize date;
@synthesize identifier;
#endif

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [title release];
    [link release];
    [itemDescription release];
    [content release];
    [author release];
    [date release];
    [identifier release];
    [super dealloc];
}
#endif

@end
