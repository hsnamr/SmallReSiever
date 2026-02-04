//
//  SmallStepCompat.m
//  SmallReSiever
//
//  Minimal SmallStep-compatible implementations for GNUStep when SmallStep
//  is not built/installed (same API as SmallStep).
//

#import "SmallStepCompat.h"
#import <AppKit/AppKit.h>

#pragma mark - SSHostApplicationAdapter

@interface SSHostApplicationAdapter : NSObject <NSApplicationDelegate> {
@public
    id<SSAppDelegate> appDelegate;
}
@end

@implementation SSHostApplicationAdapter

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    (void)notification;
    if ([appDelegate respondsToSelector:@selector(applicationWillFinishLaunching)]) {
        [appDelegate applicationWillFinishLaunching];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    (void)notification;
    if ([appDelegate respondsToSelector:@selector(applicationDidFinishLaunching)]) {
        [appDelegate applicationDidFinishLaunching];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    (void)notification;
    if ([appDelegate respondsToSelector:@selector(applicationWillTerminate)]) {
        [appDelegate applicationWillTerminate];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender {
    (void)sender;
    if ([appDelegate respondsToSelector:@selector(applicationShouldTerminateAfterLastWindowClosed:)]) {
        return [appDelegate applicationShouldTerminateAfterLastWindowClosed:sender];
    }
    return YES;
}

@end

#pragma mark - SSHostApplication

static id<SSAppDelegate> g_appDelegate = nil;

@implementation SSHostApplication

+ (instancetype)sharedHostApplication {
    static SSHostApplication *shared = nil;
    if (shared == nil) {
        shared = [[self alloc] init];
    }
    return shared;
}

+ (void)setAppDelegate:(id<SSAppDelegate>)delegate {
    g_appDelegate = delegate;
}

+ (void)runWithDelegate:(id<SSAppDelegate>)delegate {
    g_appDelegate = delegate;

    NSApplication *app = [NSApplication sharedApplication];
    static SSHostApplicationAdapter *adapter = nil;
    if (adapter == nil) {
        adapter = [[SSHostApplicationAdapter alloc] init];
    }
    adapter->appDelegate = delegate;  /* public ivar */
    [app setDelegate:adapter];
    [app run];
}

@end

#pragma mark - SSMainMenuItem

@implementation SSMainMenuItem
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize target;
@synthesize title;
@synthesize action;
@synthesize keyEquivalent;
@synthesize keyEquivalentModifierMask;
#endif

+ (instancetype)itemWithTitle:(NSString *)aTitle action:(SEL)anAction keyEquivalent:(NSString *)keyEquiv modifierMask:(NSUInteger)mask target:(id)aTarget {
    SSMainMenuItem *item = [[self alloc] init];
    [item setTitle:[aTitle copy]];
    [item setAction:anAction];
    [item setKeyEquivalent:keyEquiv ? [keyEquiv copy] : @""];
    [item setKeyEquivalentModifierMask:mask];
    [item setTarget:aTarget];
    return [item autorelease];
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [title release];
    [keyEquivalent release];
    [super dealloc];
}
#endif

@end

#pragma mark - SSMainMenu

@implementation SSMainMenu
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize appName = appName_;
#endif

- (void)buildMenuWithItems:(NSArray *)menuItems quitTitle:(NSString *)quitTitle quitKeyEquivalent:(NSString *)quitKeyEquivalent {
    NSString *name = (appName_ && [appName_ length]) ? appName_ : @"App";
    NSMenu *mainMenu = [[NSMenu alloc] init];
    NSMenuItem *appItem = [[NSMenuItem alloc] init];
    [appItem setTitle:name];
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:name];

    NSEnumerator *e = [menuItems objectEnumerator];
    SSMainMenuItem *desc;
    while ((desc = [e nextObject]) != nil) {
        NSMenuItem *mi = [[NSMenuItem alloc] initWithTitle:[desc title]
                                                     action:[desc action]
                                              keyEquivalent:[desc keyEquivalent] ? [desc keyEquivalent] : @""];
        [mi setKeyEquivalentModifierMask:[desc keyEquivalentModifierMask]];
        [mi setTarget:[desc target] ? [desc target] : self];
        [appMenu addItem:mi];
        [mi release];
    }

    [appMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:quitTitle
                                                     action:@selector(terminate:)
                                              keyEquivalent:quitKeyEquivalent ? quitKeyEquivalent : @"q"];
    [quitItem setTarget:NSApp];
    [appMenu addItem:quitItem];
    [quitItem release];

    [appItem setSubmenu:appMenu];
    [appMenu release];
    [mainMenu addItem:appItem];
    [appItem release];

    [NSApp setMainMenu:mainMenu];
    [mainMenu release];
}

- (void)install {
}

@end

#pragma mark - SSWindowStyle

@implementation SSWindowStyle

+ (NSUInteger)standardWindowMask {
    return NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
}

@end

#pragma mark - SSConcurrency

@implementation SSConcurrency

+ (void)performSelectorInBackground:(SEL)selector onTarget:(id)target withObject:(id)object {
    if (!target || !selector) return;
    [target performSelectorInBackground:selector withObject:object];
}

+ (void)performSelectorOnMainThread:(SEL)selector onTarget:(id)target withObject:(id)object waitUntilDone:(BOOL)waitUntilDone {
    if (!target || !selector) return;
    [target performSelectorOnMainThread:selector withObject:object waitUntilDone:waitUntilDone];
}

@end
