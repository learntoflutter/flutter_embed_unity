using System.Globalization;
using UnityEngine;

public class ReceiveFromFlutterRotation : MonoBehaviour
{
    float _rotationSpeed = 0;

    void Update()
    {
        transform.Rotate(0, _rotationSpeed * Time.deltaTime, 0);
    }

    public void SetRotationSpeed(string data)
    {
        _rotationSpeed = float.Parse(
            data,
            // When converting between strings and numbers in a message protocol
            // always use a fixed locale, to prevent unexpected parsing errors when
            // the user's locale is different to the locale used by the developer
            // (eg the decimal separator might be different)
            CultureInfo.InvariantCulture);
    }
}
