//
//  AppDelegate.h
//  SmallReSiever
//
//  RSS reader app delegate using SmallStep (GNUStep).
//

#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#endif

#import "SmallStepCompat.h"

@class RSSFeed;

@interface AppDelegate : NSObject <SSAppDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    NSWindow *window;
    NSTextField *urlField;
    NSButton *fetchButton;
    NSTableView *itemsTable;
    NSTextView *contentView;
    RSSFeed *currentFeed;
    NSArray *items;
}
@end
