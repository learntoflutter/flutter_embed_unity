using System.Collections;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

namespace Assets.Scripts
{
    public class ARCheckAvailability : MonoBehaviour
    {
        [SerializeField] ARSession arSession;

        void Start() 
        {
            StartCoroutine(CheckAvailabilityCoroutine());
        }

        IEnumerator CheckAvailabilityCoroutine() {

            Debug.Log("ARCheckAvailability: check");

            if ((ARSession.state == ARSessionState.None) ||
                (ARSession.state == ARSessionState.CheckingAvailability) ||
                (ARSession.state == ARSessionState.Installing))
            {
                Debug.Log("ARCheckAvailability: checking...");
                yield return ARSession.CheckAvailability();
            }

            if (ARSession.state == ARSessionState.Unsupported)
            {
                Debug.Log("ARCheckAvailability: unsupported");
                SendToFlutter.Send("ar:false");
            }
            else
            {
                Debug.Log("ARCheckAvailability: available");
                SendToFlutter.Send("ar:true");
            }
        }
    }
}