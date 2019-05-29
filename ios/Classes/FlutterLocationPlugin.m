#import "FlutterLocationPlugin.h"
#import <CoreLocation/CoreLocation.h>


@implementation FlutterLocationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_location"
            binaryMessenger:[registrar messenger]];
  FlutterLocationPlugin* instance = [[FlutterLocationPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if( [@"action_getLocation" isEqualToString:call.method]) {
      self.locationManager = [[CLLocationManager alloc] init];
      self.locationManager.delegate = self;
      self.result = result;
      
      [self startLocation:NO];
      
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)startLocation:(BOOL)enableHighAccuracy
{
    if (![self isLocationServicesEnabled]) {
    //    [self returnLocationError:PERMISSIONDENIED withMessage:@"Location services are not enabled."];
         NSLog(@"Location services are not enabled.");
        return;
    }
    if (![self isAuthorized]) {
        NSString* message = nil;
        BOOL authStatusAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
        if (authStatusAvailable) {
            NSUInteger code = [CLLocationManager authorizationStatus];
            if (code == kCLAuthorizationStatusNotDetermined) {
                // could return POSITION_UNAVAILABLE but need to coordinate with other platforms
                message = @"User undecided on application's use of location services.";
            } else if (code == kCLAuthorizationStatusRestricted) {
                message = @"Application's use of location services is restricted.";
            }
        }
        // PERMISSIONDENIED is only PositionError that makes sense when authorization denied
       // [self returnLocationError:PERMISSIONDENIED withMessage:message];
        NSLog(message);
        self.result([self retResutl:-777 desc:message provider:@"GPS" longitude:-9999 latitude:-9999]);
        return;
    }
    
#ifdef __IPHONE_8_0
    NSUInteger code = [CLLocationManager authorizationStatus];
    if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) { //iOS8+
       // __highAccuracyEnabled = enableHighAccuracy;
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]){
            [self.locationManager requestWhenInUseAuthorization];
        } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]) {
            [self.locationManager  requestAlwaysAuthorization];
        } else {
            NSLog(@"[Warning] No NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription key is defined in the Info.plist file.");
        }
        return;
    }
#endif
    
    
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
    
    if(enableHighAccuracy){
        self.locationManager.distanceFilter=5;
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    }else{
        self.locationManager.distanceFilter=10;
        self.locationManager.desiredAccuracy=kCLLocationAccuracyThreeKilometers;
    }
    
    
}


- (NSString*) retResutl:(int) code desc:(NSString*) desc provider:(NSString*) provider longitude:(double)longitude latitude:(double) latitude
{
    NSString* retVal = [@"" stringByAppendingFormat:@"{\"code\": %d , \"desc\": \"%@\" ,\"provider\":\"%@\", \"longitude\": %f , \"latitude\":%f }",code,desc,provider,longitude,latitude];
    return retVal;
}
 
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // 获取经纬度
//    NSLog(@"纬度:%f",newLocation.coordinate.latitude);
//    NSLog(@"经度:%f",newLocation.coordinate.longitude);
    // 停止位置更新
    [manager stopUpdatingLocation];
    self.result([self retResutl:0 desc:@"ok" provider:@"GPS" longitude:newLocation.coordinate.longitude latitude:newLocation.coordinate.latitude]);
    
}

// 定位失误时触发
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error:%@----%ld",error,(long)[error code]);
    if ([error code] == 1) {
        //没有位置访问权限
    }
}

- (BOOL)isAuthorized
{
    BOOL authorizationStatusClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
    
    if (authorizationStatusClassPropertyAvailable) {
        NSUInteger authStatus = [CLLocationManager authorizationStatus];
#ifdef __IPHONE_8_0
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {  //iOS 8.0+
            return (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) || (authStatus == kCLAuthorizationStatusAuthorizedAlways) || (authStatus == kCLAuthorizationStatusNotDetermined);
        }
#endif
        return (authStatus == kCLAuthorizationStatusAuthorizedAlways) || (authStatus == kCLAuthorizationStatusNotDetermined);
    }
    
    // by default, assume YES (for iOS < 4.2)
    return YES;
}

- (BOOL)isLocationServicesEnabled
{
    BOOL locationServicesEnabledInstancePropertyAvailable = [self.locationManager respondsToSelector:@selector(locationServicesEnabled)]; // iOS 3.x
    BOOL locationServicesEnabledClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(locationServicesEnabled)]; // iOS 4.x
    
    if (locationServicesEnabledClassPropertyAvailable) { // iOS 4.x
        return [CLLocationManager locationServicesEnabled];
    } else {
        return NO;
    }
}
@end
