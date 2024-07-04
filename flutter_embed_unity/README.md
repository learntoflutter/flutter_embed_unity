# flutter_embed_unity

Embed your [Unity 3D](https://unity.com/) game / app into Flutter apps as a widget on iOS and Android. Transfer messages between Unity scripts and your Flutter app. Only supports a single instance of Unity 2022.3 LTS. Supports Unity ARFoundation / ARKit / ARCore.

![ezgif com-resize](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/e4dd706d-9c0c-4365-8740-d374afa49ebb)

# Usage

After setting up your Unity and Flutter project (see below), use `EmbedUnity` to show your Unity game and listen to messages sent from your Unity scripts. Use the top level dart function `sendToUnity` to send messages from Flutter to any game object in Unity which has a `MonoBehaviour` script attached containing a public function accepting one `string` parameter.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          Expanded(
            child: EmbedUnity(
              onMessageFromUnity: (String message) {
                // Receive message from Unity
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Send message to Unity
              sendToUnity(
                "MyGameObject",  // Game object name
                "SetRotationSpeed",  // Unity script function name
                "42",  // Message
              );
            },
            child: const Text("Set rotation speed"),
          )
        ],
      ),
    ),
  ));
}

```

In your Unity scripts, use `SendToFlutter` to send messages to your `EmbedUnity` widget:

```csharp
public class MyGameObjectScript : MonoBehaviour
{
    void Update()
    {
        if (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began)
        {
             // Send message to Flutter:
             SendToFlutter.Send("touch");
        }
    }

    // Called from Flutter:
    public void SetRotationSpeed(string message)
    {
        // Do something with message
    }
}
```

There is [an example Unity project](https://github.com/learntoflutter/flutter_embed_unity/tree/main/example_unity_2022_3_project) you can use to get started - check out the repository to try it out, and consult [the wiki](https://github.com/learntoflutter/flutter_embed_unity/wiki) and the example project documentation [for iOS](https://github.com/learntoflutter/flutter_embed_unity/tree/main/flutter_embed_unity_2022_3_ios/example) and [for Android](https://github.com/learntoflutter/flutter_embed_unity/tree/main/flutter_embed_unity_2022_3_android) for instructions on running the examples. 

# Limitations

## Only supports certain versions of Unity 2022.3 LTS

> [!IMPORTANT]
> It is **very important that you only use the Unity versions listed below**. Failure to do this will likely lead to crashes at runtime, because the undocumented functions this plugin calls can change and the workarounds it implements may not work as expected.

* For iOS, as of 1st May 2024, 2022.3.21 or later is required due to App Store requirements around apps and 3rd party SDKs (including Unity) [declaring required reason API usage using Privacy Manifests](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api). See [this announcement from Unity](https://forum.unity.com/threads/apple-privacy-manifest-updates-for-unity-engine.1529026/) for more information.
* For Android 9 and later, any [Unity 2022.3 LTS](https://unity.com/releases/lts) is supported
* For Android 8 and earlier, due to [issue #15](https://github.com/learntoflutter/flutter_embed_unity/issues/15), any version of Unity 2022.3 is supported **EXCEPT for 2022.3.10 to 2022.3.18** inclusive

[Unity as a library](https://docs.unity3d.com/Manual/UnityasaLibrary.html) was only intended by Unity to be used fullscreen (running in it's own `UnityPlayerActivity.java` Activity on Android, or using `UnityAppController.mm` as the root UIViewController on iOS). By embedding Unity into a Flutter widget, this plugin breaks this assumption, making it quite delicate. It also calls undocumented functions written by Unity, and implements various workarounds, which is why this plugin will not work with different versions of Unity. If you need support for different versions, this package is [federated](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins) to allow easier extension by contributors for different versions of Unity using alternate platform packages - [consult the wiki for help developing and contributing your own.](https://github.com/learntoflutter/flutter_embed_unity/wiki).

## Only supports Flutter 3.3.x, 3.7.x, 3.10.x, 3.13.x, 3.22.x or later

Due to various issues in Flutter support for native platform views, only certain versions of Flutter are currently supported:

* [Flutter #103630: Platform views are drawn at the wrong position and don't fill the parent](https://github.com/flutter/flutter/issues/103630) (affects Flutter 3.0.x)
* [Flutter #141068: Flutter 3.16 regression - Virtual display platform view is invisible on Android < 10](https://github.com/flutter/flutter/issues/141068) (affects Flutter 3.16.x and 3.19.x)
* [Flutter #142952: Virtual display - Buggy resize with Android 12+](https://github.com/flutter/flutter/issues/142952) (affects Flutter 3.19.x)

This is being tracked in [#12](https://github.com/learntoflutter/flutter_embed_unity/issues/12) and [#14](https://github.com/learntoflutter/flutter_embed_unity/issues/14) (many thanks to [@timbotimbo](https://github.com/timbotimbo))

## Android 22+, iOS 12.0+

Unity 2022.3 LTS [only supports Android 5.1 “Lollipop” (API level 22) and above](https://docs.unity3d.com/Manual/android-requirements-and-compatibility.html) and [iOS 12 and above](https://docs.unity3d.com/Manual/ios-requirements-and-compatibility.html) so your app must also observe these limitations.

In `<your flutter app>/android/app/build.gradle` check your `minSdkVersion` is at least 22:

```
android {
    ...
    defaultConfig {
        // Unity 2022.3 requires Android 22 or higher
        minSdkVersion 22
    }
}
```

And in `<your flutter app>/ios/Podfile` make sure the ios platform requirement is at least 12:

```
# Unity 2022.3 requires iOS 12 or higher
platform :ios, '12.0'
```


## Gradle 7.2

Unity 2022.3 LTS [only supports Gradle 7.2 / Android Gradle Plugin (AGP) 7.1.2](https://docs.unity3d.com/Manual/android-gradle-overview.html), so you should use these versions in the Android part of your Flutter app to avoid build problems (especially if you are using Unity AR / XR). Do this by specifying **7.1.2** as the AGP version in `<your flutter app>/android/build.gradle`:

```
buildscript {
    ...

    dependencies {
		...
        classpath 'com.android.tools.build:gradle:7.1.2'
    }
}
```

You will also need to specify that the related version of Gradle which works with AGP 7.1.2, which is Gradle **7.2**, should be used in `<your flutter app>/android/gradle/wrapper/gradle-wrapper.properties`:

```
distributionUrl=https\://services.gradle.org/distributions/gradle-7.2-all.zip
```



## Only 1 instance
Unity can only render in 1 widget at a time. Therefore, you can only use one `EmbedUnity` widget on a Flutter screen. If another screen is pushed onto the navigator stack, Unity will be detatched from the first screen and attached to the second screen. If the second screen is popped, Unity will be reattached back to the first screen.

## Memory usage
Running Unity has a significant impact on memory usage, in addition to that already used by Flutter, so may not work well on low-end devices. After the first `EmbedUnity` widget is shown on screen and Unity loads, Unity will remain in memory in the background (but paused) even after the widget has been disposed. This is because embedded Unity does not support shutting down without shutting down the entire app. See [the official limitations for more details](https://docs.unity3d.com/Manual/UnityasaLibrary.html).

## android:configChanges
On Android, if the Activity it runs in is destroyed, Unity will kill the entire app. As a consequence, we cannot handle the main FlutterActivity being destroyed, for example on orientation change. Therefore you must make sure that `android:configChanges` on the `MainActivity` of the app in the `android` subfolder of your Flutter project includes at least orientation, screenLayout, screenSize and keyboardHidden (to prevent the Activity being destroyed when these events occur) and ideally all the values included in the default configuration:

```
android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
```

Failure to do this will mean your app will crash on orientation change. See [the `android:configChanges` documentation](https://developer.android.com/guide/topics/manifest/activity-element#config) and [Android configuration changes documentation](https://developer.android.com/guide/topics/resources/runtime-changes) for more.

## No support for Simulators

You will not be able to run your Flutter app on a simulator when using this plugin. Use real devices for development and testing.

Since Unity 2019.3, [Unity no longer supports Android x86](https://blog.unity.com/technology/android-support-update-64-bit-and-app-bundles-backported-to-2017-4-lts). This means that it cannot be run in an Android emulators. If you are not using AR / VR features, it MAY be possible to use an iOS simulator by changing the Target SDK in Unity Player Settings, but this is untested and unsupported.


## Alternatives
If you need to support other versions of unity, consider using [flutter_unity_widget](https://pub.dev/packages/flutter_unity_widget) or [consult the Wiki](https://github.com/learntoflutter/flutter_embed_unity/wiki) for pointers on how to contribute your own packages targeting different versions of Unity

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
- In Unity, go to `File -> Build Settings -> Player Settings -> Other settings`, and make the d following changes:
  - Find `Target API level`: it's not required, but recommended, to set this to the same target API level of your Flutter project's `android` app (this is usually set in `<your flutter project>/android/app/build.grade` as `targetSdkVersion`)
  - Find `Target Architechtures` and enable ARMv7 and ARM64
  
> Google Play [requires 64 bit apps](https://developer.android.com/google/play/requirements/64-bit), which is why we have to use IL2CPP and enable ARM64


## Import Unity package

To allow Unity to send messages to Flutter, and to make exporting your Unity project into Flutter easier, this plugin includes some Unity scripts which you should import into your Unity project.

- Go to [the releases for this plugin on Github](https://github.com/learntoflutter/flutter_embed_unity/releases) and find the version of this plugin you are using (the version you [add to your `pubspec.yaml`](https://pub.dev/packages/flutter_embed_unity/install))
- Expand `Assets` and download the file `flutter_embed_unity_2022_3.unitypackage`.

![1](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/92a25bd6-29a7-4caf-bf6d-399d2ecd8f06)


- In Unity, go to `Assets -> import package -> Custom package`, and choose the file you just downloaded
- The package includes two folders: `FlutterEmbed` which contains scripts which are REQUIRED to run the plugin, and `Example` which contains an optional example scene and AR scene which demonstrates how to use the plugin (this includes dependencies on ARFoundation - if you don't need the example you can untick these from the import package selection).

![import](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/3641f1a2-8fb3-40cf-9a16-bfca9919e214)


> [!NOTE]
> As an alternative to importing `flutter_embed_unity_2022_3.unitypackage`, you can browse the source which this package is made from in [the example Unity project](https://github.com/learntoflutter/flutter_embed_unity/tree/main/example_unity_2022_3_project), or use the example project as a template for your own project.

## Setup messaging in Unity

### Receiving messages from Flutter in Unity

In Flutter you can directly call any public method of any `MonoBehaviour` script attached to a game object in the active scene which has a single `string` parameter. The Example scene from the package includes an example of this in `ReceiveFromFlutterRotation.cs`. In this example, `SetRotationSpeed` can be called directly from Flutter. This script is attached to a flutter logo game object, and allows Flutter to control the rotation speed:

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

![Screenshot 2023-09-15 153150](https://github.com/learntoflutter/flutter_embed_unity/assets/145048332/77cefebb-f5d0-4759-b23f-04ffdaca4c01)

> If you can't find this menu item, make sure you have imported the flutter_embed_unity_2022_3.unitypackage
  
- The export script will make some checks for you (follow any instructions which appear)
- When asked, select the `unityLibrary` export folder you created
- Wait for the project to build, then check the Unity console output to understand what has happened and check for errors

> To learn about the structure of the Unity export you have just made, see [the documentation for Android](https://docs.unity3d.com/Manual/UnityasaLibrary-Android.html) and the [documentation for iOS](https://docs.unity3d.com/Manual/UnityasaLibrary-iOS.html). The export script takes these structures and modifies them for easier integration into Flutter: the Unity console output tells you what changes have been made

The Unity project is now ready to use, but we still haven't actually linked it to our Flutter app.


## Link exported Unity project to your Flutter project

### iOS

- In Xcode, open your app's `<your flutter project>/ios/Runner.xcworkspace`. It's **very important** to make sure you are opening the `xcworkspace` and not the `xcproj`: [workspaces](https://developer.apple.com/documentation/xcode/managing-multiple-projects-and-their-dependencies) are designed for combining multiple projects (in this case, the Runner project for your Flutter app and the exported Unity project)
- In the project navigator, make sure nothing is selected
- From Xcode toolbar, select `File -> Add files to "Runner"` and select `<your flutter project>/ios/UnityLibrary/Unity-Iphone.xcodeproj`. This should add the Unity-iPhone project to your workspace at the same level as the Runner and Pods projects (if you accidentally added it as a child of Runner, right-click Unity-iPhone, choose Delete, then choose Remove Reference. Then *make sure nothing is selected* and try again). Alternatively, you can drag-and-drop Unity-Iphone.xcodeproj into the project navigator, again ensuring that you drop it at the root of the tree (at the same level as Runner and Pods)

![2](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/ca369db9-1991-4093-8713-5e68b0ddac17)


### Android

- Add the Unity project as a dependency to your app by adding the following to `<your flutter project>/android/app/build.gradle`:
```
dependencies {
    implementation project(':unityLibrary')
}
```

![5](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/04e44ff4-755c-457b-9267-d9c4735559fc)



- Add the exported unity project to the gradle build by including it in `<your flutter project>/android/settings.gradle`:
```
include ':unityLibrary'
```

![6](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/11721c31-2d76-4451-81bf-c0a9fa4bd62e)


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

![7](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/56097d90-4707-4375-ba33-4e5d65cae104)

- Add to android/gradle.properties:

```
unityStreamingAssets=
```

![8](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/b705d075-175c-4bd6-a126-422d83670d30)

> By default, Unity references `unityStreamingAssets` in it's exported project build.gradle, and provides the definition in the gradle.properties of the thin launcher app. Because we are using a Flutter app rather than the provided launcher, we need to add the same definition to our own gradle.properites, otherwise you will get a build error `Could not get unknown property 'unityStreamingAssets'`


## If you're using XR (VR / AR) on Android

If you are using XR features in Unity (eg ARFoundation) you need to perform some additional configuration on your project. First, make sure you check Unity's project validation checks: in your Unity project, go to `Project Settings -> XR Plug-in Management -> Project Validation`, and fix any problems.

- Add `include ':unityLibrary:xrmanifest.androidlib'` to your `android/settings.gradle`:

![6b](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/3a51afd3-0d3c-4fe9-8bc1-be67daff6e74)


> In your exported `unityLibrary` you may find an extra project folder called `xrmanifest.androidlib`. The Unity project depends on this, so you need to inlcude it in your app's build.

- Find your `MainActivity` class (this is usually located at `<flutter project>\android\app\src\main\kotlin\com\<your org>\MainActivity.kt` or `<flutter project>\android\app\src\main\java\com\<your org>\MainActivity.java`). If your `MainActivity` extends `FlutterActivity`, you can simply change it to extend `FakeUnityPlayerActivity` instead of `FlutterActivity` (`FakeUnityPlayerActivity` also extends `FlutterActivity`). This is the simplest option, as nothing else needs to be done:

```java
import com.learntoflutter.flutter_embed_unity_android.unity.FakeUnityPlayerActivity;

public class MainActivity extends FakeUnityPlayerActivity {
	
}
```

```kotlin
import com.learntoflutter.flutter_embed_unity_android.unity.FakeUnityPlayerActivity

class MainActivity: FakeUnityPlayerActivity() {
    
}

```

- Otherwise, if your `MainActivity` extends something else (for example `FlutterFragmentActivity` or your own custom Activity) it may be easier to make your `MainActivity` implement `IFakeUnityPlayerActivity`. If you do this, you MUST also create a public field of type `Object` (for Java) or `Any?` (for Kotlin) in your `MainActivity` called `mUnityPlayer`, and set this via the interface function:

```java
import com.learntoflutter.flutter_embed_unity_android.unity.IFakeUnityPlayerActivity;

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

Unity can take a few seconds to load the first time it is rendered. Therefore one common task you might need to do is wait for Unity to load the first scene before sending any messages. Here's an example of how you might do this. Add the following script to a game object in your Unity scene:

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
            // Now you can start sending messages to Unity
        }
    }
)
```

> [!NOTE]
> Unity only loads once. When `EmbedUnity` widget is disposed, your scene is still loaded in the background, so in this example when you create a new `EmbedUnity` a second time, the scene is already loaded.


## Manually pausing and resuming

You can manually pause and resume Unity using the top level functions `pauseUnity` and `resumeUnity`. This does not unload Unity from memory: it simply pauses the 'game time'. You can still pass messages to Unity game objects when Unity is paused. When `EmbedUnity` is disposed, it pauses Unity automatically for you, and resumes it when `EmbedUnity` is created again.

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


## Using more than one instance of `EmbedUnity`

Unity can only be shown in 1 widget at a time. This is a limitation with Unity itself. Because of this, flutter_embed_unity only supports using a single `EmbedUnity` per Flutter screen / route, and Unity will only be displayed on the 'current' route (top-most in the stack).

For example, if you have a screen containing an `EmbedUnity` (Screen 1), you can push another screen / dialog / route etc onto the navigation stack (Screen 2) containing another `EmbedUnity`. Unity will be detached from the `EmbedUnity` in Screen 1 and be shown on Screen 2. When Screen 2 is popped from the stack, Unity is detached from Screen 2 and reattached to Screen 1.

![Stacking illustration](https://github.com/learntoflutter/flutter_embed_unity/assets/15979056/473c22c8-927a-43bf-82de-1fcabae4c72e)

Note that in the example above, even though Unity is detached from Screen 1 and 2, by default **all `EmbedUnity` widgets on all screens will still receive messages via `onMessageFromUnity`**. To avoid processing duplicate messages, you can configure it to only send messages to the `EmbedUnity` which was created most recently (which will usually be the one on the 'top' of the navigation stack):

```dart
EmbedUnityPreferences.messageFromUnityListeningBehaviour =
  MessageFromUnityListeningBehaviour.onlyMostRecentlyCreatedWidgetReceivesMessages;
```

Currently, having two instances of `EmbedUnity` on the same screen is not supported.


# Common issues

## Export incomplete: AndroidManifest.xml not found

There is [an issue with some versions of Unity 2022.3](https://issuetracker.unity3d.com/issues/android-xr-xr-management-package-equals-4-dot-3-1-deletes-unitylibrary-androidmanifest-dot-xml-when-exporting-a-gradle-build) which causes the following error when attempting to export the project using the plugin export script with AR packages enabled:

![265426774-9fcb0274-1502-4e38-8d3b-bc86e7a04c98](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/9f3a6cff-b333-4a41-98a0-293f9b0b8179)

This is caused by a broken version of a Unity package called `com.unity.xr.management` which is a depencency of AR Foundation, Google ARCore XR Plugin and Apple ARKit XR Plugin. This issue [is fixed in version 4.4+](https://issuetracker.unity3d.com/issues/android-xr-xr-management-package-equals-4-dot-3-1-deletes-unitylibrary-androidmanifest-dot-xml-when-exporting-a-gradle-build) of com.unity.xr.management, however you may need to manually pin this version until the parent packages are updated to use this newer version. To do this, in your Unity project, open `<your unity project>/Packages/manifest.json` and add `"com.unity.xr.management": "4.4.0",`:

![xr management fix](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/39e9c102-f870-4162-976d-85ca23a5ca2b)


## libmain.so not found

If you are attempting to run your app on an Android emulator, you will encounter this error. As noted above in the limitations, this is not supported. Use a real device instead.


## Undefined symbol: _FlutterEmbedUnityIos_sendToFlutter

In versions prior to 1.1.1, some additional manual steps were required to link the Unity project to your Xcode project. As of 1.2.0 these are now automated as part of the Unity export process. Check the [Changelog release notes](https://pub.dev/packages/flutter_embed_unity/changelog) for 1.2.0 to see how to update to the new export process. Alternatively, you can do the following step manually after each export: In project navigator, select the Unity-iPhone project, then in the editor select the Unity-iPhone project under PROJECTS, then select the Build Settings tab. In the Build Settings tab, find the 'Other linker Flags' setting (you can use the search box to help you find it). Add the following : `-Wl,-U,_FlutterEmbedUnityIos_sendToFlutter`


## ERROR: could not open UnityFramework.framework/Data/Managed/Metadata/global-metadata.dat, IL2CPP initialization failed

In versions prior to 1.1.1, some additional manual steps were required to link the Unity project to your Xcode project. As of 1.2.0 these are now automated as part of the Unity export process. Check the [Changelog release notes](https://pub.dev/packages/flutter_embed_unity/changelog) for 1.2.0 to see how to update to the new export process. Alternatively, you can do the following step manually after each export: In project navigator, expand the Unity-iPhone project, and select the Data folder. In the Inspector, under Target Membership, change the target membership to UnityFramework.


## Project with path 'xrmanifest.androidlib' could not be found in project ':unityLibrary'

You are using AR packages in your Unity project but you have forgotten to follow the instuctions above in the section titled "If you're using XR (VR / AR) on Android"


## A problem occurred configuring project ':unityLibrary:xrmanifest.androidlib' - Could not create an instance of type com.android.build.api.variant.impl.LibraryVariantBuilderImpl - Namespace not specified. Please specify a namespace in the module's build.gradle file

This is caused by the fact that you are using Gradle 8 or higher in the Android part of your Flutter app, but Unity 2022.3 does not support this. The gradle version is usually specified in `<your flutter project>/android/build.gradle`, for example:

```gradle
dependencies {
	...
    classpath 'com.android.tools.build:gradle:8.0.2'   <-- This is the problem
}
```

See the Limitations section above for instructions on how to set the correct gradle version for your app.


## Could not find :arcore_client: / :ARPresto: / :UnityARCore: etc.

Check you have followed the instructions about linking Unity to your Android project. Specifically, make sure you have added the unityLibrary flatDir to the correct place in you `build.gradle` (it goes under the `allprojects` section, not the `buildscript` section).


## Error (Xcode): Multiple commands produce '.../build/ios/Debug-iphoneos/Runner.app/Frameworks/UnityFramework.framework'

This is probably because you have migrated from using the flutter_unity_widget package, where you have to embed & sign UnityFramework.framework into your Runner app. This package includes UnityFramework.framework as part of the plugin, so this step isn't needed, and in fact will mean you end up with UnityFramework twice.

To resolve this, in Xcode, select Runner in the project navigator, then select the Runner target in the editor window. Select the General tab and scroll down to Frameworks, Libraries & Embedded Content. If you have UnityFramework.framework in the list, remove it.


## IL2CPP C++ code builder is unable to build C++ code. In order to build C++ code for Mac, you must have Xcode installed.

> Unable to detect any compatible iPhoneOS SDK!
> at Unity.IL2CPP.Bee.BuildLogic.iOS.iOSBuildLogic.GetCompatibleXcodeInstallation(Architecture architecture, Version xcodeMinVersion, Version platformSdkMinVersion, Identifier platformSdkIdentifier, XcodePlatformSdk& compatiblePlatformSdk, XcodeInstallation& compatibleXcodeInstallation)
> at Unity.IL2CPP.Bee.BuildLogic.iOS.iOSBuildLogic.UserAvailableToolchainFor(Architecture architecture, NPath toolChainPath, NPath sysRootPath, Boolean targetIsSimulator)
> at Unity.IL2CPP.Bee.IL2CPPExeCompileCppBuildProgram.BuildProgram.Main(String[] args, String currentDirectory)
> at Unity.IL2CPP.Building.InProcessBuildProgram.StartImpl(String workingDirectory, String[] arguments) in /Users/bokken/build/output/unity/il2cpp/Unity.IL2CPP.Building/InProcessBuildProgram.cs:line 51
>
> Error: Unity.IL2CPP.Building.BuilderFailedException: Build failed with 0 successful nodes and 0 failed ones
>
> Error: Internal build system error. BuildProgram exited with code 1.
> Unity.IL2CPP.Bee.BuildLogic.ToolchainNotFoundException: IL2CPP C++ code builder is unable to build C++ code. In order to build C++ code for Mac, you must have Xcode installed.
> Building for Apple Silicon requires Xcode 9.4 and Mac 10.12 SDK.

This is caused by an incompatibility between Unity and Xcode 15 which has been fixed in newer versions of Unity. See the following resources:

* [Resolved issue on Unity Issue Tracker](https://issuetracker.unity3d.com/issues/building-projects-with-il2cpp-scripting-backend-for-apple-platforms-fails-with-xcode-15-dot-0b6-or-newer)
* [Unity forum discussion](https://forum.unity.com/threads/project-wont-build-using-xode15-release-candidate.1491761/)

The solution as described in the issue tracker is to update Unity to 2022.3.10 or newer


## Framework not found FBLPromises

This build error can arise when using Firebase packages in your Unity project. To resolve this (thanks to @timbotimbo for the solution):

* Make sure the Unity pods are installed. In the terminal, run `pod install` in the ios/unityLibrary folder

> If you're using a Mac with Apple Silicon and run into cocoapod errors, try `arch -x86_64 pod install --repo-update` instead

* Now use **Add Files to "Runner"** to add `ios/unityLibrary/Pods/Pods.xcodeproj`, just like you have already done with Unity-iPhone

For further info see [#8](https://github.com/learntoflutter/flutter_embed_unity/issues/8)



# Plugin developers / contributors

See [the Wiki for more information](https://github.com/learntoflutter/flutter_embed_unity/wiki) on running the example, notes on how the plugin works, developing for different versions of Unity etc.
				
# Acknowledgements

Thanks to [@cookiejarlid](https://github.com/cookiejarlid) who created [flutter_unity](https://github.com/Glartek/flutter-unity) and [@juicycleff](https://github.com/juicycleff) who created [flutter_unity_widget](https://github.com/juicycleff/flutter-unity-view-widget), they figured out many of the techniques used in this package to get Unity to work with Flutter. Thanks to [@timbotimbo](https://github.com/timbotimbo) for patches to flutter_unity_widget, some of which are also used in this package, and continuing support on this package.
