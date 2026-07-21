$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot"
$env:ANDROID_HOME = "C:\android-sdk"
$env:PATH = "$env:JAVA_HOME\bin;" + $env:PATH

Copy-Item -Path "d:\HỆ THỐNG QUẢN LÝ CÔNG VIỆC\source\TITSMART_Task_Management\mobile\lib\*" -Destination "C:\titsmart_mobile\lib\" -Recurse -Force
Set-Location "C:\titsmart_mobile"
& "C:\flutter\bin\flutter.bat" build apk --release
Copy-Item -Path "C:\titsmart_mobile\build\app\outputs\flutter-apk\app-release.apk" -Destination "d:\HỆ THỐNG QUẢN LÝ CÔNG VIỆC\source\TITSMART_Task_Management\TITSMART_App_v1.0.apk" -Force
