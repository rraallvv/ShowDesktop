//
//  motiondetectionAppDelegate.m
//  motiondetection
//
//  Created by Michal Bugno on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation motiondetectionAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	for (NSScreen *screen in [NSScreen screens]) {
		NSRect frame = [screen frame];
		
		NSWindow *fullScreenWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 10, 10)
																 styleMask:NSBorderlessWindowMask
																   backing:NSBackingStoreBuffered
																	 defer:NO
																	screen:screen];
		
		NSView *fullScreenView = [[NSView alloc] initWithFrame:frame];
		[fullScreenWindow setContentView: fullScreenView];
		[fullScreenWindow makeKeyAndOrderFront:self];
	}
	
	NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
	
	for (NSRunningApplication *app in apps) {
		if([app.bundleIdentifier.lowercaseString isEqualToString:@"com.apple.finder"]) {
			[app activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
		} else {
			[app hide];
		}
	}
	
	[NSApp terminate:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

@end
