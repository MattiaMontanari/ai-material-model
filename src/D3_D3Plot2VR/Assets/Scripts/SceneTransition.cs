using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.XR.Management;

public class SceneTransition : MonoBehaviour {
    private void Awake() {
        DontDestroyOnLoad(gameObject);
    }

    public void TransitionToVR(string sceneName) {
        if (XRGeneralSettings.Instance.Manager.activeLoader == null) {
            XRGeneralSettings.Instance.Manager.InitializeLoaderSync();
        }

        if (XRGeneralSettings.Instance.Manager.activeLoader != null) {
            XRGeneralSettings.Instance.Manager.StartSubsystems();
        }

        SceneManager.LoadScene(sceneName);
    }

    public void TransitionToDesktop(string sceneName) {
        if (XRGeneralSettings.Instance.Manager.activeLoader != null) {
            XRGeneralSettings.Instance.Manager.StopSubsystems();
        }

        SceneManager.LoadSceneAsync(sceneName);
    }

    private void OnDestroy() {
        if (XRGeneralSettings.Instance.Manager.activeLoader != null) {
            XRGeneralSettings.Instance.Manager.DeinitializeLoader();
        }
    }
}