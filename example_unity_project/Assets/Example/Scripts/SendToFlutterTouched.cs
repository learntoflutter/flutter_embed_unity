using UnityEngine;

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
                Debug.Log($"{gameObject.name} was touched");
                SendToFlutter.Send("touch");
            }
        }
    }
}
