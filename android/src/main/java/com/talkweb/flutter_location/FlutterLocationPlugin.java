package com.talkweb.flutter_location;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Build;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterLocationPlugin */
public class FlutterLocationPlugin implements MethodCallHandler {

  private static String action_getLocation = "action_getLocation";
  static Activity _context;
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_location");
    channel.setMethodCallHandler(new FlutterLocationPlugin());
    _context=registrar.activity();
  }

  @Override
  public void onMethodCall(MethodCall call,final Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }else if (call.method.equals(action_getLocation)){ //获取经纬度
      String[] permissions = new String[]{Manifest.permission.ACCESS_COARSE_LOCATION,Manifest.permission.ACCESS_FINE_LOCATION};
      PermissionsUtils.getInstance().chekPermissions(
              _context, permissions, new PermissionsUtils.IPermissionsResult(){

                @Override
                public void passPermissons() {
                  final GPSUtils instance = GPSUtils.getInstance(_context);
                  instance.getLngAndLat(new GPSUtils.OnLocationResultListener() {
                    @Override
                    public void onLocationResult(Location location) {

                      JSONObject retVal = new JSONObject();
                      try {
                        retVal.put("code",0);
                        retVal.put("desc","");
                        retVal.put("latitude",location.getLatitude());
                        retVal.put("longitude",location.getLongitude());
                        retVal.put("provider",location.getProvider());
                      } catch (JSONException e) {
                        e.printStackTrace();
                      }
                      result.success(retVal.toString());
                      instance.removeListener();
                    }

                    @Override
                    public void OnLocationChange(Location location) {

                    }
                  });
                }

                @Override
                public void forbitPermissons() {
                  JSONObject retVal = new JSONObject();
                  try {
                    retVal.put("code",-9);
                    retVal.put("desc","用户未给予权限");
                    retVal.put("latitude",-1);
                    retVal.put("longitude",-1);
                    retVal.put("provider",-1);
                  } catch (JSONException e) {
                    e.printStackTrace();
                  }
                  result.success(retVal.toString());
                }
              }
      );

    }
    else {
      result.notImplemented();
    }
  }



  /**
   * 是否应该检查权限
   * @return
   */
  public boolean showCheckPermissions() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      return true;
    } else {
      return false;
    }
  }



}
