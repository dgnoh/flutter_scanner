#import "ScannerFactory.h"
#import "ScannerView.h"

#import <AVFoundation/AVFoundation.h>

@implementation ScannerFactory {
  NSObject<FlutterPluginRegistrar>* _registrar;
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
  }
  return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {

  [self requestCameraPermissionsIfNeeded];
  return [[ScannerController alloc] initWithFrame:frame
                                   viewIdentifier:viewId
                                        arguments:args
                                        registrar:_registrar];
//    ScannerController *controller = [ScannerController alloc];
//    return controller;

//  return [[FLTGoogleMapController alloc] initWithFrame:frame
//                                        viewIdentifier:viewId
//                                             arguments:args
//                                             registrar:_registrar];
}
- (void)requestCameraPermissionsIfNeeded {

  // check camera authorization status
  AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  switch (authStatus) {
    case AVAuthorizationStatusAuthorized: { // camera authorized
      // do camera intensive stuff
    }
          break;
    case AVAuthorizationStatusNotDetermined: { // request authorization

      [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
          dispatch_async(dispatch_get_main_queue(), ^{

              if(granted) {
                // do camera intensive stuff
              } else {
                [self notifyUserOfCameraAccessDenial];
              }
          });
      }];
    }
          break;
    case AVAuthorizationStatusRestricted:
    case AVAuthorizationStatusDenied: {
      dispatch_async(dispatch_get_main_queue(), ^{
          [self notifyUserOfCameraAccessDenial];
      });
    }
          break;
    default:
      break;
  }
}



- (void)notifyUserOfCameraAccessDenial {
  // display a useful message asking the user to grant permissions from within Settings > Privacy > Camera
}

@end

@implementation ScannerController {
  int64_t _viewId;
  FlutterMethodChannel* _channel;
  BOOL _trackCameraPosition;
  NSObject<FlutterPluginRegistrar>* _registrar;
  BOOL _cameraDidInitialSetup;
  ScannerView* _scannerView;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _viewId = viewId;
    _registrar = registrar;
    _trackCameraPosition = NO;
    // 사용하는 viewId를 문자열로 포함시킵니다. 여기서는 예시로 %lld를 사용합니다. 실제 타입에 맞게 조정이 필요할 수 있습니다.
    NSString *channelName = @"io.dkargo.lodis/scanner";
    _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:[registrar messenger]];

    _scannerView = [[ScannerView alloc] initWithChannel:_channel];
    __weak __typeof__(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([@"setAutoCaptureEnabled" isEqualToString:call.method]) {
          NSNumber *enabled = call.arguments[@"enableAutoCapture"];
          NSLog(@"setAutoCaptureEnabled: %d", [enabled boolValue]);
          [weakSelf setAutoCaptureEnabled:[enabled boolValue]];
          result(nil);
        }
        else if ([@"isNativeReady" isEqualToString:call.method]) {
            result(@"true");
        }
        else {
          result(FlutterMethodNotImplemented);
        }
    }];

    _cameraDidInitialSetup = NO;

    float channelBrightness = [args[@"brightness"] floatValue] ?: 5.0;
    float channelContrast = [args[@"contrast"] floatValue] ?: 1.3;
  }
  return self;
}

- (UIView *)view {
  return _scannerView;
}

// ScannerView에 자동 캡처 활성화/비활성화 설정
- (void)setAutoCaptureEnabled:(BOOL)enabled {
  NSLog(@"setAutoCaptureEnabled2");
  [_scannerView setAutoCaptureEnabled:enabled];
}

- (void)dealloc {
    // FlutterMethodChannel의 메소드 콜 핸들러 해제
    [_channel setMethodCallHandler:nil];
    _scannerView = nil; // ScannerView 참조 해제
}

@end

