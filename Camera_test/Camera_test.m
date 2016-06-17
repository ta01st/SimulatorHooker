#import "../ZKSwizzle.h"
#import "../Common.h"
#import <AVFoundation/AVCaptureSession.h>

@interface CAMCaptureEngine : NSObject
- (void)_handleSessionDidStartRunning:(id)arg1;
@end

@interface CAMViewfinderViewController : NSObject
@end

@interface CAMCaptureCapabilities : NSObject
@end

hook(AVCaptureSession)

// get rid of crashing at startup
- (BOOL)_buildAndRunGraph
{
	return YES;
}

@end

hook(CAMCaptureEngine)

- (id)initWithPowerController:(id)arg1
{
	self = ZKOrig(id, arg1);
	[(CAMCaptureEngine *)self _handleSessionDidStartRunning:nil];
	return self;
}

endhook

hook(CAMViewfinderViewController)

- (void)viewDidLoad
{
	ZKOrig(void);
}

endhook

hook(CAMCaptureCapabilities)

- (_Bool)isCameraSupportedForDevice:(NSInteger)device
{
	return YES;
}

- (_Bool)isFlashSupportedForDevice:(NSInteger)device
{
	return YES;
}

- (_Bool)isPanoramaSupportedForDevice:(NSInteger)device
{
	return YES;
}

endhook

__attribute__((constructor)) static void init()
{
	runIn(@"Camera");
}