#import "ScannerView.h"
#import "IPDFCameraViewController.h"

@implementation ScannerView
{
  BOOL _autoCaptureEnabled;
}
- (instancetype)init{
  self = [super init];

  self.detectionRefreshRateInMS = 50;
  self.overlayColor = [UIColor colorWithRed: 1.00 green: 0.00 blue: 0.00 alpha: 0.50];
  self.enableTorch = false;
  self.useFrontCam = false;
  self.useBase64 = false;
  self.saveInAppDocument = true;
  self.captureMultiple = false;
  self.detectionCountBeforeCapture = 8;
  self.detectionRefreshRateInMS = 50;
  self.saturation = 1;
  self.quality = 1;
//        self.brightness = channelBrightness;
//        self.contrast = channelContrast;
  self.brightness = 0.2;
  self.contrast = 1.4;
  self.durationBetweenCaptures = 0;


  if (self) {
    _autoCaptureEnabled = true;
    [self setEnableBorderDetection:YES];
    [self setDelegate: self];
  }

  return self;
}

-(instancetype) initWithChannel:(FlutterMethodChannel *)channel {
  ScannerView* instance = [ScannerView new];
  instance.flutterChannel = channel;


  return instance;
}


-(void) onPictureTaken {
  printf("on picture taken");
}

-(void) onRectangleDetect:(BOOL)isDetected {
  // Flutter에 isDetected 값을 전달
  dispatch_async(dispatch_get_main_queue(), ^{
      printf("calling flutter onRectangleDetected");
      [self->_flutterChannel invokeMethod:@"onRectangleDetected" arguments:@{@"isDetected": @(isDetected)}];
  });
}

//- (void)setChannelBrightness:(float)brightness {
//    self.brightness = brightness;
//}
//
//- (void)setChannelContrast:(float)contrast {
//    self.contrast = contrast;
//}


- (void) didDetectRectangle:(CIRectangleFeature *)rectangle withType:(IPDFRectangeType)type {
  if (!_autoCaptureEnabled) {
    return;
  }
  switch (type) {
    case IPDFRectangeTypeGood:
      self.stableCounter ++;
          break;
    default:
      self.stableCounter = 0;
          break;
  }

//    if (self.onRectangleDetect) {
//        self.onRectangleDetect(@{@"stableCounter": @(self.stableCounter), @"lastDetectionType": @(type)});
//    }
//
  if (self.stableCounter > self.detectionCountBeforeCapture &&
      [NSDate timeIntervalSinceReferenceDate] > self.lastCaptureTime + self.durationBetweenCaptures) {
    self.lastCaptureTime = [NSDate timeIntervalSinceReferenceDate];
    self.stableCounter = 0;
    [self capture];
  }
}
- (void) onPictureTaken: (NSDictionary*) result {
  printf("on picture taken");
}

- (void)setAutoCaptureEnabled:(BOOL)enabled {
  _autoCaptureEnabled = enabled;
}

- (void) capture {
  [self captureImageWithCompletionHander:^(UIImage *croppedImage, UIImage *initialImage, CIRectangleFeature *rectangleFeature) {
//      if (self.onPictureTaken) {
      NSData *croppedImageData = UIImageJPEGRepresentation(croppedImage, self.quality);

      if (initialImage.imageOrientation != UIImageOrientationUp) {
        UIGraphicsBeginImageContextWithOptions(initialImage.size, false, initialImage.scale);
        [initialImage drawInRect:CGRectMake(0, 0, initialImage.size.width
                , initialImage.size.height)];
        initialImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
      }

      NSData *initialImageData = UIImageJPEGRepresentation(initialImage, self.quality);

      /*
       RectangleCoordinates expects a rectanle viewed from portrait,
       while rectangleFeature returns a rectangle viewed from landscape, which explains the nonsense of the mapping below.
       Sorry about that.
       */
      id rectangleCoordinates = rectangleFeature ? @{
              @"topLeft": @{ @"y": @(rectangleFeature.bottomLeft.x + 30), @"x": @(rectangleFeature.bottomLeft.y)},
              @"topRight": @{ @"y": @(rectangleFeature.topLeft.x + 30), @"x": @(rectangleFeature.topLeft.y)},
              @"bottomLeft": @{ @"y": @(rectangleFeature.bottomRight.x), @"x": @(rectangleFeature.bottomRight.y)},
              @"bottomRight": @{ @"y": @(rectangleFeature.topRight.x), @"x": @(rectangleFeature.topRight.y)},
      } : [NSNull null];

      if (self.useBase64) {
        dispatch_async(dispatch_get_main_queue(), ^{
            printf("calling flutter onPictureTaken base64");
            [self->_flutterChannel invokeMethod:@"onPictureTaken" arguments:@{
                    @"croppedImage": [croppedImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength],
                    @"initialImage": [initialImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength],
                    @"rectangleCoordinates": rectangleCoordinates }];
        });

//              onPictureTaken(@{
//                                    @"croppedImage": [croppedImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength],
//                                    @"initialImage": [initialImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength],
//                                    @"rectangleCoordinates": rectangleCoordinates });
      }
      else {
        NSString *dir = NSTemporaryDirectory();
        if (self.saveInAppDocument) {
          dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        }
        NSString *croppedFilePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"cropped_img_%i.jpeg",(int)[NSDate date].timeIntervalSince1970]];
        NSString *initialFilePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"initial_img_%i.jpeg",(int)[NSDate date].timeIntervalSince1970]];

        [croppedImageData writeToFile:croppedFilePath atomically:YES];
        [initialImageData writeToFile:initialFilePath atomically:YES];



        dispatch_async(dispatch_get_main_queue(), ^{
            printf("calling flutter onPictureTaken file");
            [self->_flutterChannel invokeMethod:@"onPictureTaken" arguments:@{
                    @"croppedImage": croppedFilePath,
                    @"initialImage": initialFilePath,
                    @"rectangleCoordinates": rectangleCoordinates

            }];
        });
      }

      if (!self.captureMultiple) {
        [self stop];
      }
  }];

}


@end
