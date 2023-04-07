# FirebaseAnalytics

Firebase Analytics for Android, Godot 3.5.1

This plugin is a wrapper of an android plugin. There is a Firebase singleton that calls methods in the AFirebase android plugin


## Installation
1. Install the android build template. This will create an android folder in the file system
2. Godot > Export Settings > Android > MinSDK 23, set unique_name(example org.godotengine.firebasetest), Custom Build - true, Permissions - Access Network State, Internet
3. Transfer files from the "ForAndroidPluginFolder" folder to the android/plugins folder. This will add a plugin for android
4. In the android\build folder, in the build file.gradle change code and sync (android studio)
``` java
  buildscript {
    apply from: 'config.gradle'

      repositories {
          google()
          mavenCentral()
  //CHUNK_BUILDSCRIPT_REPOSITORIES_BEGIN
  //CHUNK_BUILDSCRIPT_REPOSITORIES_END
      }
      dependencies {
          classpath "com.android.tools.build:gradle:$versions.androidGradlePlugin"
          classpath libraries.kotlinGradlePlugin
          classpath 'com.google.gms:google-services:4.3.15'
  //CHUNK_BUILDSCRIPT_DEPENDENCIES_BEGIN
  //CHUNK_BUILDSCRIPT_DEPENDENCIES_END
      }
  }

// This part is below buildscript{dependencies{}}
// firebase-bom added for version control(although there is only analytics here)
dependencies {
    implementation libraries.kotlinStdLib
    implementation libraries.androidxFragment
    implementation platform('com.google.firebase:firebase-bom:31.2.3')
    implementation 'com.google.firebase:firebase-analytics'
    //...
}
apply plugin: 'com.google.gms.google-services'
```
5. Get google-services.json in firebase-console, transfer to android/build
    * If SHA-1 is needed, I get it in android studio, grade button in right menu > Tasks/android/signReport (this can be disabled in settings)
    * When updating SHA-1 in firebase-console, it is worth replacing google-services.json
    * I forgot whether SHA-1 is needed for analytics ... :P

## How to use

### DebugView Firebase

* Firebase sends data in its own optimized way, it takes time (hours-days). For more convenient debugging, there is a DebugView that sends data within seconds
* I also recommend debugging via cmd > adb logcat. This is in case of errors and crashes (godot will not tell you what the error is, but cmd will say)

1. Connect your phone to godot via USB for debugging (It will look like an android icon, if you don't have one, you need to follow a number of steps to enable)
2. Cmd > adb devices. This will show if you have connected devices
3. 1 - enable debugging, 2 - disable
```
  adb shell setprop debug.firebase.analytics.app PACKAGE_NAME
  adb shell setprop debug.firebase.analytics.app .none.
```
4. That's it. DebugView is faster, but also with a delay, it may take a few minutes to connect (try sending LogEvent in debug mode)

### Code

To write code, use the Firebase singleton wrapper (this plugin is a wrapper for an android plugin)

Here is the code you will use:

#### Events
``` gdscript
  logEvent(event, params: Dictionary);
  # Custom Event, without parameters
  logEvent("customName", {})
  # Custom Event, 1 parameters (customParam:123) // You can use the recommended parameters for the names
  logEvent("customName2", {"customParam": {"value": 123, "type": "long"} })
  # Recommended Event(LevelStart) Wrapper
  logEvent_LevelStart("level_name")
  # Recommended Event(LevelStart) Code (In Firebase singleton)
  logEvent(FirebaseEvent.level_start, { FirebaseParams.keys()[FirebaseParams.level_name]: { "value": levelName, "type": "string" } })
  #* recommended events and parameters are taken from the documentation
  # All wrappers of recommended events (These are the ones I wrote, actually there are more of them, see Firebase.FirebaseEvent)
  logEvent_LevelStart(levelName: String)
  logEvent_LevelEnd(levelName: String, success: bool)
  logEvent_LevelUp(level: int, character: String)
  logEvent_EarnVirtualCurrency(virtualCurrencyName: String, value: float)
  logEvent_SpendVirtualCurrency(item_name: String, virtualCurrencyName: String, value: float)
  logEvent_TutorialBegin()
  logEvent_TutorialComplete()
  logEvent_UnlockAchievement(achievement_id: String)
  logEvent_ScreenView(screen_name: String, screen_class: String)
```
#### UserProperty
``` gdscript
  setUserProperty(name:String, value:String)
  # example
  setUserProperty("FavoriteFood", "Arbuz")
```
#### And other code that you can find in Firebase singleton

#### (Firebase Documentation(to understand what functions and events are for))[https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics#public-void-setanalyticscollectionenabled-boolean-enabled]

## Images

![img](https://github.com/Qumico/FirebaseAnalytics/blob/main/Resources/preview1.png)
![img2](https://github.com/Qumico/FirebaseAnalytics/blob/main/Resources/preview2.png)

