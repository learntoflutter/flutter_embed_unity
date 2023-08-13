using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CubeRotation : MonoBehaviour
{
    float _rotationSpeed = -15;

    void Update () {
        transform.Rotate(0, _rotationSpeed * Time.deltaTime, 0);
    }

    public void SetRotationSpeed(string data) {
        _rotationSpeed = float.Parse(data);
    }
}
