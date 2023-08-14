# flutter_embed_unity

Embed Unity 3D into Flutter apps. Designed to offer more basic functionality than other packages, but be more stable and maintainable

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



Our project is now configured and ready to use, but we still haven't actually linked it to our app, so if we run it now, we will get:

> java.lang.NoClassDefFoundError: Failed resolution of: Lcom/unity3d/player/UnityPlayer


First add the exported unity project to the gradle build using an `include` in android/settings.gradle:
- Add to android/settings.gradle:

include ':unityLibrary'


And then tell our project to depend on it:

- Add to android/app/build.gradle at the bottom on its own:

dependencies {
    implementation project(':unityLibrary')
}


By default, Unity has this in it's exported project build.gradle:

aaptOptions {
        noCompress = ['.unity3d', '.ress', '.resource', '.obb', '.bundle', '.unityexp'] + unityStreamingAssets.tokenize(', ')
        ignoreAssetsPattern = "!.svn:!.git:!.ds_store:!*.scc:!CVS:!thumbs.db:!picasa.ini:!*~"
    }
	
When we try to build, this error will happen:

> Could not get unknown property 'unityStreamingAssets'

Fix this by:
- Add to android/gradle.properties:

unityStreamingAssets=.unity3d, google-services-desktop.json, google-services.json, GoogleService-Info.plist



## Optional adjustments

playerOptions.options = BuildOptions.AllowDebugging | BuildOptions.Development;
PlayerSettings.SetIl2CppCompilerConfiguration(BuildTargetGroup.Android, isReleaseBuild ? Il2CppCompilerConfiguration.Release : Il2CppCompilerConfiguration.Debug);
                PlayerSettings.SetIl2CppCodeGeneration(UnityEditor.Build.NamedBuildTarget.Android, UnityEditor.Build.Il2CppCodeGeneration.OptimizeSize);
				
## Unity export script

See See https://docs.unity3d.com/2022.3/Documentation/Manual/UnityasaLibrary-Android.html
https://docs.unity3d.com/2022.3/Documentation/Manual/UnityasaLibrary.html

Old and outdated but still useful background: https://forum.unity.com/threads/using-unity-as-a-library-in-native-ios-android-apps.685195/



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