package com.example.scanner;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;

import com.example.scanner.views.MainView;
import com.example.scanner.views.OpenNoteCameraView;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformView;
import com.example.scanner.helpers.AppGlobals;


public class ScannerViewManager implements PlatformView, MethodCallHandler {


    private MainView view = null;
    Context context;
    Activity activity;




    final MethodChannel channel;

    Map<String, Object> params;

    ScannerViewManager(Context context,Activity activity, Map<String, Object> params,MethodChannel channel){
        this.context = context;
        this.activity = activity;
        this.params = params;
        this.channel = channel;

        this.channel.setMethodCallHandler(this);
    }



    @Override
    public View getView() {
        MainView.createInstance(context,activity);
        view = MainView.getInstance();
        setParams();
        return view;
    }

    @Override
    public void dispose() {

    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "setAutoCaptureEnabled":
                boolean enableAutoCapture = call.argument("enableAutoCapture");
                System.out.println("ScannerViewManager setAutoCaptureEnabled: " + enableAutoCapture);
                AppGlobals.getInstance().setAutoCaptureEnabled(enableAutoCapture);
                result.success(null); // Acknowledge the call was received.
                break;

            case "isNativeReady":
                result.success("true");
                break;
            // Handle other method calls if necessary
            default:
                result.notImplemented(); // Method not found
        }
    }

    void setParams(){

        view.setOnRectangleDetectedListener(new OpenNoteCameraView.OnRectangleDetectedListener() {
            @Override
            public void onRectangleDetected(boolean isDetected) {
                Handler uiThreadHandler = new Handler(context.getMainLooper());
                Runnable runnable = new Runnable() {
                    @Override
                    public void run() {
                        Map<String, Object> args = new HashMap<>();
                        args.put("isDetected", isDetected);
                        System.out.println("onRectangleDetected" + isDetected);
                        channel.invokeMethod("onRectangleDetected", args);
                    }
                };
                uiThreadHandler.postAtFrontOfQueue(runnable);
            }
        });
        view.setOnProcessingListener(new OpenNoteCameraView.OnProcessingListener() {

            @Override
            public void onProcessingChange(Map data) {
//Log.d("debug",path.toString());
                Handler uiThreadHandler = new Handler(context.getMainLooper());
                Runnable runnable = new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod("onPictureTaken",data);
                    }
                };
                uiThreadHandler.postAtFrontOfQueue(runnable );
            }
        });

        view.setOnScannerListener(new OpenNoteCameraView.OnScannerListener() {

            @Override
            public void onPictureTaken(Map data) {

                 Handler uiThreadHandler = new Handler(context.getMainLooper());
                 Runnable runnable = new Runnable() {
                     @Override
                     public void run() {
                       channel.invokeMethod("onPictureTaken",data);
                     }
                 };
uiThreadHandler.postAtFrontOfQueue(runnable );


            }
        });

        boolean documentAnimation;
        if(params.containsKey("documentAnimation")){
            documentAnimation =(boolean) params.get("documentAnimation");
        }else{
            documentAnimation = false;
        }

        view.setDocumentAnimation(documentAnimation);

        String overlayColor;
        if(params.containsKey("overlayColor")){
            overlayColor = (String ) params.get("overlayColor");
            view.setOverlayColor(overlayColor);
        }

        int detectionCountBeforeCapture;
        if(params.containsKey("detectionCountBeforeCapture")){
            detectionCountBeforeCapture =(int) params.get("detectionCountBeforeCapture");
        }else{
            detectionCountBeforeCapture = 15;
        }
        view.setDetectionCountBeforeCapture(detectionCountBeforeCapture);


        boolean enableTorch;
        if(params.containsKey("enableTorch")){
            enableTorch =(boolean) params.get("enableTorch");
        }else{
            enableTorch = false;
        }

        view.setEnableTorch(enableTorch);


        boolean manualOnly;
        if(params.containsKey("manualOnly")){
            manualOnly =(boolean) params.get("manualOnly");
        }else{
            manualOnly = false;
        }

        view.setManualOnly(manualOnly);

        boolean noGrayScale;
        if(params.containsKey("noGrayScale")){
            noGrayScale =(boolean) params.get("noGrayScale");
        }else{
            noGrayScale = false;
        }

        view.setRemoveGrayScale(noGrayScale);

        double brightness;
        if(params.containsKey("brightness")){
            brightness =(double) params.get("brightness");
        }else{
            brightness = 10;
        }
        view.setBrightness(brightness);


        double contrast;
        if(params.containsKey("contrast")){
            contrast =(double) params.get("contrast");
        }else{
            contrast = 1;
        }
        view.setContrast(contrast);
    }




}
