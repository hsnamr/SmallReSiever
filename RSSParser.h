//
//  RSSParser.h
//  SmallReSiever
//
//  Parse RSS 2.0 and Atom 1.0 using libxml2 (FOSS).
//

#import <Foundation/Foundation.h>

@class RSSFeed;

@interface RSSParser : NSObject

/// Parse XML data (RSS 2.0 or Atom 1.0) into an RSSFeed. Returns nil on error.
+ (RSSFeed *)feedFromData:(NSData *)data feedURL:(NSString *)feedURL;

@end
