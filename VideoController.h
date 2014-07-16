//
//  VideoController.h
//  motiondetection
//
//  Created by Michal Bugno on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

typedef struct { unsigned char r, g, b, a; } BPixel;

@interface VideoController : NSObject {
    QTCaptureSession *mCaptureSession;
    QTCaptureDeviceInput *mCaptureDeviceInput;
    IBOutlet QTCaptureView *mCaptureView;
	IBOutlet NSSlider *threshold;
	QTCaptureMovieFileOutput *mCaptureMovieFileOutput;
    QTCaptureVideoPreviewOutput *mCaptureOutput;
	BPixel *inputData, *outputData, *previousInputData;
	NSBitmapImageRep *inputBitmap, *outputBitmap;
    IBOutlet NSLevelIndicator *level;
	NSTimer *startTimer;
	NSTimer *minLengthTimer;
	NSTimer *maxLengthTimer;
	BOOL detection;
	IBOutlet NSTextField *countLabel;
	float detectedArea;
	float previousAverageMagnitud;
	NSUserDefaults *defaultSettings;
}

- (IBAction)start:(NSButton*)sender;
- (IBAction)threshold:(NSSlider*)sender;

@end
