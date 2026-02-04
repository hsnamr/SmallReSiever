//
//  AppDelegate.m
//  SmallReSiever
//
//  RSS reader UI and lifecycle using SmallStep (GNUStep).
//

#import "AppDelegate.h"
#import "RSSFeed.h"
#import "RSSItem.h"
#import "RSSParser.h"

@implementation AppDelegate

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [window release];
    [urlField release];
    [fetchButton release];
    [itemsTable release];
    [contentView release];
    [currentFeed release];
    [items release];
    [super dealloc];
}
#endif

- (void)applicationWillFinishLaunching {
    [self buildMenu];
    [self buildWindow];
}

- (void)applicationDidFinishLaunching {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender {
    (void)sender;
    return YES;
}

- (void)buildMenu {
    SSMainMenu *menu = [[SSMainMenu alloc] init];
    [menu setAppName:@"SmallReSiever"];
    NSArray *menuItems = [NSArray arrayWithObjects:
        [SSMainMenuItem itemWithTitle:@"Add Feed…" action:@selector(addFeed:) keyEquivalent:@"o" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Refresh" action:@selector(refreshFeed:) keyEquivalent:@"r" modifierMask:NSCommandKeyMask target:self],
        nil];
    [menu buildMenuWithItems:menuItems quitTitle:@"Quit SmallReSiever" quitKeyEquivalent:@"q"];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [menu release];
#endif
}

- (void)buildWindow {
    NSUInteger style = [SSWindowStyle standardWindowMask];
    NSRect frame = NSMakeRect(100, 100, 700, 500);
    window = [[NSWindow alloc] initWithContentRect:frame
                                          styleMask:style
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
    [window setTitle:@"SmallReSiever"];
    [window setReleasedWhenClosed:NO];

    NSView *content = [window contentView];
    CGFloat margin = 12;
    CGFloat y = frame.size.height - margin;

    // URL field and Fetch button
    urlField = [[NSTextField alloc] initWithFrame:NSMakeRect(margin, y - 28, 400, 22)];
    [urlField setPlaceholderString:@"Feed URL (e.g. https://example.com/feed.xml)"];
    [urlField setAutoresizingMask:NSViewMinYMargin];
    [content addSubview:urlField];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [urlField release];
#endif

    fetchButton = [[NSButton alloc] initWithFrame:NSMakeRect(420, y - 28, 80, 22)];
    [fetchButton setTitle:@"Fetch"];
    [fetchButton setTarget:self];
    [fetchButton setAction:@selector(fetchFeed:)];
    [fetchButton setAutoresizingMask:NSViewMinYMargin];
    [content addSubview:fetchButton];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [fetchButton release];
#endif

    y -= 40;

    // Items table (left) and content (right)
    NSScrollView *tableScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(margin, margin, 220, y - margin)];
    [tableScroll setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [tableScroll setHasVerticalScroller:YES];
    [tableScroll setBorderType:NSBezelBorder];

    NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:@"title"];
    [col setTitle:@"Items"];
    [col setWidth:200];

    itemsTable = [[NSTableView alloc] initWithFrame:NSZeroRect];
    [itemsTable addTableColumn:col];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [col release];
#endif
    [itemsTable setHeaderView:nil];
    [itemsTable setDataSource:self];
    [itemsTable setDelegate:self];
    [itemsTable setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [tableScroll setDocumentView:itemsTable];
    [content addSubview:tableScroll];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [itemsTable release];
    [tableScroll release];
#endif

    NSScrollView *textScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(240, margin, frame.size.width - 240 - margin, y - margin)];
    [textScroll setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [textScroll setHasVerticalScroller:YES];
    [textScroll setBorderType:NSBezelBorder];

    contentView = [[NSTextView alloc] initWithFrame:NSZeroRect];
    [contentView setEditable:NO];
    [contentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [textScroll setDocumentView:contentView];
    [content addSubview:textScroll];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [contentView release];
    [textScroll release];
#endif

    items = [NSArray array];
}

- (void)addFeed:(id)sender {
    (void)sender;
    [window makeFirstResponder:urlField];
}

- (void)refreshFeed:(id)sender {
    (void)sender;
    [self fetchFeed:fetchButton];
}

- (void)fetchFeed:(id)sender {
    (void)sender;
    NSString *urlString = [urlField stringValue];
    urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (urlString.length == 0) return;

    [fetchButton setEnabled:NO];
    [SSConcurrency performSelectorInBackground:@selector(loadFeedFromURLString:) onTarget:self withObject:urlString];
}

- (void)loadFeedFromURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url || (![[url scheme] isEqualToString:@"http"] && ![[url scheme] isEqualToString:@"https"])) {
        [SSConcurrency performSelectorOnMainThread:@selector(feedLoadFailedWithError:)
                                         onTarget:self
                                       withObject:@"Invalid URL"
                                    waitUntilDone:NO];
        return;
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if (error) {
        [SSConcurrency performSelectorOnMainThread:@selector(feedLoadFailedWithError:)
                                         onTarget:self
                                       withObject:[error localizedDescription]
                                    waitUntilDone:NO];
        return;
    }
    if (!data || [data length] == 0) {
        [SSConcurrency performSelectorOnMainThread:@selector(feedLoadFailedWithError:)
                                         onTarget:self
                                       withObject:@"Empty response"
                                    waitUntilDone:NO];
        return;
    }

    RSSFeed *feed = [RSSParser feedFromData:data feedURL:urlString];
    if (!feed) {
        [SSConcurrency performSelectorOnMainThread:@selector(feedLoadFailedWithError:)
                                         onTarget:self
                                       withObject:@"Parse error (not RSS/Atom?)"
                                    waitUntilDone:NO];
        return;
    }

    [SSConcurrency performSelectorOnMainThread:@selector(didLoadFeed:)
                                     onTarget:self
                                   withObject:feed
                                waitUntilDone:NO];
}

- (void)feedLoadFailedWithError:(NSString *)message {
    [fetchButton setEnabled:YES];
    currentFeed = nil;
    items = [NSArray array];
    [itemsTable reloadData];
    [contentView setString:[NSString stringWithFormat:@"Error: %@", message]];
}

- (void)didLoadFeed:(RSSFeed *)feed {
    [fetchButton setEnabled:YES];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [currentFeed release];
    currentFeed = [feed retain];
#else
    currentFeed = feed;
#endif
    items = [feed items] ? [feed items] : [NSArray array];
    [window setTitle:[NSString stringWithFormat:@"SmallReSiever – %@", [feed title]]];
    [itemsTable reloadData];
    [contentView setString:@""];
    if ([items count] > 0) {
        [itemsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        [self tableViewSelectionDidChange:[NSNotification notificationWithName:NSTableViewSelectionDidChangeNotification object:itemsTable]];
        [itemsTable scrollRowToVisible:0];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    (void)tableView;
    return (NSInteger)[items count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    (void)tableColumn;
    if (row < 0 || (NSUInteger)row >= [items count]) return @"";
    RSSItem *item = [items objectAtIndex:(NSUInteger)row];
    NSString *title = [item title];
    return title.length ? title : @"(no title)";
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tv = [notification object];
    NSInteger row = [tv selectedRow];
    if (row < 0 || (NSUInteger)row >= [items count]) {
        [contentView setString:@""];
        return;
    }
    RSSItem *item = [items objectAtIndex:(NSUInteger)row];
    NSMutableString *text = [NSMutableString string];
    if ([item title].length) [text appendFormat:@"%@\n\n", [item title]];
    if ([item link].length) [text appendFormat:@"Link: %@\n\n", [item link]];
    if ([item date]) {
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateStyle:NSDateFormatterMediumStyle];
        [f setTimeStyle:NSDateFormatterShortStyle];
        [text appendFormat:@"%@\n\n", [f stringFromDate:[item date]]];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [f release];
#endif
    }
    NSString *body = [item content].length ? [item content] : [item itemDescription];
    if (body.length) [text appendString:body];
    [contentView setString:text];
    if ([contentView respondsToSelector:@selector(scrollToBeginningOfDocument:)])
        [contentView scrollToBeginningOfDocument:nil];
    else
        [contentView scrollPoint:NSMakePoint(0, 0)];
}

@end
