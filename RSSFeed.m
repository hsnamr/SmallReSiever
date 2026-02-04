//
//  RSSFeed.m
//  SmallReSiever
//

#import "RSSFeed.h"
#import "RSSItem.h"

@implementation RSSFeed
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize title;
@synthesize feedURL;
@synthesize link;
@synthesize items;
#endif

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [title release];
    [feedURL release];
    [link release];
    [items release];
    [super dealloc];
}
#endif

@end
