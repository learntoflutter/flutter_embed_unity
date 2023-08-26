# flutter_embed_unity

Embed Unity 3D into Flutter apps. Designed to offer more basic functionality than other packages, but be more stable and maintainable

# 3D

See https://www.youtube.com/watch?v=zKQYGKAe5W8&t=7067s&ab_channel=Flutter

## Limitations

Breaking many of these rules, which is why this library is brittle / has workarounds:

https://docs.unity3d.com/Manual/UnityasaLibrary.html
https://docs.unity3d.com/Manual/UnityasaLibrary-Android.html


Real device only, not simulator? Test iOS: Build Settings -> Target SDK -> Simulator SDK


Gradle: https://docs.unity3d.com/Manual/android-gradle-overview.html



On Android and iOS:
Only full-screen rendering is supported. It’s not possible to render only on a part of the screen.
When Unity is in an unloaded state (after calling Application.Unload), it retains some amount of memory (between 80–180Mb) to be able to instantly switch back and run again in the same process. The amount of memory that’s not released largely depends on the device’s graphics resolution.
On iOS, if the Unity runtime quits entirely (after calling Application.Quit), it’s not possible to reload Unity again in the same app session.
You can’t load more than one instance of the Unity runtime, or integrate more than one Unity runtime.




## Required configurations

### android:configChanges


The UnityPlayer is not designed to be shown again after it is shut down, or used in Flutter widgets. 

See https://docs.unity3d.com/Manual/UnityasaLibrary-Android.html
> Quit - The application calls IUnityPlayerLifecycleEvents.onUnityPlayerQuitted when the Unity Player quits. The process that was running Unity ends after this call.

Workarounds. One limitation is that we cannot handle the main FlutterActivity being destroyed (eg on orientation change). Therefore you must make sure that android:configChanges includes at least orientation, screenLayout, screenSize and keyboardHidden (to prevent crashes during orientation change) and ideally all the values included in the default configuration:

android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"

See https://developer.android.com/guide/topics/manifest/activity-element#config
https://developer.android.com/guide/topics/resources/runtime-changes

### android:screenOrientation

??????
Do not set android:screenOrientation (eg android:screenOrientation="landscape"), this may cause unity to freeze after orientation change?????

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Unity

2022.3 LTS latest

From hub: new project, 3D (URP) Core
Create anywhere (recommend outside project, separate github repo)
Build settings: android, switch platform

Check 'Export project'
See https://docs.unity3d.com/2022.1/Documentation/Manual/android-export-process.html


Target API level: select the same level your project is targeting

Player Settings -> Other settings -> Scripting backend: select IL2CPP
See https://docs.unity3d.com/Manual/scripting-backends.html
https://docs.unity3d.com/Manual/IL2CPP.html

Player Settings -> Other settings -> Target Architechtures: enable ARMv7 and ARM64

Optional:
- IL2CPP code generation: Faster runtime vs faster build

Export project to ??????
Check Unity console says Build completed with a result of 'Succeeded'

Our Unity project is now ready to use, but we still haven't actually linked it to our app

### iOS

As per https://docs.unity3d.com/Manual/UnityasaLibrary-iOS.html we need to:

> To integrate Unity into another Xcode project, you need to combine both Xcode projects (the native one and the one Unity generates) into a single Xcode workspace, and add the UnityFramework.framework file to the Embedded Binaries section of the Application target for the native Xcode project. 

So open your app's `ios/Runner.xcworkspace` in Xcode

In the project navigator, make sure nothing is selected

From Xcode toolbar, select File -> Add files to "Runner" -> select `ios/UnityLibrary/Unity-Iphone.xcodeproj`. This should add the Unity-iPhone project to your workspace at the same level as the Runner and Pods projects (if you accidentally added it as a child of Runner, right-click Unity-iPhone, choose Delete, then choose Remove Reference. Then *make sure nothing is selected* and try again). Alternatively, you can drag-and-drop Unity-Iphone.xcodeproj into the project navigator, again ensuring that you drop it at the root of the tree (at the same level as Runner and Pods)

In Xcode project navigator, select Runner, then in the editor select the Runner target under TARGETS, then select the General tab. Scroll down to Frameworks, Libraries, and Embedded Content. Click the + button to add. In the window which opens to select a framework, you should be able to find Workspace -> Unity-iPhone -> UnityFramework.framework. Select this and click Add. Make sure the Embed option is set to 'Embed & Sign'.


-------- Must be done after every export --------
The exported Unity project contains a project and target called Unity-iPhone, which is a thin 'launcher' app for Unity which you can build and deploy as a stand-alone app. Instead, we want to embed everything (the Unity engine and our Unity game) into our own Flutter app as a single framework file (UnityFramework). To do that, we need to change the Target Membership of the Data folder to be UnityFramework instead of the default Unity-iPhone:
In project navigator, expand Unity-iPhone project, and select the Data folder. In the Inspector, under Target Membership, change the target membership to UnityFramework.

To be able to pass messages from Unity C# to the iOS part of the plugin (which then passes the message on to Flutter) the C# file you include in your Unity project declares (but does not define) a function called `FlutterEmbedUnityIos_sendToFlutter`. This function is instead defined in the plugin. To join these two things together, we need to tell Xcode to ignore the fact that `FlutterEmbedUnityIos_sendToFlutter` is not defined in the Unity module, and instead link it to the definition in the plugin:

In project navigator, select Unity-iPhone project, then in the editor select the Unity-iPhone project under PROJECTS, then select the Build Settings tab. In the Build Settings tab, find the 'Other linker Flags' setting (you can use the search box to help you find it). Add the following as a setting: `-Wl,-U,_FlutterEmbedUnityIos_sendToFlutter`

> `-Wl` allows us to pass additional options to the linker when it is invoked
> `-U` tells the linker to force the symbol `_FlutterEmbedUnityIos_sendToFlutter` to be entered in the output file as an undefined symbol. It will be linked instead to a function defined in the plugin.
-----------------


Common error: “No such module UnityFramework”

1. Make sure you have carefully done all the steps outlined here
2. In Xcode, in the top bar to the right of the Run button (the one shaped like a triangular Play button), change the target from Runner to UnityFramework. Then press ⌘+B to build UnityFramework. Then do the same for the Unity-iPhone target. Finally, change back to the Runner target and attempt to build again.
3. See https://stackoverflow.com/questions/29500227/getting-error-no-such-module-using-xcode-but-the-framework-is-there


### Android


tell our project to depend on it:

- Add to android/app/build.gradle (add to any existing dependencies block, or create one if it doesn't exist):

dependencies {
    implementation project(':unityLibrary')
}


add the exported unity project to the gradle build using an `include` in android/settings.gradle:
- Add to android/settings.gradle:

include ':unityLibrary'


Add to `android\build.gradle`:


```
allprojects {
    repositories {
        google()
        mavenCentral()
		// Add this:
        flatDir {
            dirs "${project(':unityLibrary').projectDir}/libs"
        }
    }
}
```

so it becomes


By default, Unity has this in it's exported project build.gradle:

aaptOptions {
        noCompress = ['.unity3d', '.ress', '.resource', '.obb', '.bundle', '.unityexp'] + unityStreamingAssets.tokenize(', ')
        ignoreAssetsPattern = "!.svn:!.git:!.ds_store:!*.scc:!CVS:!thumbs.db:!picasa.ini:!*~"
    }
	
When we try to build, this error will happen:

> Could not get unknown property 'unityStreamingAssets'

Fix this by:
- Add to android/gradle.properties:

```
unityStreamingAssets=
```


##### If you're using XR (VR / AR)

If you are using XR features in Unity (eg ARFoundation), make sure you check Unity's project validation checks: in your Unity project, go to Project Settings -> XR Plug-in Management -> Project Validation, and fix any problems.

Then we need to perform some additional configuration on your project.

###### Android

In your exported `unityLibrary` you may find an extra project folder called `xrmanifest.androidlib`. The Unity project depends on this, so you need to inlcude it in your app's build. Do this by adding the following to your `android/settings.gradle`:

```
// This additional project is required to build with Unity XR:
include ':unityLibrary:xrmanifest.androidlib'
```

In addition, some changes need to be made to the `MainActivity` of your app. This is to work around the fact that Unity as a library was designed to run in a custom activity made by Unity (you can find this in `unityLibrary\src\main\java\com\unity3d\player\UnityPlayerActivity.java`). Unfortunately, some Unity code expects to be able to find some properties in the activity hosting the Unity player - specifically, a field called `mUnityPlayer`. If it doesn't find this field, your app will crash when your XR code initialises with the following error:

> `Non-fatal Exception: java.lang.Exception: AndroidJavaException : java.lang.NoSuchFieldError: no "Ljava/lang/Object;" field "mUnityPlayer" in class "Lcom/example/app/MainActivity;" or its superclasses`

Because this plugin is designed to embed Unity in a widget, not in an activity, we need to make our MainActivity 'pretend' like it's a `UnityPlayerActivity` by giving it a `mUnityPlayer` field which can be set by the plugin when the `UnityPlayer` is created. 

Find your `MainActivity` class (this is usually located at `<flutter project>\android\app\src\main\kotlin\com\<your org>\MainActivity.kt` or `<flutter project>\android\app\src\main\java\com\<your org>\MainActivity.java`)

If your `MainActivity` extends `FlutterActivity`, you can simply change it to extend `FakeUnityPlayerActivity` instead of `FlutterActivity` (`FakeUnityPlayerActivity` also extends `FlutterActivity`). This is the simplest option, as nothing else needs to be done:


```java
import com.jamesncl.dev.flutter_embed_unity_android.unity.FakeUnityPlayerActivity;

public class MainActivity extends FakeUnityPlayerActivity {
	
}
```

```kotlin
import com.jamesncl.dev.flutter_embed_unity_android.unity.FakeUnityPlayerActivity

class MainActivity: FakeUnityPlayerActivity() {
    
}

```

Otherwise, if your `MainActivity` extends something else (for example `FlutterFragmentActivity` or your own custom Activity) it may be easier to make your `MainActivity` implement `IFakeUnityPlayerActivity`. If you do this, you MUST also create a public field of type `Object` (for Java) or `Any?` (for Kotlin) in your `MainActivity` called `mUnityPlayer`, and set this via the interface function:

```java
import com.jamesncl.dev.flutter_embed_unity_android.unity.IFakeUnityPlayerActivity;

public class MainActivity implements IFakeUnityPlayerActivity {

	// Don't change the name of this variable; referenced from native code
    public Object mUnityPlayer;
    
    @Override
    public void setmUnityPlayer(Object mUnityPlayer) {
        this.mUnityPlayer = mUnityPlayer;
    }
}

``` 

```kotlin
class Thing: IFakeUnityPlayerActivity {
    
	// Don't change the name of this variable; referenced from native code
    var mUnityPlayer: Any? = null
	
    override fun setmUnityPlayer(mUnityPlayer: Any?) {
        this.mUnityPlayer = mUnityPlayer
    }
}
```


## Optional adjustments

playerOptions.options = BuildOptions.AllowDebugging | BuildOptions.Development;
PlayerSettings.SetIl2CppCompilerConfiguration(BuildTargetGroup.Android, isReleaseBuild ? Il2CppCompilerConfiguration.Release : Il2CppCompilerConfiguration.Debug);
                PlayerSettings.SetIl2CppCodeGeneration(UnityEditor.Build.NamedBuildTarget.Android, UnityEditor.Build.Il2CppCodeGeneration.OptimizeSize);
				
## Unity export script

See See https://docs.unity3d.com/2022.3/Documentation/Manual/UnityasaLibrary-Android.html
https://docs.unity3d.com/2022.3/Documentation/Manual/UnityasaLibrary.html
https://docs.unity3d.com/Manual/UnityasaLibrary-iOS.html

Old and outdated but still useful background: https://forum.unity.com/threads/using-unity-as-a-library-in-native-ios-android-apps.685195/

https://github.com/Unity-Technologies/uaal-example/blob/master/docs/android.md

UnityPlayerActivity source:
<Unity hub editors install folder>\2022.3.7f1\Editor\Data\PlaybackEngines\AndroidPlayer\Source\com\unity3d\player\UnityPlayerActivity.java


We're replacing launcher with our own app, but when we run, there will be an error:

> Error creating CustomUnityPlayer: android.content.res.Resources$NotFoundException: String resource ID #0x0

This is because unity is trying to read some string values from the `strings.xml` resouces file which it was expecting to find (`app_name` and `game_view_content_description`). Even though we don't actually use these, we still need them to be present to keep unity happy. So:

- Copy strings.xml from `android\unityLibrary\launcher\src\main\res\values\` to `android\unityLibrary\unityLibrary\src\main\res\values\`
- Now we can delete the `launcher` folder, `gradle` folder, and files at the root export (`build.gradle`, `gradle.properties`, `local.properties`, `settings.gradle`)


- Move contents of unityLibrary/unityLibrary to unityLibrary
- ??????????? Delete ` android:extractNativeLibs="true"` from `<application ... >` tag in `android\unityLibrary\src\main\AndroidManifest.xml`
- Delete the whole `<activity>` under `<application>` in `android\unityLibrary\src\main\AndroidManifest.xml`
            
			
If we are using Gradle 8 for our project (which the example project does) we need to add the package's namespace to the build.gradle, which is now required, otherwise we get:

> Namespace not specified. Please specify a namespace in the module's build.gradle file

Unity 2022.3 currently does not include this, as it still uses Gradle 7.2 (see https://docs.unity3d.com/Manual/android-gradle-overview.html), so add this to the build.gradle at `android\unityLibrary\build.gradle` file like so:

android {
    namespace 'com.unity3d.player'
	...
}


# Misc notes

Wait for scene load the first time you create an EmbedUnity widget before sending message. After that, you can send message at any time (even without EmbedUnity widget in the widget tree and even after pausing Unity) and it will be received, because Unity is still active in the background.



# Developer notes

Android: explain the classes.jar

iOS: built UnityFramework.framework (by building the exported Unity project), extract it from DerivedData, copied to flutter_embed_unity_2022_3_ios/ios, edited flutter_embed_unity_2022_3_ios/ios/flutter_embed_unity_ios.podspec to include: 

```
# Add UnityFramework
s.vendored_frameworks = 'UnityFramework.framework'
```
Then run `pod install` from flutter_embed_unity_2022_3_ios/example/iOS


`-Wl,-U,_FlutterEmbedUnityIos_sendToFlutter`

> `-Wl` allows us to pass additional options to the linker (`ld`) when it is invoked
> `-U` tells the linker to force the symbol `_FlutterEmbedUnityIos_sendToFlutter` to be entered in the output file as an undefined symbol. It will be linked instead to a C function defined in `flutter_embed_unity_2022_3_ios/ios/Classes/SendToFlutter.swift`

See https://linux.die.net/man/1/ld