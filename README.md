# flutter_location

获取设备GPS坐标 [Obtaining GPS coordinates of equipment]



## Getting Started

### 引入 [Introduce]

append pubspec.yaml

```ymal
  flutter_location:
    git: https://github.com/zhangjianying/flutter_location.git
```



### 使用 [Use]

```dart
import 'package:flutter_location/flutter_location.dart';

 // function
 Future<LocationData> getLocation() async {
    LocationData currentLocation = null;
    try {
      currentLocation = await FlutterLocation.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {}
      currentLocation = null;
    }
    return currentLocation;
  }

//use
  onPress: (){
        LocationData result = await getLocation();
        print('result: ${result.toString()}');
        DialogUtils.showSnackBarMsg(context, result.toString());
  }

```



LocationData 结构 

[LocationData structure]

```dart
class LocationData {
  final String provider;
  final String desc;
  final double longitude;
  final double latitude;
  final int code;

  LocationData(
      {this.provider, this.desc, this.longitude, this.latitude, this.code});

  @override
  String toString() {
    return "code:${code}  latitude:${latitude} longitude:${longitude} provider:${provider} desc:${desc}";
  }
}
```



## 解决冲突 [Resolving conflicts]

如果android编译报错.可能是因为使用了com.android.support 的原因

[If Android compiles errors, it may be because com. android. support is used.]

修改你工程的 gradle.build 

[Modify the gradle. build of your project]

添加如下:

[Add the following:]

```java
project.configurations.all {
        resolutionStrategy.eachDependency { details ->
            if (details.requested.group == 'com.android.support'
                    && !details.requested.name.contains('multidex') ) {
                details.useVersion "28.0.0"
            }
        }
}
```



## IOS权限配置 [ios authority config]

添加 NSLocationWhenInUseUsageDescription 与 NSLocationAlwaysUsageDescription 到plist.info
[Add NSLocation WhenInUseUsage Description and NSLocation Always Usage Description to plist. info]



# 注意 [Note]

* 只根据设备获取GPS坐标.android上不借助Google Play服务. [Get GPS coordinates only from devices. Android does not use Google Play services]
* android / ios 都是插件自身管理权限.不借助permission_handler 等第三方插件. [Android / IOS is the plug-in's own management rights. No third-party plug-ins such as permission_handler are used.]