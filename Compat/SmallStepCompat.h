//
//  SmallStepCompat.h
//  SmallReSiever
//
//  Minimal declarations for SmallStep APIs used by SmallReSiever,
//  to avoid requiring nullable/weak in the toolchain.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@protocol SSAppDelegate <NSObject>
@optional
- (void)applicationDidFinishLaunching;
- (void)applicationWillTerminate;
- (void)applicationWillFinishLaunching;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender;
@end

@interface SSMainMenuItem : NSObject {
    id target;
    NSString *title;
    SEL action;
    NSString *keyEquivalent;
    NSUInteger keyEquivalentModifierMask;
}
@property (nonatomic, assign) id target;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) SEL action;
@property (nonatomic, copy) NSString *keyEquivalent;
@property (nonatomic, assign) NSUInteger keyEquivalentModifierMask;
+ (instancetype)itemWithTitle:(NSString *)title action:(SEL)action keyEquivalent:(NSString *)keyEquiv modifierMask:(NSUInteger)mask target:(id)target;
@end

@interface SSMainMenu : NSObject {
    NSString *appName_;
}
@property (nonatomic, copy) NSString *appName;
- (void)buildMenuWithItems:(NSArray *)items quitTitle:(NSString *)quitTitle quitKeyEquivalent:(NSString *)quitKeyEquivalent;
- (void)install;
@end

@interface SSHostApplication : NSObject
+ (instancetype)sharedHostApplication;
+ (void)runWithDelegate:(id<SSAppDelegate>)delegate;
@end

@interface SSWindowStyle : NSObject
+ (NSUInteger)standardWindowMask;
@end

@interface SSConcurrency : NSObject
+ (void)performSelectorInBackground:(SEL)selector onTarget:(id)target withObject:(id)object;
+ (void)performSelectorOnMainThread:(SEL)selector onTarget:(id)target withObject:(id)object waitUntilDone:(BOOL)waitUntilDone;
@end
