# flutter_embed_unity

Embed Unity 3D into Flutter apps using [Unity as a library](https://docs.unity3d.com/Manual/UnityasaLibrary.html)


# Important limitations

## Only supports Unity 2022.3 LTS
[Unity as a library](https://docs.unity3d.com/Manual/UnityasaLibrary.html) was only intended by Unity to be used fullscreen (running in it's own `UnityPlayerActivity.java` Activity on Android, or using `UnityAppController.mm` as the root UIViewController on iOS). By embedding Unity into a Flutter widget, this plugin breaks this assumption, calls undocumented functions written by Unity.

It is therefore **very important that you only use the Unity version which this plugin supports**, which is currently [Unity 2022.3 LTS (Long Term Support)](https://unity.com/releases/lts). Failure to do this will likely lead to crashes at runtime, because the undocumented functions this plugin calls can change and the workarounds it implements may not work as expected.

## Only 1 instance
Unity can only render in 1 widget at a time. Therefore, you can only use one `EmbedUnity` widget on a Flutter screen. If another screen is pushed onto the navigator stack, Unity will be detatched from the first screen and attached to the second screen. If the second screen is popped, Unity will be reattached back to the first screen.

## Memory usage
After the first `EmbedUnity` widget is shown on screen and Unity loads, Unity will remain in memory in the background (but paused) even after the widget has been disposed. Unity does not support shutting down without shutting down the entire app. See [the official limitations for more details](https://docs.unity3d.com/Manual/UnityasaLibrary.html).

## android:configChanges
[Unity as a library](https://docs.unity3d.com/Manual/UnityasaLibrary.html) is not designed to be shown again after it is shut down. On Android, if the Activity it runs in is destroyed, Unity will kill the entire app. As a consequence, we cannot handle the main FlutterActivity being destroyed, for example on orientation change. Therefore you must make sure that `android:configChanges` on the `MainActivity` of the app in the `android` subfolder of your Flutter project includes at least orientation, screenLayout, screenSize and keyboardHidden (to prevent the Activity being destroyed when these events occur) and ideally all the values included in the default configuration:

```
android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
```

Failure to do this will mean your app will crash on orientation change. See [the `android:configChanges` documentation](https://developer.android.com/guide/topics/manifest/activity-element#config) and [Android configuration changes documentation](https://developer.android.com/guide/topics/resources/runtime-changes) for more.


## TODO:
Real device only, not simulator? Test iOS: Build Settings -> Target SDK -> Simulator SDK

## TODO:
Gradle: https://docs.unity3d.com/Manual/android-gradle-overview.html

## Alternatives
If you need to support other versions of unity, consider using [flutter_unity_widget](https://pub.dev/packages/flutter_unity_widget)

Flutter Forward 2023 demonstrated [an early preview of 3D support directly in Dart using Impeller](https://www.youtube.com/watch?v=zKQYGKAe5W8&t=7067s&ab_channel=Flutter).


# Setup

## Configure Unity

- Install [the latest Unity 2022.3 LTS](https://unity.com/releases/lts) (See limitations above - you MUST use this version of Unity)
- Either open an existing Unity project (it must be configured to use [the Universal Render Pipeline](https://docs.unity3d.com/Manual/universal-render-pipeline.html)), or create a new one using the `3D (URP) Core` template
- In Unity, make sure to select the appropriate build platform: go to `File -> Build Settings` and select either Android or iOS, then click `Switch Platform`
- TODO import the package from tag release
  
### Additional Unity configuration for Android

- In Unity, go to `File -> Build Settings`, and [enable the `Export project` tickbox](https://docs.unity3d.com/2022.1/Documentation/Manual/android-export-process.html). This means that when Unity builds, it builds as a library which we can import into Flutter.
- In Unity, go to `File -> Build Settings -> Player Settings -> Other settings`, and make the d following changes:
  - Find `Target API level`: it's not required, but recommended, to set this to the same target API level of your Flutter project's `android` app (this is usually set in `<your flutter project>/android/app/build.grade` as `targetSdkVersion`)

TODO: Is this required? Is it needed in iOS?
  - In `File -> Build Settings -> Player Settings -> Other settings`, look for [`Scripting backend`](https://docs.unity3d.com/Manual/scripting-backends.html): this needs to be set to [`IL2CPP`](https://docs.unity3d.com/Manual/IL2CPP.html) so that the build can be integrated into your app.
  - In 

Recommended on Android:

Player Settings -> Other settings -> Target Architechtures: enable ARMv7 and ARM64

Optional:
- IL2CPP code generation: Faster runtime vs faster build


## Import Unity package

To allow Unity to send messages to Flutter, and to make exporting your Unity project into Flutter easier, this plugin includes some Unity scripts which you should import into your Unity project.

- Go to [the releases for this plugin on Github](https://github.com/jamesncl/flutter_embed_unity/releases)
- Find the release which matches the one you have used to add this plugin to your `pubspec.yaml`
- Expand `Assets`
- Download the file `flutter_embed_unity_2022_3.unitypackage`

![image](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/28e92fe3-a13d-4d32-8b97-ed4f723d5b4a)

- In Unity, go to `Assets -> import package -> Custom package`, and choose the file you just downloaded
- The package includes two parts: `FlutterEmbed` which contains scripts which are required to run the plugin, and `Example` which contains an optional example scene which demonstrates how to use them (you can untick these from the import package selection if you don't need the example).


## Setup your Unity project for sending messages to Flutter

### Sending messages from Flutter to Unity

You can directly call any public method of any `MonoBehaviour` script attached to a game object in the active scene which has a single `string` parameter. The Example scene from the package includes an example of this in `ReceiveFromFlutterRotation.cs`. In this example, `SetRotationSpeed` can be called directly from Flutter. This script is attached to a flutter logo game object, and allows Flutter to control the rotation speed:

```
public class ReceiveFromFlutterRotation : MonoBehaviour
{
    float _rotationSpeed = 0;

    void Update()
    {
        transform.Rotate(0, _rotationSpeed * Time.deltaTime, 0);
    }

    // Called from Flutter:
    public void SetRotationSpeed(string data)
    {
        _rotationSpeed = float.Parse(
            data,
            // When converting between strings and numbers in a message protocol
            // always use a fixed locale, to prevent unexpected parsing errors when
            // the user's locale is different to the locale used by the developer
            // (eg the decimal separator might be different)
            CultureInfo.InvariantCulture);
    }
}
```

### Sending messages from Unity to Flutter

You can only send a `string` message to Flutter, so it is up to you to decide on a message protocol (such as [protobuf](https://protobuf.dev/) or [JSON](https://www.json.org/json-en.html)). Simply use the `SendToFlutter.Send(string)` static function of the `SendToFlutter.cs` script from the `EmbedUnity` section of the package. There is an example of this in `SendToFlutterTouched.cs` which sends the message `touch` when the Flutter logo is touched:

```
public class SendToFlutterTouched : MonoBehaviour
{
    void Update()
    {
        if (Input.GetMouseButtonDown(0) || (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                SendToFlutter.Send("touch");
            }
        }
    }
}

```


## Export your Unity project

To embed Unity into your Flutter app, you need to export your Unity project into a form which we can integrate into the native `android` and / or `ios` part of your Flutter project.
The `EmbedUnity` section of the `flutter_embed_unity_2022_3.unitypackage` you imported includes scripts to make this easy, and an Editor menu item to launch them, so you should see an option called `Flutter embed` in the Unity toobar.

- First, create the folder to export your Unity project to. This MUST be either:
  - `<your flutter project>/android/unityLibrary` for Android or
  - `<your flutter project>/ios/unityLibrary` for iOS
- Select `Flutter Embed -> Export project to Flutter app` (select `ios` or `android` as appropriate)
- The export script will make some checks for you (follow any instructions which appear)
- When asked, select the `unityLibrary` export folder you created
- Wait for the project to build, then check the Unity console output to understand what has happened and check for errors

> It's recommended to learn about the structure of the Unity export you have just made so you understand how it works: see [the documentation for Android](https://docs.unity3d.com/Manual/UnityasaLibrary-Android.html) and the [documentation for iOS](https://docs.unity3d.com/Manual/UnityasaLibrary-iOS.html). The export script takes these structures and modifies them for easier integration into Flutter: the Unity console output tells you what changes have been made

The Unity project is now ready to use, but we still haven't actually linked it to our Flutter app.


## Link exported Unity project to your Flutter project

### iOS

- In Xcode, open your app's `<your flutter project>/ios/Runner.xcworkspace`. It's **very important** to make sure you are opening the `xcworkspace` and not the `xcproj`: [workspaces](https://developer.apple.com/documentation/xcode/managing-multiple-projects-and-their-dependencies) are designed for combining multiple projects (in this case, the Runner project for your Flutter app and the exported Unity project)
- In the project navigator, make sure nothing is selected
- From Xcode toolbar, select `File -> Add files to "Runner"` and select `<your flutter project>/ios/UnityLibrary/Unity-Iphone.xcodeproj`. This should add the Unity-iPhone project to your workspace at the same level as the Runner and Pods projects (if you accidentally added it as a child of Runner, right-click Unity-iPhone, choose Delete, then choose Remove Reference. Then *make sure nothing is selected* and try again). Alternatively, you can drag-and-drop Unity-Iphone.xcodeproj into the project navigator, again ensuring that you drop it at the root of the tree (at the same level as Runner and Pods)

![image](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/72dfc0dd-9b68-4c4f-ae6f-5a2c6de2feae)


-------- Must be done after every export --------
The exported Unity project contains a project and target called Unity-iPhone, which is a thin 'launcher' app for Unity which you can build and deploy as a stand-alone app. Instead, we want to embed everything (the Unity engine and our Unity game) into our own Flutter app as a single framework file (UnityFramework). To do that, we need to change the Target Membership of the Data folder to be UnityFramework instead of the default Unity-iPhone:
In project navigator, expand Unity-iPhone project, and select the Data folder. In the Inspector, under Target Membership, change the target membership to UnityFramework.

![image](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/005ff072-46a0-48fe-8ba9-9c82f36fa835)

To be able to pass messages from Unity C# to the iOS part of the plugin (which then passes the message on to Flutter) the C# file you include in your Unity project declares (but does not define) a function called `FlutterEmbedUnityIos_sendToFlutter`. This function is instead defined in the plugin. To join these two things together, we need to tell Xcode to ignore the fact that `FlutterEmbedUnityIos_sendToFlutter` is not defined in the Unity module, and instead link it to the definition in the plugin:

In project navigator, select Unity-iPhone project, then in the editor select the Unity-iPhone project under PROJECTS, then select the Build Settings tab. In the Build Settings tab, find the 'Other linker Flags' setting (you can use the search box to help you find it). Add the following as a setting: `-Wl,-U,_FlutterEmbedUnityIos_sendToFlutter`

![image](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/28d59a25-7b2a-4f7e-b70e-2611830bf8a9)

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

![image](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/1b1d5378-c4fc-4a39-b930-ec7626a44f7d)


add the exported unity project to the gradle build using an `include` in android/settings.gradle:
- Add to android/settings.gradle:

include ':unityLibrary'


![image](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/dea1b772-1a81-4083-8637-f99cfb9759cd)


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

![image](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/6492c00b-defb-470b-9ca7-b94aedbb6e2d)



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

![image](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/ad9b7a2c-0e1e-4c57-8be5-fc78bbb6cce0)


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
