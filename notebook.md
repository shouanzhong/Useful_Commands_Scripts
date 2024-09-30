## 跳过开机向导
1.设置系统属性
```shell
adb shell settings put global device_provisioned 1
adb shell settings put secure user_setup_complete 1
adb shell settings put secure user_setup_persona_complete 1
```
2.禁用 Setup Wizard 应用 (不同机器需根据包名做调整)
```shell
adb shell pm disable-user com.google.android.setupwizard
adb shell pm disable com.google.android.setupwizard
```

## 打开开发者模式
```shell
adb shell settings put global development_settings_enabled 1
```
