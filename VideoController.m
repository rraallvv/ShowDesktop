//
//  VideoController.m
//  motiondetection
//
//  Created by Michal Bugno on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VideoController.h"

#define kStartTime	60
#define kMinTime	5
#define kMaxTime	180

@implementation VideoController

- (void) awakeFromNib {
	
	mCaptureView.delegate = self;
	
	// Create a new Capture Session
    mCaptureSession = [[QTCaptureSession alloc] init];
    
    // Connect inputs and outputs to the session
    BOOL success = NO;
    NSError *error;
    
    // Find a video device
    QTCaptureDevice *device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
	
    if(device) {
		
        success = [device open:&error];
        if(!success) {
            // Handle Error!
        }
		
        // Add the video device to the session as device input
        mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];
        success = [mCaptureSession addInput:mCaptureDeviceInput error:&error];
        if(!success) {
            // Handle error
        }
		
		// Create the preview output and add it to the session
		mCaptureOutput = [[QTCaptureVideoPreviewOutput alloc] init];
		success = [mCaptureSession addOutput:mCaptureOutput error:&error];
		if (!success) {
			// Handle error
		}
		[mCaptureOutput setDelegate:self];
		
		// Create the movie file output and add it to the session
		mCaptureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
		success = [mCaptureSession addOutput:mCaptureMovieFileOutput error:&error];
		if (!success) {
			// Handle error
		}
		[mCaptureMovieFileOutput setDelegate:self];
		
		// Specify the compression options
		NSEnumerator *connectionEnumerator = [[mCaptureMovieFileOutput connections] objectEnumerator];
		QTCaptureConnection *connection;
		
		while ((connection = [connectionEnumerator nextObject])) {
			NSString *mediaType = [connection mediaType];
			QTCompressionOptions *compressionOptions = nil;
			if ([mediaType isEqualToString:QTMediaTypeVideo]) {
				compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptions240SizeH264Video"];
			} else if ([mediaType isEqualToString:QTMediaTypeSound]) {
				compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsHighQualityAACAudio"];
			}
			
			[mCaptureMovieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
			
			[mCaptureView setCaptureSession:mCaptureSession];
		}
		
		// Start the capture session runing
        [mCaptureSession startRunning];
    }
}

- (IBAction)start:(NSButton*)sender {
	detection = !detection;
	
    if (detection) {
		sender.title = @"Stop";
		
		countLabel.integerValue = kStartTime;
		
		// Create minLengthTimer to start detection
		dispatch_async(dispatch_get_main_queue(), ^{
			startTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
														  target:self
														selector:@selector(startTimerExpired:)
														userInfo:nil
														 repeats:YES];
		});
		
    } else {
		[startTimer invalidate];
		startTimer = nil;
		countLabel.stringValue = @"--";
		sender.title = @"Capture";
		
		[self stopDetection];
    }
}

- (void) minLengthTimerExpired:(NSTimer *)sender {
	[self stopDetection];
}

- (void) startDetection {
	NSLog(@"Recording");
	
	if (countLabel.isHidden) {
		countLabel.textColor = [NSColor blueColor];
		countLabel.hidden = NO;
		countLabel.integerValue = 0;
	}
	countLabel.integerValue++;
	
	NSString *filename = [NSString stringWithFormat: @"/Users/Shared/My Movie %ld.mov", (long)countLabel.integerValue];
	[mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:filename]];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		minLengthTimer = [NSTimer scheduledTimerWithTimeInterval:kMaxTime
														  target:self
														selector:@selector(maxLengthTimerExpired:)
														userInfo:nil
														 repeats:NO];
	});
}

- (void) stopDetection {
	if (minLengthTimer) {
		[minLengthTimer invalidate];
		minLengthTimer = nil;
	}
	if (maxLengthTimer) {
		[maxLengthTimer invalidate];
		maxLengthTimer = nil;
	}
	if (mCaptureMovieFileOutput.outputFileURL) {
		NSLog(@"Saving File");
		[mCaptureMovieFileOutput recordToOutputFileURL:nil];
	}
}

- (void) startTimerExpired:(NSTimer *)sender {
	countLabel.integerValue--;
	if (countLabel.integerValue == 0) {
		[startTimer invalidate];
		startTimer = nil;
		countLabel.hidden = YES;
	}
}

- (void) maxLengthTimerExpired:(NSTimer*)sender {
	[self stopDetection];
}

- (void)calculateDifferenceBetween:(uint8_t *)image1 and:(uint8_t *)image2 {
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
    [[NSWorkspace sharedWorkspace] openURL:outputFileURL];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [mCaptureSession stopRunning];
    [[mCaptureDeviceInput device] close];
}

- (void)dealloc
{
    [mCaptureSession release];
    [mCaptureDeviceInput release];
    [mCaptureMovieFileOutput release];
	
    [super dealloc];
}

- (CIImage *)view:(QTCaptureView *)view willDisplayImage:(CIImage *)image
{
	CIImage *grayscaleImage = [[CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:
								kCIInputImageKey, image,
								kCIInputIntensityKey, @1.0,
								kCIInputColorKey, [CIColor colorWithRed:1 green:1 blue:1], nil]
							   valueForKey:kCIOutputImageKey];
	
	CIImage *bluredImage = [[CIFilter filterWithName: @"CIGaussianBlur" keysAndValues:
							 kCIInputImageKey, grayscaleImage,
							 kCIInputRadiusKey, @1.0, nil]
							valueForKey: kCIOutputImageKey];
	
	
	CGSize size = image.extent.size;
	
	int width, height;
	
	width = size.width;
	height = size.height;
	
	int rowBytes = (width * 4);
	
	if (!inputBitmap) {
		inputBitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
															  pixelsWide:width
															  pixelsHigh:height
														   bitsPerSample:8
														 samplesPerPixel:4
																hasAlpha:YES
																isPlanar:NO
														  colorSpaceName:NSCalibratedRGBColorSpace
															bitmapFormat:0
															 bytesPerRow:0
															bitsPerPixel:0];
		
		inputData = (BPixel *)inputBitmap.bitmapData;
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName ( kCGColorSpaceGenericRGB );
	CGContextRef context = CGBitmapContextCreate( [inputBitmap bitmapData], width, height, 8, rowBytes, colorSpace, kCGImageAlphaPremultipliedLast );
	
	CIContext* ciContext = [CIContext contextWithCGContext:context options:nil];
	[ciContext drawImage:bluredImage atPoint:CGPointZero fromRect: [image extent]];
	
	CGContextRelease( context );
	CGColorSpaceRelease( colorSpace );
	
	
	int xPoint, yPoint;
	
	if (!outputBitmap) {
		outputBitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
															   pixelsWide:width
															   pixelsHigh:height
															bitsPerSample:8
														  samplesPerPixel:4
																 hasAlpha:YES
																 isPlanar:NO
														   colorSpaceName:NSCalibratedRGBColorSpace
															 bitmapFormat:0
															  bytesPerRow:0
															 bitsPerPixel:0];
		outputData = (BPixel *)outputBitmap.bitmapData;
	}
	
	if (previousInputData)
	{
		unsigned char r, g, b;
		unsigned char r1, g1, b1;
		unsigned char r2, g2, b2;
		
		float magnitud;
		
		int index;
		
		const float f = 1/255.0;
		
		detectedArea = 0;
		
		for (xPoint = 0; xPoint < width; ++xPoint) {
			for (yPoint = 0; yPoint < height; ++yPoint) {
				index = width * yPoint + xPoint;
				
				r1 = inputData[index].r;
				g1 = inputData[index].g;
				b1 = inputData[index].b;
				
				r2 = previousInputData[index].r;
				g2 = previousInputData[index].g;
				b2 = previousInputData[index].b;
				
				r = outputData[index].r;
				g = outputData[index].g;
				b = outputData[index].b;
				
				r = 0.1 * (r + r1 - r2);
				g = 0.1 * (g + g1 - g2);
				b = 0.1 * (b + b1 - b2);
				
				magnitud = sqrtf(r * r + g * g + b * b) * f;
				
				outputData[index].r = r;
				outputData[index].g = g;
				outputData[index].b = b;
				outputData[index].a = magnitud * 255;
				
				
				detectedArea += magnitud;
				
				previousInputData[index].r = inputData[index].r;
				previousInputData[index].g = inputData[index].g;
				previousInputData[index].b = inputData[index].b;
				previousInputData[index].a = inputData[index].a;
			}
		}
		
		detectedArea = detectedArea / (0.025 * width * height);
		
	} else {
		previousInputData = malloc(rowBytes * height);
	}
	
	
	
	
	
	
	
	
	[level setFloatValue:100 * detectedArea];
	
	if (detection && !startTimer && (level.floatValue > threshold.floatValue)) {
		
		if (minLengthTimer) {
			[minLengthTimer invalidate];
		} else {
			[self startDetection];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			minLengthTimer = [NSTimer scheduledTimerWithTimeInterval:kMinTime
															  target:self
															selector:@selector(minLengthTimerExpired:)
															userInfo:nil
															 repeats:NO];
		});
	}
	
	CIImage *detectedAreas = [[[CIImage alloc] initWithBitmapImageRep:outputBitmap] autorelease];
	
	CIImage *outputImage = [[CIFilter filterWithName:@"CISourceOverCompositing" keysAndValues:
							 kCIInputBackgroundImageKey, image,
							 kCIInputImageKey, detectedAreas, nil]
							valueForKey:kCIOutputImageKey];
	
	return outputImage;
}

@end
