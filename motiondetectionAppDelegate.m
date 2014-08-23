//
//  motiondetectionAppDelegate.m
//  motiondetection
//
//  Created by Michal Bugno on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "motiondetectionAppDelegate.h"

@implementation motiondetectionAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	//[window setStyleMask:NSUtilityWindowMask | NSNonactivatingPanelMask];
	[window setLevel:NSFloatingWindowLevel];
	[window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
	
	[NSWorkspace.sharedWorkspace hideOtherApplications];
	NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
	
	for (NSRunningApplication *app in apps) {
		if([app.bundleIdentifier.lowercaseString isEqualToString:@"com.apple.finder"]) {
			[app activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
		}
	}
	
	//[NSApp terminate:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

@end
