package com.example.scanner.helpers;

public class AppGlobals {
    private static AppGlobals instance;
    private boolean autoCaptureEnabled = false; // 전역으로 관리하고 싶은 변수

    // 싱글턴 인스턴스 반환 메서드
    public static synchronized AppGlobals getInstance() {
        if (instance == null) {
            instance = new AppGlobals();
        }
        return instance;
    }

    // autoCaptureEnabled 상태를 가져오는 메서드
    public boolean isAutoCaptureEnabled() {
        return autoCaptureEnabled;
    }

    // autoCaptureEnabled 상태를 설정하는 메서드
    public void setAutoCaptureEnabled(boolean autoCaptureEnabled) {
        this.autoCaptureEnabled = autoCaptureEnabled;
    }
}
