package com.learntoflutter.flutter_embed_unity_android.unity;

import io.flutter.embedding.android.FlutterActivity;

/**
 * A convenience Activity which implements the IFakeUnityPlayerActivity
 * interface for you. If your MainActivity cannot extend this class
 * (for example, because your MainActivity is already extending a different
 * class), your MainActivity should implement IFakeUnityPlayerActivity
 * and MUST store the provided object as a public field called mUnityPlayer.
 * See comments on IFakeUnityPlayer for more details.
 */
public class FakeUnityPlayerActivity extends FlutterActivity implements IFakeUnityPlayerActivity {

   // don't change the name of this variable; referenced from native code
   // See com.unity3d.player.UnityPlayerActivity.java
   public Object mUnityPlayer;

   // This is called at Runtime by the flutter_embed_unity plugin.
   // It will pass an instance of com.unity3d.player.UnityPlayer
   // as the object.
   @Override
   public void setmUnityPlayer(Object mUnityPlayer) {
      this.mUnityPlayer = mUnityPlayer;
   }
}