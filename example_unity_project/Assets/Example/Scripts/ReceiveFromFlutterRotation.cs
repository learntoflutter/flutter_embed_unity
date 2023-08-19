using UnityEngine;

public class ReceiveFromFlutterRotation : MonoBehaviour
{
    float _rotationSpeed = -15;

    void Update()
    {
        transform.Rotate(0, _rotationSpeed * Time.deltaTime, 0);
    }

    public void SetRotationSpeed(string data)
    {
        _rotationSpeed = float.Parse(data);
    }
}
