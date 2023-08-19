using UnityEngine;

public class SendToFlutterTouched : MonoBehaviour
{
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
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
