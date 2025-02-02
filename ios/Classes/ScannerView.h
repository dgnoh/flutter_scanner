#import "IPDFCameraViewController.h"
#import <Flutter/Flutter.h>

@interface ScannerView : IPDFCameraViewController <IPDFCameraViewControllerDelegate>

//@property (nonatomic, copy) RCTBubblingEventBlock onPictureTaken;
//@property (nonatomic, copy) RCTBubblingEventBlock onRectangleDetect;
@property (nonatomic, assign) NSInteger detectionCountBeforeCapture;
@property (nonatomic, assign) NSInteger stableCounter;
@property (nonatomic, assign) double durationBetweenCaptures;
@property (nonatomic, assign) double lastCaptureTime;
@property (nonatomic, assign) float quality;
@property (nonatomic, assign) BOOL useBase64;
@property (nonatomic, assign) BOOL captureMultiple;
@property (nonatomic, assign) BOOL saveInAppDocument;
@property (nonatomic) BOOL autoCaptureEnabled;
@property (nonatomic, assign) FlutterMethodChannel* flutterChannel;

-(instancetype) init : (float)channelBrightness contrast: (float)channelContrast;

- (instancetype)initWithChannel : (FlutterMethodChannel*) channel;

//- (instancetype)initWithChannelAndArgs : (FlutterMethodChannel*) channel  brightness:(float)channelBrightness contrast: (float)channelContrast;

- (void) capture ;
- (void) onPictureTaken: (NSDictionary*) result;
- (void) onRectangleDetect:(BOOL)isDetected;
- (void)setAutoCaptureEnabled:(BOOL)enabled;

@end
