using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class ARLogoPinner : MonoBehaviour
{
    private static readonly float cursorRaycastX = 0.5f;
    private static readonly float cursorRaycastY = 0.2f;
    private static readonly float noSurfaceMannequinPositionX = 0.5f;
    private static readonly float noSurfaceMannequinPositionY = 0.5f;
    private static readonly float noSurfaceMannequinDistanceFromCamera = 3f;

    public ARRaycastManager raycastManager;
    public GameObject flutterLogo;
    private bool haveFoundSurface = false;

    // Update is called once per frame
    void Update()
    {
        Vector2 screenPosition = Camera.main.ViewportToScreenPoint(new Vector2(cursorRaycastX, cursorRaycastY));
        List<ARRaycastHit> hits = new List<ARRaycastHit>();
        raycastManager.Raycast(screenPosition, hits, UnityEngine.XR.ARSubsystems.TrackableType.PlaneWithinPolygon);

        if (hits.Count > 0)
        {
            // Surface was detected, so use that as the logo position
            flutterLogo.transform.position = hits[0].pose.position;
            float scaleRelativeToDistance = hits[0].distance / 8;
            flutterLogo.transform.localScale = new Vector3(scaleRelativeToDistance, scaleRelativeToDistance, scaleRelativeToDistance);
            haveFoundSurface = true;
        }
        else if (!haveFoundSurface)
        {
            // No surface detected, so use a point straight infront of the camera
            flutterLogo.transform.position = Camera.main.ViewportToWorldPoint(new Vector3(noSurfaceMannequinPositionX, noSurfaceMannequinPositionY, noSurfaceMannequinDistanceFromCamera));
            flutterLogo.transform.localScale = Vector3.one;
        }
    }
}