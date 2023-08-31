# flutter_embed_unity

Embed [Unity 3D](https://unity.com/) into Flutter apps using [Unity as a library](https://docs.unity3d.com/Manual/UnityasaLibrary.html)

![ezgif-3-432510b499](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/cc69185e-bb84-4ed6-a778-1705a85798fb)

# Limitations

## Only supports Unity 2022.3 LTS
[Unity as a library](https://docs.unity3d.com/Manual/UnityasaLibrary.html) was only intended by Unity to be used fullscreen (running in it's own `UnityPlayerActivity.java` Activity on Android, or using `UnityAppController.mm` as the root UIViewController on iOS). By embedding Unity into a Flutter widget, this plugin breaks this assumption, calls undocumented functions written by Unity.

> [!IMPORTANT]
> It is **very important that you only use the Unity version which this plugin supports**, which is currently [Unity 2022.3 LTS (Long Term Support)](https://unity.com/releases/lts). Failure to do this will likely lead to crashes at runtime, because the undocumented functions this plugin calls can change and the workarounds it implements may not work as expected.

## Flutter 3.3+

Due to [an issue](https://github.com/flutter/flutter/issues/103630) with prior versions of Flutter 3, 3.3+ is required

## Android 22+, iOS 12.0+

Unity 2022.3 LTS [only supports Android 5.1 “Lollipop” (API level 22) and above](https://docs.unity3d.com/Manual/android-requirements-and-compatibility.html) and [iOS 12 and above](https://docs.unity3d.com/Manual/ios-requirements-and-compatibility.html) so your app must also observe these limitations

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

## No support for Simulators

You will not be able to run your Flutter app on a simulator when using this plugin. Use real devices for development and testing.

Since Unity 2019.3, [Unity no longer supports Android x86](https://blog.unity.com/technology/android-support-update-64-bit-and-app-bundles-backported-to-2017-4-lts). This means that it cannot be run in an Android emulators. If you are NOT using AR / VR features, it may be possible to use an iOS simulator by changing the Target SDK in Unity Player Settings, but this is untested and unsupported.


## Alternatives
If you need to support other versions of unity, consider using [flutter_unity_widget](https://pub.dev/packages/flutter_unity_widget) or [consult the Wiki](https://github.com/jamesncl/flutter_embed_unity/wiki) for pointers on how to contribute your own packages targeting different versions of Unity

Flutter Forward 2023 demonstrated [an early preview of 3D support directly in Dart using Impeller](https://www.youtube.com/watch?v=zKQYGKAe5W8&t=7067s&ab_channel=Flutter).


# Setup

## Configure Unity

- Install [the latest Unity 2022.3 LTS](https://unity.com/releases/lts) (See limitations above - you MUST use this version of Unity)
- Either open an existing Unity project (it must be configured to use [the Universal Render Pipeline](https://docs.unity3d.com/Manual/universal-render-pipeline.html)), or create a new one using the `3D (URP) Core` template
- In Unity, make sure to select the appropriate build platform: go to `File -> Build Settings` and select either Android or iOS, then click `Switch Platform`
- In Unity, go to `File -> Build Settings -> Player Settings -> Other settings`, and make the following changes:
  - Find [`Scripting backend`](https://docs.unity3d.com/Manual/scripting-backends.html) and set this to [`IL2CPP`](https://docs.unity3d.com/Manual/IL2CPP.html)
- **Optional:** find `IL2CPP code generation` and `C++ Compiler Configuration`, and set to `Faster runtime` and `Release` if you are doing a release build and want your app to run as fast as possible (this will increase the build time significantly) or `faster build` and `Debug` if you are developing, want better error messages and want to build / iterate as fast as possible

 
### Additional Unity configuration for Android

- In Unity, go to `File -> Build Settings`, and enable the `Export project` tickbox
  
> This means that when Unity builds, it [builds as a library which we can import](https://docs.unity3d.com/2022.1/Documentation/Manual/android-export-process.html) into Flutter.

- In Unity, go to `File -> Build Settings -> Player Settings -> Other settings`, and make the d following changes:
  - Find `Target API level`: it's not required, but recommended, to set this to the same target API level of your Flutter project's `android` app (this is usually set in `<your flutter project>/android/app/build.grade` as `targetSdkVersion`)
  - Find `Target Architechtures` and enable ARMv7 and ARM64
  
> Google Play [requires 64 bit apps](https://developer.android.com/google/play/requirements/64-bit), which is why we have to use IL2CPP and enable ARM64


## Import Unity package

To allow Unity to send messages to Flutter, and to make exporting your Unity project into Flutter easier, this plugin includes some Unity scripts which you should import into your Unity project.

- Go to [the releases for this plugin on Github](https://github.com/jamesncl/flutter_embed_unity/releases)
- Find the release which matches the one you have used to add this plugin to your `pubspec.yaml`
- Expand `Assets`
- Download the file `flutter_embed_unity_2022_3.unitypackage`

![1](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/ef5ba891-cdbd-4a97-87c5-0da34850cf6b)


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
            CultureInfo.InvariantCulture
        );
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

![2](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/ca369db9-1991-4093-8713-5e68b0ddac17)



- **This must be repeated every time you export your Unity project:** In project navigator, expand the `Unity-iPhone` project, and select the `Data` folder. In the Inspector, under Target Membership, change the target membership to `UnityFramework`.
  
![3](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/791b13cb-0864-4636-98ae-fb3e327b671a)

> This allows you to embed the Unity engine and your Unity game easily into your own Flutter app as a single unit.

- **This must be repeated every time you export your Unity project:** In project navigator, select the `Unity-iPhone` project, then in the editor select the `Unity-iPhone` project under PROJECTS, then select the Build Settings tab. In the Build Settings tab, find the 'Other linker Flags' setting (you can use the search box to help you find it). Add the following : `-Wl,-U,_FlutterEmbedUnityIos_sendToFlutter`

![4](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/c66d164f-1da1-4f2a-a640-615cd9b05b0a)


> To be able to pass messages from Unity C# to the iOS part of the plugin (which then passes the message on to Flutter) the C# file you include in your Unity project declares (but does not define) a function called `FlutterEmbedUnityIos_sendToFlutter`. This function is instead defined in the plugin. To join these two things together, we need to tell Xcode to ignore the fact that `FlutterEmbedUnityIos_sendToFlutter` is not defined in the Unity module, and instead link it to the definition in the plugin.
> `-Wl` allows us to pass additional options to the linker when it is invoked
> `-U` tells the linker to force the symbol `_FlutterEmbedUnityIos_sendToFlutter` to be entered in the output file as an undefined symbol. It will be linked instead to a function defined in the plugin.


### Android

- Add the Unity project as a dependency to your app by adding the following to `<your flutter project>/android/app/build.gradle`:
```
dependencies {
    implementation project(':unityLibrary')
}
```

![5](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/ef5b0f5e-8c1b-45cd-b5ec-a443d18c7f8f)


- Add the exported unity project to the gradle build by including it in `<your flutter project>/android/settings.gradle`:
```
include ':unityLibrary'
```

![6](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/3d1e87d0-2aeb-40ef-877c-bac722a709ae)


Add the Unity export directory as a repository so gradle can find required libraries / AARs etc in `<your flutter project>/android/build.gradle`:

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

![7](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/afd05061-e800-4200-a085-fa8828875b15)


- Add to android/gradle.properties:

```
unityStreamingAssets=
```
![8](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/c158abc4-b761-4705-b815-0e04c684d21f)


> By default, Unity references `unityStreamingAssets` in it's exported project build.gradle, and provides the definition in the gradle.properties of the thin launcher app. Because we are using a Flutter app rather than the provided launcher, we need to add the same definition to our own gradle.properites, otherwise you will get a build error `Could not get unknown property 'unityStreamingAssets'`


## If you're using XR (VR / AR) on Android

If you are using XR features in Unity (eg ARFoundation) you need to perform some additional configuration on your project. First, make sure you check Unity's project validation checks: in your Unity project, go to `Project Settings -> XR Plug-in Management -> Project Validation`, and fix any problems.

- Add the following to your `android/settings.gradle`:

```
// This additional project is required to build with Unity XR:
include ':unityLibrary:xrmanifest.androidlib'
```
> In your exported `unityLibrary` you may find an extra project folder called `xrmanifest.androidlib`. The Unity project depends on this, so you need to inlcude it in your app's build.

- Find your `MainActivity` class (this is usually located at `<flutter project>\android\app\src\main\kotlin\com\<your org>\MainActivity.kt` or `<flutter project>\android\app\src\main\java\com\<your org>\MainActivity.java`). If your `MainActivity` extends `FlutterActivity`, you can simply change it to extend `FakeUnityPlayerActivity` instead of `FlutterActivity` (`FakeUnityPlayerActivity` also extends `FlutterActivity`). This is the simplest option, as nothing else needs to be done:

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

- Otherwise, if your `MainActivity` extends something else (for example `FlutterFragmentActivity` or your own custom Activity) it may be easier to make your `MainActivity` implement `IFakeUnityPlayerActivity`. If you do this, you MUST also create a public field of type `Object` (for Java) or `Any?` (for Kotlin) in your `MainActivity` called `mUnityPlayer`, and set this via the interface function:

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

> This is to work around the fact that Unity as a library was designed to run in a custom activity made by Unity (you can find this in `unityLibrary\src\main\java\com\unity3d\player\UnityPlayerActivity.java`). Unfortunately, some Unity code expects to be able to find some properties in the activity hosting the Unity player - specifically, a field called `mUnityPlayer`. If it doesn't find this field, your app will crash when your XR code initialises with the following error:
>
> `Non-fatal Exception: java.lang.Exception: AndroidJavaException : java.lang.NoSuchFieldError: no "Ljava/lang/Object;" field "mUnityPlayer" in class "Lcom/example/app/MainActivity;" or its superclasses`
> 
> Because this plugin is designed to embed Unity in a widget, not in an activity, we need to make our MainActivity 'pretend' like it's a `UnityPlayerActivity` by giving it a `mUnityPlayer` field which can be set by the plugin when the `UnityPlayer` is created. 


# Using the plugin

You should now be able to use the plugin! 

- Add the dependency to `flutter_embed_unity` to your `pubspec.yaml` and then `flutter pub get`
- Simply drop the `EmbedUnity` widget where you want to render Unity. For example:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

class Example extends StatelessWidget {
  
  const Example();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmbedUnity(
        onMessageFromUnity: (String message) {
          // Receive message from Unity sent via SendToFlutter.cs
        },
      ),
    );
  }
}
```

The first time the widget is rendered, Unity will start and the first active scene will load.

To receive messages from Unity, use the optional `onMessageFromUnity` parameter (See also 'Sending messages from Flutter to Unity' section above)

To send messages to a game object in Unity, simply call the top level function `sendToUnity`:

```dart
sendToUnity(
    "MyGameObject",  // The name of the Unity game object
    "SetRotationSpeed",  // The name of a public function attached to the game object in a MonoBehaviour script
    "42",  // The message to send
);
```

This will send a message to the given game object in the active scene. Note that the scene must be loaded - see the next section.

When the `EmbedUnity` widget is disposed, Unity will be 'paused' (game time will stop), and resumed the next time a `EmbedUnity` is rendered.

After Unity is loaded, subsequent usages of `sendToUnity` will still work, and will be received by Unity, even if there is no `EmbedUnity` widget in the tree and even though Unity is 'paused'. This is because Unity cannot be shut down when loaded (see Limitations above).

> Important! Only one `EmbedUnity` widget can be used in a route / screen at a time. Using more than one is not supported (see Limitations above). You can push a new route onto the stack with a second `EmbedUnity`: if you do this, Unity will be detatched from the first `EmbedUnity` widget and attached to the second.


## Waiting for the Unity scene to load

This plugin is designed to be as bare bones as possible, leaving the details up to you. One common task you might need to do is waiting for Unity to load the first scene before sending any messages. As an example of how to do this, add the following script to a game object in your Unity project:

```csharp
using UnityEngine;
using UnityEngine.SceneManagement;

public class SendToFlutterSceneLoaded : MonoBehaviour
{
    void OnEnable()
    {
        SceneManager.sceneLoaded += OnSceneLoaded;
    }

    void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        SendToFlutter.Send("scene_loaded");
    }

    // called when the game is terminated
    void OnDisable()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded;
    }
}

```

Then in your Flutter project:

```dart
EmbedUnity(
    onMessageFromUnity: (String data) {
        if(data == "scene_loaded") {
            // Start sending messages to Unity
        }
    }
)
```


## Manually pausing and resuming

If you need, you can manually pause and resume Unity using the top level functions `pauseUnity` and `resumeUnity`:

```
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

...

ElevatedButton(
    onPressed: () {
        pauseUnity();
    },
    child: const Text("Pause"),
),
```


# Common issues

## libmain.so not found

If you are attempting to run your app on an Android emulator, you will encounter this error. As noted above in the limitations, this is not supported. Use a real device instead.

## No such module UnityFramework

1. Make sure you have carefully done all the steps outlined here
2. In Xcode, in the top bar to the right of the Run button (the one shaped like a triangular Play button), change the target from Runner to UnityFramework. Then press ⌘+B to build UnityFramework. Then do the same for the Unity-iPhone target. Finally, change back to the Runner target and attempt to build again.
3. See https://stackoverflow.com/questions/29500227/getting-error-no-such-module-using-xcode-but-the-framework-is-there


# Plugin developers / contributors

See [the Wiki for more information](https://github.com/jamesncl/flutter_embed_unity/wiki) on running the example, notes on how the plugin works, developing for different versions of Unity etc.
				
