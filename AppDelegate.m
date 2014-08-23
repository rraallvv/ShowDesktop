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
		
		NSWindow *fullScreenWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, frame.size.width, frame.size.height)
																 styleMask:NSBorderlessWindowMask
																   backing:NSBackingStoreBuffered
																	 defer:NO
																	screen:screen];
		
		NSView *fullScreenView = [[NSView alloc] initWithFrame:frame];
		[fullScreenWindow setContentView: fullScreenView];
		[fullScreenWindow makeKeyAndOrderFront:self];
	}
	
	// Insert code here to initialize your application
	//[window setStyleMask:NSUtilityWindowMask | NSNonactivatingPanelMask];
	[window setLevel:NSFloatingWindowLevel];
	[window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
	
	//[NSWorkspace.sharedWorkspace hideOtherApplications];
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
