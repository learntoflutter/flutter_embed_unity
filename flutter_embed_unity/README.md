# flutter_embed_unity

Embed your [Unity 3D](https://unity.com/) game / app into Flutter apps as a widget on iOS and Android. Transfer messages between Unity scripts and your Flutter app. Only supports a single instance of Unity 6 LTS. Unity 2022.3 LTS may work but will no longer be officially supported by this package (2022.3 is no longer supported by Unity, and isn't compatible with Gradle 9+). Limited support for Unity ARFoundation / ARKit / ARCore.

![ezgif com-resize](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/e4dd706d-9c0c-4365-8740-d374afa49ebb)


> [!IMPORTANT]
> Embedding Unity in Flutter is not supported by Unity and involves many moving parts. Consider carefully before commiting to using this plugin, as future changes to Flutter, Unity, Xcode, Swift Package Manager, Gradle, AGP, JVM versions or other build plumbing may unexpectedly break this plugin, which may be difficult to fix. Building your app entirely in Unity, or entirely in Flutter using [Flutter GPU](https://github.com/flutter-team-archive/engine/blob/main/docs/impeller/Flutter-GPU.md) may be a better alternative (see [fscene.dev](https://fscene.dev/) for some great examples of what is possible using Flutter GPU by leveraging the [flutter_scene](https://pub.dev/packages/flutter_scene) package).


# Usage

## Platform implementation override required for Unity 2022.3 LTS on Android

Currently, the default configuration of the plugin supports Unity 6 LTS on Android.

If you are targeting Unity 2022.3 LTS, you now need to explicitly override the default implementation for android from Unity 6 to Unity 2022.3 by adding flutter_embed_unity_2022_3_android as a dependency:

```yaml
dependencies:
  ...
  flutter_embed_unity: ^3.0.0  # (replace version with the latest available)
  flutter_embed_unity_2022_3_android: ^2.0.0  # <-- If using Unity 2022.3, add this (replace version with the latest available)
```

For iOS only, you do not need to add any additional dependency - the default implementation for iOS is compatible with both Unity 6 LTS and Unity 2022.3 LTS.


## Using the EmbedUnity widget

After setting up your Unity and Flutter project (see below), use the `EmbedUnity` widget to show your Unity game and listen to messages sent from your Unity scripts. Use the top level dart function `sendToUnity` to send messages from Flutter to any game object in Unity which has a `MonoBehaviour` script attached containing a public function accepting one `string` parameter.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          Expanded(
            // This will render your Unity project
            child: EmbedUnity(
              onMessageFromUnity: (String message) {
                // Receive message from Unity scripts here
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

There is [an example Unity 2022.3 project](https://github.com/learntoflutter/flutter_embed_unity/tree/main/example_unity_2022_3_project) and [an example Unity 6000.0 project](https://github.com/learntoflutter/flutter_embed_unity/tree/main/example_unity_6000_0_project) you can use to get started - check out the repository to try it out, and consult [the wiki](https://github.com/learntoflutter/flutter_embed_unity/wiki) and the example project READMEs for instructions on running the examples. 


# Limitations


## Unity version support

It is important that you only use the Unity versions listed below. Failure to do this will likely lead to crashes at runtime, because the undocumented functions this plugin calls can change and the workarounds it implements may not work as expected.

[Unity as a library](https://docs.unity3d.com/Manual/UnityasaLibrary.html) was only intended by Unity to be used fullscreen (running in it's own `UnityPlayerActivity.java` Activity on Android, or using `UnityAppController.mm` as the root UIViewController on iOS). By embedding Unity into a Flutter widget, this plugin breaks this assumption, making it quite delicate. It also calls undocumented functions written by Unity, and implements various workarounds, which is why this plugin may not work with different versions of Unity. If you need support for different versions, this package is [federated](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins) to allow easier extension by contributors for different versions of Unity using alternate platform packages - [consult the wiki for help developing and contributing your own.](https://github.com/learntoflutter/flutter_embed_unity/wiki)


### Unity 6 LTS
* For Android, version 6000.3.0f1 or newer or 6000.0.58f2 or newer is required due to a [security update advisory](https://unity.com/security/sept-2025-01).

  <details>
  <summary>Superseded version requirements. (click to expand)</summary>

  * For Android, as of November 1st 2025, 6000.0.38 or later is required due to Google Play
 requirements that all new apps and updates targeting Android 15+ [must support 16 KB page sizes](https://android-developers.googleblog.com/2025/05/prepare-play-apps-for-devices-with-16kb-page-size.html).
  See [this announcement from Unity](https://discussions.unity.com/t/info-unity-engine-support-for-16-kb-memory-page-sizes-android-15/1589588) for more information.
</details>  
* Version 6000.3.17f1+ or newer is [required if you are using Gradle 9+](https://docs.unity3d.com/6000.3/Documentation/Manual/android-gradle-version-compatibility.html)


### Unity 2022.3 LTS

* For Android, version 2022.3.62f2 or newer is required due to a [security update advisory](https://unity.com/security/sept-2025-01). For enterprise clients this is 2022.3.67f2 or newer.
* For iOS, as of 1st May 2024, 2022.3.21 or later is required due to App Store requirements around apps and 3rd party SDKs (including Unity) [declaring required reason API usage using Privacy Manifests](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api). See [this announcement from Unity](https://forum.unity.com/threads/apple-privacy-manifest-updates-for-unity-engine.1529026/) for more information.

  <details>
  <summary>Superseded version requirements. (click to expand) </summary>

  * For Android 8 and earlier, due to [issue #15](https://github.com/learntoflutter/flutter_embed_unity/issues/15), versions 2022.3.10 to 2022.3.18 inclusive are **NOT** supported.
  * For Android, as of November 1st 2025, 2022.3.56 or later is required due to Google Play
 requirements that all new apps and updates targeting Android 15+ (SDK 35) [must support 16 KB page sizes](https://android-developers.googleblog.com/2025/05/prepare-play-apps-for-devices-with-16kb-page-size.html).
  See [this announcement from Unity](https://discussions.unity.com/t/info-unity-engine-support-for-16-kb-memory-page-sizes-android-15/1589588) for more information.
</details>


## Only supports Flutter 3.3.x, 3.7.x, 3.10.x, 3.13.x, 3.22.x or later

Due to various issues in Flutter support for native platform views, only certain versions of Flutter are currently supported:

* [Flutter #103630: Platform views are drawn at the wrong position and don't fill the parent](https://github.com/flutter/flutter/issues/103630) (affects Flutter 3.0.x)
* [Flutter #141068: Flutter 3.16 regression - Virtual display platform view is invisible on Android < 10](https://github.com/flutter/flutter/issues/141068) (affects Flutter 3.16.x and 3.19.x)
* [Flutter #142952: Virtual display - Buggy resize with Android 12+](https://github.com/flutter/flutter/issues/142952) (affects Flutter 3.19.x)

This is being tracked in [#12](https://github.com/learntoflutter/flutter_embed_unity/issues/12) and [#14](https://github.com/learntoflutter/flutter_embed_unity/issues/14) (many thanks to [@timbotimbo](https://github.com/timbotimbo))

Upcoming versions may only support Flutter 3.38 and newer due to [changes to iOS UIScene lifecycle requirements](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate#migration-guide-for-flutter-plugins), this is being tracked in [#71](https://github.com/learntoflutter/flutter_embed_unity/issues/71)


## Known issues with AR when using Flutter 3.22 or later, and Android API 32 (version 12 / Snow Cone) or earlier

Due to [Issue #21](https://github.com/learntoflutter/flutter_embed_unity/issues/21), AR may crash when using Flutter 3.22+ on Android API 32 or earlier. There is currently a workaround available, however this workaround may break in future versions of flutter. The workaround is documented in [Issue #21](https://github.com/learntoflutter/flutter_embed_unity/issues/21) (thanks [@timbotimbo](https://github.com/timbotimbo))


## Minimum versions of Android SDK and iOS

Unity 2022.3 LTS [only supports Android API 22 and above](https://docs.unity3d.com/Manual/android-requirements-and-compatibility.html) and [iOS 12 and above](https://docs.unity3d.com/Manual/ios-requirements-and-compatibility.html), and Unity 6000.0 [only supports Android API 23 and above](https://docs.unity3d.com/Manual/android-requirements-and-compatibility.html) and [iOS 13 and above](https://docs.unity3d.com/Manual/ios-requirements-and-compatibility.html) so your app must also observe these limitations.


## Gradle, AGP, NDK, JDK versions

Officially, [Unity is tested against the following dependencies](https://docs.unity3d.com/6000.0/Documentation/Manual/android-gradle-overview.html):

| Unity Version                     | Gradle Version  | Android Gradle Plug-in Version | NDK                  | JDK |
|-----------------------------------|-----------------|--------------------------------|----------------------|-----|
| 6000.2 - 6000.3+                  | 8.13            | 8.10.0                         | r27c (27.2.12479018) | 17  |
| 6000.0.61f1+                      | 8.13            | 8.10.0                         | r27c (27.2.12479018) | 17  |
| 6000.0.45f1 - 6000.0.60f1         | 8.11            | 8.7.2                          | r27c (27.2.12479018) | 17  |
| 6000.0.1f1 - 6000.0.44f1          | 8.4             | 8.3.0                          | r27c (27.2.12479018) | 17  |
| 2022.3.38f1+                      | 7.5.1           | 7.4.2                          | r23b (23.1.7779620)  | 11  |
| 2022.3.0f1 - 2022.3.37f1          | 7.2             | 7.1.2                          | r23b (23.1.7779620)  | 11  |

Anecdotal evidence suggests that it works with projects compiled with different versions of gradle, AGP, NDK and JDK, however you should test thoroughly. There is [some guidance in the wiki on what combinations of versions may work](https://github.com/learntoflutter/flutter_embed_unity/wiki#android-only-choose-a-combination-of-gradle-agp-jdk-and-android-studio-which-works-for-you).

Alternatively, you may want to investigate AAR compilation, which may be a solution if you are encountering too many version conflicts.


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


## Limited support for Simulators

Android and iOS similators appear to work well on Macs with Apple Silicon. 

For iOS simulator, when exporting your Unity project (see below) to embed into your Flutter app to run in a simulator, you will need to go into Player Settings -> Other settings -> Configuration and set *Target SDK* to `Simulator SDK` and *Simulator architecture* to `Universal`. Remember to set back to Device SDK when running on real devices.

Simulators are not supported when using AR/XR in Unity.

Other similator setups may not work due to architecture mismatches between the Unity export and your development machine. You may be able to work around these issues by experimenting with the 'Target architectures' setting (for Android) and 'Target SDK' setting (for iOS) in Unity's Player Settings.


## Alternatives
If you need to support other versions of unity, consider using [flutter_unity_widget](https://pub.dev/packages/flutter_unity_widget) or [consult the Wiki](https://github.com/learntoflutter/flutter_embed_unity/wiki) for instructions on how to create your own platform-specific sub-package to this federated package to target different versions of Unity.



# Setup


## Configure Unity

- Install [the latest Unity 2022.3 LTS, 6000.0 LTS or 6000.3 LTS](https://unity.com/releases/editor/archive)
- Either open an existing Unity project (it must be configured to use [the Universal Render Pipeline](https://docs.unity3d.com/Manual/universal-render-pipeline.html)), or create a new one using the `3D (URP) Core` template
- In Unity, make sure to select the appropriate build platform: go to `File -> Build Settings` (Unity 2022.3) or `File -> Build Profiles` (Unity 6) and select either Android or iOS, then click `Switch Platform`
- In Unity, go to `File -> Build Settings / Build Profile -> Player Settings -> Other settings`, and make the following changes:
  - Find [`Scripting backend`](https://docs.unity3d.com/Manual/scripting-backends.html) and set this to [`IL2CPP`](https://docs.unity3d.com/Manual/IL2CPP.html)
  - **Optional:** find `IL2CPP code generation` and `C++ Compiler Configuration`, and set to `Faster runtime` and `Release` if you are doing a release build and want your app to run as fast as possible (this will increase the build time significantly) or `faster build` and `Debug` if you are developing, want better error messages and want to build / iterate as fast as possible

 
### Additional Unity configuration for Android

- In Unity, go to `File -> Build Settings / Build Profile`, and enable the `Export project` tickbox
- In Unity, go to `File -> Build Settings / Build Profile -> Player Settings -> Other settings`, and make the following changes:
  - Find `Target API level`: it's not required, but recommended, to set this to the same target API level of your Flutter project's `android` app (this is usually set in `<your flutter project>/android/app/build.grade` as `targetSdkVersion`)
  - Find `Target Architechtures` and enable ARMv7 and ARM64
  
> Google Play [requires 64 bit apps](https://developer.android.com/google/play/requirements/64-bit), which is why we have to use IL2CPP and enable ARM64


## Import Unity package

To allow Unity to send messages to Flutter, and to make exporting your Unity project into Flutter easier, this plugin includes some Unity scripts which you should import into your Unity project.

There are a few different ways you can import these scripts:

### Import a .unitypackage file

- Go to [the releases for this plugin on Github](https://github.com/learntoflutter/flutter_embed_unity/releases) and find the version of this plugin you are using (the version you [add to your `pubspec.yaml`](https://pub.dev/packages/flutter_embed_unity/install))
- Expand `Assets` and download the file `flutter_embed_unity_2022_3.unitypackage` for Unity 2022.3 or `flutter_embed_unity_6000_0.unitypackage` for Unity 6000.0 / 6000.3.

![Screenshot 2025-05-29 at 12 11 39](https://github.com/user-attachments/assets/063d2825-0d18-4fe3-a0bf-2d198c18187f)

- In Unity, go to `Assets -> import package -> Custom package`, and choose the file you just downloaded
- The package includes two folders: `FlutterEmbed` which contains scripts which are REQUIRED to run the plugin, and `Example` which contains an optional example scene and AR scene which demonstrates how to use the plugin (this includes dependencies on ARFoundation - if you don't need the example you can untick these from the import package selection).

![import](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/3641f1a2-8fb3-40cf-9a16-bfca9919e214)


### Use Unity Package Manager to import from Git URL

- In Unity, open Package Manager, click the `+` button and choose 'Install package from Git URL...'
- Enter one of:
  - For Unity 2022.3: `https://github.com/learntoflutter/flutter_embed_unity.git?path=example_unity_2022_3_project/Assets/FlutterEmbed`
  - For Unity 6000.0 / 6000.3: `https://github.com/learntoflutter/flutter_embed_unity.git?path=example_unity_6000_0_project/Assets/FlutterEmbed`

The scripts will be added to your project under Packages -> Flutter Embed Unity.

### Copy directly from the example Unity projects

Alternatively you can browse the source in [the example Unity 2022.3 project](https://github.com/learntoflutter/flutter_embed_unity/tree/main/example_unity_2022_3_project) or [the example Unity 6000.0 project](https://github.com/learntoflutter/flutter_embed_unity/tree/main/example_unity_6000_0_project), and copy the scripts from the EmbedUnity asset folder into your Unity project, or use the example project as a starting template for a new Unity project.


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
The `EmbedUnity` assets you have added to your Unity project includes scripts to make this easy, and an Editor menu item to launch them, so you should see an option called `Flutter embed` in the Unity toolbar.

- First, create the folder to export your Unity project to. This MUST be either:
  - `<your flutter project>/android/unityLibrary` for Android or
  - `<your flutter project>/ios/unityLibrary` for iOS
- Select `Flutter Embed -> Export project to Flutter app` (select `ios` or `android` as appropriate)

![Screenshot 2023-09-15 153150](https://github.com/learntoflutter/flutter_embed_unity/assets/145048332/77cefebb-f5d0-4759-b23f-04ffdaca4c01)

> If you can't find this menu item, make sure you have imported the unitypackage as explained above
  
- The export script will make some checks for you (follow any instructions which appear)
- When asked, select the `unityLibrary` export folder you created
- Wait for the project to build, then check the Unity console output to understand what has happened and check for errors

> To learn about the structure of the Unity export you have just made, see [the documentation for Android](https://docs.unity3d.com/Manual/UnityasaLibrary-Android.html) and the [documentation for iOS](https://docs.unity3d.com/Manual/UnityasaLibrary-iOS.html). The export script takes these structures and modifies them for easier integration into Flutter: the Unity console output tells you what changes have been made

The Unity project is now ready to use, but we still haven't actually linked it to our Flutter app.


> You can also [Export from the command line](#advanced-export-from-the-command-line) instead.


## Link exported Unity project to your Flutter project


### iOS

- In Xcode, open your app's `<your flutter project>/ios/Runner.xcworkspace`. It's **very important** to make sure you are opening the `xcworkspace` and not the `xcproj`: [workspaces](https://developer.apple.com/documentation/xcode/managing-multiple-projects-and-their-dependencies) are designed for combining multiple projects (in this case, the Runner project for your Flutter app and the exported Unity project)
- In the project navigator, make sure nothing is selected
- From Xcode toolbar, select `File -> Add files to "Runner"` and select `<your flutter project>/ios/UnityLibrary/Unity-Iphone.xcodeproj`. This should add the Unity-iPhone project to your workspace at the same level as the Runner and Pods projects.

![2](https://github.com/jamesncl/flutter_embed_unity/assets/15979056/ca369db9-1991-4093-8713-5e68b0ddac17)

- In Xcode, select Runner in the project explorer, then under `Targets` select Runner, and open the General tab. Scroll down to *Frameworks, Libraries and Embedded Content*:

<img width="858" height="555" alt="Screenshot 2026-03-26 at 14 17 56" src="https://github.com/user-attachments/assets/d87695ed-8112-4c3f-b2d3-168877c93680" />


  Click `+` and select Workspace -> Unity-iPhone -> UnityFramework.framework. Leave the Embed option as the default `Embed & Sign`.

<img width="349" height="405" alt="Screenshot 2026-03-26 at 14 19 17" src="https://github.com/user-attachments/assets/7bcc1de3-5dec-4bd8-99df-dbb29f5163a0" />


> [!NOTE]
> Adding UnityFramework.framework as an embedded framework is only required for version 2.0.0 and later of the flutter_embed_unity package. If you are using an earlier version, leave this step out.


- In Xcode, select Runner in the project explorer, then under `Targets` select Runner, and open the Build Phases tab. Drag the Thin Binary build phase to the bottom, so that it's below the Embed Frameworks build phase. This is to avoid a build cycle error `Cycle inside Runner; building could produce unreliable results` when building in Xcode.


- If you are using Cocoapods to build your Flutter project, in `<your flutter app>/ios/Podfile` make sure the ios platform requirement is at least [the minimum required by Unity](https://docs.unity3d.com/Manual/ios-requirements-and-compatibility.html):

```ruby
# Unity 2022.3 requires iOS 12+, Unity 6000.0 requires iOS 13+
platform :ios, '13.0'
```


### Android

- You need to make the following modifications to `<your flutter project>/android/app/build.gradle`: 
  - Add the Unity project as a dependency to your app by adding `implementation project(':unityLibrary')` as a dependency (see below).
  - Also, if you are using Gradle 8 and later, you need to replace the value of the NDK version (which is likely set to `flutter.ndkVersion`) with a version of NDK which is equal to or higher than the one used by Unity (see the [Unity NDK compatibililty matrix](https://docs.unity3d.com/6000.1/Documentation/Manual/android-supported-dependency-versions.html)).
  - You should also make sure that your minimum Android SDK is set to one which is equal to or higher than the minimum required by your Unity project. The minimum supported by Unity 2022.3 is 22, the minimum supported by Unity 6000.0 is 23 (or, it may be set to a higher value in your Unity project's [Player Settings](https://docs.unity3d.com/6000.1/Documentation/Manual/class-PlayerSettingsAndroid.html))

If you created your project using Flutter 3.27 or earlier, you are likely still using the Groovy syntax:
```groovy
// Syntax for android/app/build.gradle
android {
  ...
  // Change ndkVersion to minimum supported by Unity:
  ndkVersion "23.1.7779620"  // For Unity 2022.3
  ndkVersion "27.2.12479018"  // For Unity 6000.0

  ...
  defaultConfig {
    ...    
    // Make sure minSdkVersion is equal to or higher than the minimum supported by your Unity project
    minSdkVersion 23  // 22+ for Unity 2022.3, 23+ for Unity 6000.0
  }
}

// Add this:
dependencies {
    implementation project(':unityLibrary')
}
```

Alternatively if you created your project using Flutter 3.29 or later, or have migrated to Kotin gradle DSL, you will have a file called `build.gradle.kts` which requires different syntax:
```kotlin
// Alternative syntax for android/app/build.gradle.kts
android {
  ...
  // Change ndkVersion to minimum supported by Unity:
  ndkVersion = "23.1.7779620"  // For Unity 2022.3
  ndkVersion = "27.2.12479018"  // For Unity 6000.0

  ...
  defaultConfig {
    ...    
    // Make sure minSdk is equal to or higher than the minimum supported by your Unity project
    minSdk = 23  // 22+ for Unity 2022.3, 23+ for Unity 6000.0
  }
}

// Add this:
dependencies {
    implementation(project(":unityLibrary"))
}
```

- Add the exported unity project to the gradle build by including it in `<your flutter project>/android/settings.gradle`:
```groovy
// Syntax for android/settings.gradle
include ':unityLibrary'
```
```kotlin
// Alternative syntax for android/settings.gradle.kts
include(":unityLibrary")
```

Add the Unity export directory as a repository so gradle can find required libraries / AARs etc in `<your flutter project>/android/build.gradle`. If you created your project using Flutter 3.27 or earlier, you are likely still using the Groovy syntax:

```groovy
// Syntax for android/build.gradle
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
```kotlin
// Alternative syntax for build.gradle.kts
allprojects {
    repositories {
        google()
        mavenCentral()
        // Add this:
        flatDir {
            dirs(file("${project(":unityLibrary").projectDir}/libs"))
        }
    }
}
```

By default, Unity references `unityStreamingAssets` in it's exported project build.gradle, and provides the definition in the gradle.properties of the thin launcher app. Because we are using a Flutter app rather than the provided launcher, we need to add the same definition to our own gradle.properites, otherwise you will get a build error `Could not get unknown property 'unityStreamingAssets'`.

To find the value of unityStreamingAssets you need to add, inspect the Unity console logs after exporting your Unity project. You should see a log which says "The following should be added to your project's android/gradle.properties:". Use the value printed below this line. It is often a blank value (i.e. just use `unityStreamingAssets=`), but if you are using [Streaming Assets](https://docs.unity3d.com/6000.0/Documentation/Manual/StreamingAssets.html) you may have a different value.

- Add to android/gradle.properties:

```
unityStreamingAssets=<the value shown in the Unity console log after export>
```


Unity's resources files are already compressed during the unity project export. When the Flutter project is built, these resources may be compressed again unnecessarily, which leads to longer loading times for Unity. To prevent this you can to copy some blocks from Unity's build.gradle to your app's build.gradle:

- (Optional) Add an `androidResources` block (or `aaptOptions` if you are using AGP version less than 4.0, which is not recommended) to your app's `android/app/build.gradle` (thanks [@RF103T](https://github.com/RF103T)). It goes inside the `android` block.

```groovy
android {
  ...
  // Syntax for android/app/build.gradle
  androidResources {
    ignoreAssetsPattern = "!.svn:!.git:!.ds_store:!*.scc:!CVS:!thumbs.db:!picasa.ini:!*~"
    noCompress = ['.unity3d', '.ress', '.resource', '.obb', '.bundle', '.unityexp'] + unityStreamingAssets.tokenize(', ')
  }
}
```
```groovy
android {
  ...
  // Syntax for android/app/build.gradle.kts

  androidResources {
    // Read unityStreamingAssets from gradle.properties
    val unityStreamingAssetsList = (project.findProperty("unityStreamingAssets") as? String)
              ?.split(",")
              ?.map { it.trim() }
              ?: emptyList()

    noCompress += listOf(
      ".unity3d", ".ress", ".resource", ".obb", ".bundle", ".unityexp"
    ) + unityStreamingAssetsList

    ignoreAssetsPattern = "!.svn:!.git:!.ds_store:!*.scc:!CVS:!thumbs.db:!picasa.ini:!*~"
  }
}
```

This can significantly increase the load speed of your Unity project if you have large assets. For more detail see [issue #32](https://github.com/learntoflutter/flutter_embed_unity/issues/32#issuecomment-2757284181)


## If you're using XR (VR / AR) on Android

If you are using XR features in Unity (eg ARFoundation) you need to perform some additional configuration on your project. First, make sure you check Unity's project validation checks: in your Unity project, go to `Project Settings -> XR Plug-in Management -> Project Validation`, and fix any problems.

- Add `include ':unityLibrary:xrmanifest.androidlib'` to your `android/settings.gradle` or  
`include(":unityLibrary:xrmanifest.androidlib")` for `android/settings.gradle.kts`:

In your exported `unityLibrary` you may find an extra project folder called `xrmanifest.androidlib`. The Unity project depends on this, so you need to inlcude it in your app's build.

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

This is to work around the fact that Unity as a library was designed to run in a custom activity made by Unity (you can find this in `unityLibrary\src\main\java\com\unity3d\player\UnityPlayerActivity.java`). Unfortunately, some Unity code expects to be able to find some properties in the activity hosting the Unity player - specifically, a field called `mUnityPlayer`. If it doesn't find this field, your app will crash when your XR code initialises with the following error:

`Non-fatal Exception: java.lang.Exception: AndroidJavaException : java.lang.NoSuchFieldError: no "Ljava/lang/Object;" field "mUnityPlayer" in class "Lcom/example/app/MainActivity;" or its superclasses`
 
Because this plugin is designed to embed Unity in a widget, not in an activity, we need to make our MainActivity 'pretend' like it's a `UnityPlayerActivity` by giving it a `mUnityPlayer` field which can be set by the plugin when the `UnityPlayer` is created. 


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

# Advanced: Export from the command line
> Batchmode support was added after version 1.3.1.  
If `ProjectExporterBatchmode.ExportProject` doesn't exisit in your Unity project, download and import a newer unitypackage. 

Besides using the Editor menu, you can also export from Unity using the command line.  
It is advised to try an export using the Editor Menu first, as that will help you check your project settings.

To start you will need the path to 3 directories.
1. Your Unity install directory:  
  Mac `/Applications/Unity/Hub/Editor/<version>/Unity.app/Contents/MacOS/Unity`  
  Windows `C:/Program Files/Unity/Hub/Editor/<version>/Editor/Unity.exe`  
  Linux `/Applications/Unity/Hub/Editor/<version>/Unity.app/Contents/Linux/Unity`  
2. Your Unity project directory.
3. Your output directory.  
  `<your flutter project>/android/unityLibrary` or `<your flutter project>/ios/unityLibrary`.  

Once you've got all 3, you are ready to export.

Use the `-buildTarget` value `Android` or `iOS` to select your platform.

```bash
"<unity path>" \
  -projectPath "<unity project path>" \
  -batchmode \
  -nographics \
  -buildTarget Android \
  -executeMethod ProjectExporterBatchmode.ExportProject \
  -exportPath "<output path>" \
  -quit
```
(For windows replace `\` with `^` in CMD or `` ` `` in Powershell)

Or as a single line
```bash
"<unity path>" -projectPath "<unity project path>" -batchmode -nographics -buildTarget Android -executeMethod ProjectExporterBatchmode.ExportProject -exportPath "<output path>" -quit
```

Unity will launch as an invisible (headless) instance in the background. It is important to include `-quit`, otherwise the headless Unity engine might stay active on your machine after the script aborts.

By default Unity won't display logs and errors in the command line. To view build logs, do one of the following:
* View the output in the [editor log](https://docs.unity3d.com/2022.3/Documentation/Manual/LogFiles.html)
* add the argument `-logFile <path to file>` to log to a specific file
* add the argument `-logFile -` to output log to the console

You might see the following on an exception, but you will need to check the logs for the exact message.
```
Aborting batchmode due to failure:
executeMethod method ProjectExporterBatchmode.ExportProject threw exception.
```

Check the [Unity documentation](https://docs.unity3d.com/2022.3/Documentation/Manual/EditorCommandLineArguments.html) for more info on building from the command line.

## Windows specific commands
On windows the command will return instantly, and Unity will finish exporting in the background a little while later.  

You can use start commands, like the examples below, to wait for Unity to complete. 

CMD
```cmd
start /wait "" "<unity path>" ^
 -projectPath "<unity project path>" ^
 -batchmode ^
 -nographics ^
 -buildTarget Android ^
 -executeMethod ProjectExporterBatchmode.ExportProject ^
 -exportPath "<output path>" ^
 -quit
```
Powershell
```powershell
Start-Process -FilePath "<unity path>" `
  -ArgumentList `
    "-projectPath", "<unity project path>", `
    "-batchmode", `
    "-nographics", `
    "-buildTarget", "Android", `
    "-executeMethod", "ProjectExporterBatchmode.ExportProject", `
    "-exportPath", "<output path>", `
    "-quit" `
  -Wait -PassThru
```



# Advanced: AAR compilation for Android

Unity 2022.3 is becoming quite old, and so it may increasingly become more difficult to manage dependency conflicts between Unity, Flutter, AGP, Gradle, JDK, NDK etc.

An alternative solution may be to [compile the Unity project into an AAR](https://github.com/learntoflutter/flutter_embed_unity/wiki/Advanced:-AAR-compilation-for-Android) before importing into Flutter (thanks [@timbotimbo](https://github.com/timbotimbo)).

See [the Wiki](https://github.com/learntoflutter/flutter_embed_unity/wiki/Advanced:-AAR-compilation-for-Android) for more information


# Common issues

## Undefined symbol: OBJC_CLASS$_UnityFramework

This is caused by changes to Xcode's linker in XCode 26 package (see [#84](https://github.com/learntoflutter/flutter_embed_unity/issues/84)) which has been fixed in an updated version of this plugin - check the [changlelog notes](https://pub.dev/packages/flutter_embed_unity/changelog)

## Namespace 'com.google.ar.core' is used in multiple modules and/or libraries: :arcore_client:, :unityandroidpermissions:.

This may be caused by (a conflict with earlier versions of Unity and ARFoundation with Gradle 9+)[https://discussions.unity.com/t/android-gradle-9-1-0-agp-9-0-0-update-in-unity-6-0/1709062] which was fixed in later versions. If you are using Gradle 9, update Unity to >= 6000.3.17f1 and ARFoundation >= 6.5.0

## Swift Compiler Error (Xcode): Unable to find module dependency: 'UnityFramework'

If you have recently upgraded flutter_embed_unity from version 1.x to 2.x make sure to read the breaking change notes [in the change log](https://pub.dev/packages/flutter_embed_unity/changelog). Version 2.x now requires UnityFramework.framework from your Unity-iPhone project to be embedded into your Runner target in Xcode. See the iOS setup instructions above to see how to do this. You may need to also run `flutter clean` before rebuilding.

## dyld: Library not loaded: @rpath/UnityFramework.framework/UnityFramework (no such file)

Same as above

## Error (Xcode): Multiple commands produce '.../UnityFramework.framework'

If you are using a version of flutter_embed_unity prior to 2.x, check to make sure you have NOT embedded the UnityFramework.framework into your app's Runner target in Xcode. Version 1.x does not require this, and in fact will cause this error if you do. To check, go to Xcode, select Runner in the project navigator, then select the Runner target in the editor window. Select the General tab and scroll down to Frameworks, Libraries & Embedded Content. If you have UnityFramework.framework in the list, and you are using a version of flutter_embed_unity prior to 2.x, remove it. You may need to also run `flutter clean` before rebuilding.


## Error (Xcode): Cycle inside Runner; building could produce unreliable results

After adding UnityFramework.framework to Targets -> Runner -> General -> Frameworks, Libraries and Embedded Content, you may run into this Xcode build error when building for iOS.

The problem is most likely caused by the fact that that flutter’s Thin Binary build phase in Xcode reads and rewrites the final built app binary, which is only produced after all frameworks — including UnityFramework.framework — have been copied into the app bundle. However, because the Thin Binary is also listed as part of the Runner build process, Runner’s build is considered to depend on that script, creating a dependency loop (Copy UnityFramework -> Thin Binary -> Build final app -> Copy UnityFramework)

The following will likely fix this:

* In Xcode, select Runner in the project navigator
* Under Targets, select Runner
* Go to the Build Phases tab
* Find the Thin Binary build phase. Drag it downwards until it is below the Embed Frameworks build phase

If the above does not fix the issue, check if you have any custom Run Script build phases which may also be implicitly referencing the final built product. For example, any script which references variables which point to the final built product path, such as $TARGET_BUILD_DIR, $FULL_PRODUCT_NAME, $DWARF_DSYM_FOLDER_PATH, $WRAPPER_NAME, $WRAPPER_EXTENSION, $CODESIGNING_FOLDER_PATH, $BUILT_PRODUCTS_DIR, $CONTENTS_FOLDER_PATH etc could trigger this build cycle.


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


## java.lang.NoClassDefFoundError: Failed resolution of: Landroid/window/OnBackInvokedCallback

Since Flutter 3.22, Unity will crash on certain Android versions when ARFoundation is activated. This only happens on Android <13. See [#21](https://github.com/learntoflutter/flutter_embed_unity/issues/21)


> E/Unity   ( 7029): AndroidJavaException: java.lang.NoClassDefFoundError: Failed resolution of: Landroid/window/OnBackInvokedCallback;
>E/Unity   ( 7029): java.lang.NoClassDefFoundError: Failed resolution of: Landroid/window/OnBackInvokedCallback;
>E/Unity   ( 7029): 	at java.lang.reflect.Executable.getMethodReturnTypeInternal(Native Method)
>E/Unity   ( 7029): 	at java.lang.reflect.Method.getReturnType(Method.java:148)
E/Unity   ( 7029): 	at java.lang.Class.getDeclaredMethods(Class.java:1880)
E/Unity   ( 7029): 	at com.unity3d.player.ReflectionHelper.getMethodID(Unknown Source:26)
E/Unity   ( 7029): 	at com.unity3d.player.UnityPlayer.nativeRender(Native Method)
E/Unity   ( 7029): 	at com.unity3d.player.UnityPlayer.-$$Nest$mnativeRender(Unknown Source:0)
E/Unity   ( 7029): 	at com.unity3d.player.UnityPlayer$F$a.handleMessage(Unknown Source:122)
E/Unity   ( 7029): 	at android.os.Handler.dispatchMessage(Handler.java:102)
E/Unity   ( 7029): 	at android.os.Looper.loop(Looper.java:214)
E/Unity   ( 7029): 	at com.unity3d.player.UnityPlayer$F.run(Unknown Source:24)
E/Unity   ( 7029): Caused by: java.lang.ClassNotFoundException: Didn't find class "android.window.OnBackInvokedCallback" on path: DexPathList[[zip file "/data/app/com.learntoflutter.flutter_embed_uni


## Crash on iOS when using Google Maps

If you're using the [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) package you may encounter a crash on iOS during app startup in `libdispatch.dylib`:

```
libdispatch.dylib`:
0x10511cd2c <+0>: stp x20, x21, [sp, #-0x10]!
0x10511cd30 <+4>: adrp x20, 7
0x10511cd34 <+8>: add x20, x20, #0xaf8 ; "BUG IN CLIENT OF LIBDISPATCH: trying to lock recursively"
0x10511cd38 <+12>: adrp x21, 41
0x10511cd3c <+16>: add x21, x21, #0x220 ; gCRAnnotations
0x10511cd40 <+20>: str x20, [x21, #0x8]
0x10511cd44 <+24>: ldp x20, x21, [sp], #0x10
-> 0x10511cd48 <+28>: brk #0x1       <-- Break occurs here
```

This can be resolved by disabling 'Thread Performance Checker' in your Xcode scheme (see [#28](https://github.com/learntoflutter/flutter_embed_unity/issues/28) for more info):

![b7cc87349704f02ed91be4b0014a353a2e005d98_2_690x228](https://github.com/user-attachments/assets/88038f06-0343-4360-a1cf-ae1d72732fd2)


# Plugin developers / contributors

See [the Wiki for more information](https://github.com/learntoflutter/flutter_embed_unity/wiki) on running the example, notes on how the plugin works, developing for different versions of Unity etc.
				
# Acknowledgements

Thanks to [@cookiejarlid](https://github.com/cookiejarlid) who created [flutter_unity](https://github.com/Glartek/flutter-unity) and [@juicycleff](https://github.com/juicycleff) who created [flutter_unity_widget](https://github.com/juicycleff/flutter-unity-view-widget), they figured out many of the techniques used in this package to get Unity to work with Flutter. Thanks to [@timbotimbo](https://github.com/timbotimbo) for patches to flutter_unity_widget, some of which are also used in this package, and continuing support on this package.
