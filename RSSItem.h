//
//  RSSItem.h
//  SmallReSiever
//
//  Single RSS/Atom entry (item or entry).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSSItem : NSObject {
    NSString *title;
    NSString *link;
    NSString *itemDescription;
    NSString *content;
    NSString *author;
    NSDate *date;
    NSString *identifier;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *itemDescription;  // description or summary
@property (nonatomic, copy) NSString *content;          // atom:content or encoded body
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *identifier;

@end
