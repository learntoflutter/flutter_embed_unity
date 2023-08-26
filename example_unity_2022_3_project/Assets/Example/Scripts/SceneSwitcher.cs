using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneSwitcher : MonoBehaviour
{
    void SwitchToScene(string sceneName) 
    {
        if(!sceneName.Equals(SceneManager.GetActiveScene().name)) {
            SceneManager.LoadSceneAsync(sceneName, LoadSceneMode.Single);   
        }
    }
}
