@echo off
set "JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot"
set "ANDROID_HOME=C:\android-sdk"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo Copying lib directory...
xcopy /E /Y /I "d:\HỆ THỐNG QUẢN LÝ CÔNG VIỆC\source\TITSMART_Task_Management\mobile\lib" "C:\titsmart_mobile\lib"

echo Building APK...
cd /d C:\titsmart_mobile
call C:\flutter\bin\flutter.bat build apk --release

echo Copying built APK...
copy /Y "C:\titsmart_mobile\build\app\outputs\flutter-apk\app-release.apk" "d:\HỆ THỐNG QUẢN LÝ CÔNG VIỆC\source\TITSMART_Task_Management\TITSMART_App_v1.0.apk"
echo BUILD FINISHED SUCCESSFULLY!
