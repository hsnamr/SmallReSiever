//
//  RSSFeed.h
//  SmallReSiever
//
//  RSS/Atom feed: title, link, and list of items.
//

#import <Foundation/Foundation.h>

@class RSSItem;

@interface RSSFeed : NSObject {
    NSString *title;
    NSString *feedURL;
    NSString *link;
    NSArray *items;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *feedURL;   // URL this feed was fetched from
@property (nonatomic, copy) NSString *link;  // HTML link from channel
@property (nonatomic, copy) NSArray *items;

@end
