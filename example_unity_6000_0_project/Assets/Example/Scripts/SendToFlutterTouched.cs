using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.EnhancedTouch;

public class SendToFlutterTouched : MonoBehaviour
{
    void Awake() {
        // Required for input polling in new input system
        EnhancedTouchSupport.Enable();
    }

    void OnDestroy()
    {
        EnhancedTouchSupport.Disable();
    }

    void Update()
    {
        if (UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches.Count > 0 
        && UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches[0].began)
        {
            Ray ray = Camera.main.ScreenPointToRay(UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches[0].screenPosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                Debug.Log("Flutter logo touched");
                SendToFlutter.Send("touch");
            }
        }
    }
}
