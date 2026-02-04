//
//  main.m
//  SmallReSiever
//
//  RSS reader for GNUStep using SmallStep and libxml2.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "SmallStepCompat.h"
#import "AppDelegate.h"

int main(int argc, char **argv) {
    (void)argc;
    (void)argv;
    [NSApplication sharedApplication];
    AppDelegate *delegate = [[AppDelegate alloc] init];
    [SSHostApplication runWithDelegate:delegate];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [delegate release];
#endif
    return 0;
}
