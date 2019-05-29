#import <Flutter/Flutter.h>
#import <CoreLocation/CoreLocation.h>
@interface FlutterLocationPlugin : NSObject<FlutterPlugin>

@property (nonatomic,strong)CLLocationManager *locationManager;
@property FlutterResult result;



@end
