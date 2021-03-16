using D3Plot;
using UnityEngine;

public class CameraTurntable : MonoBehaviour {
    // Degrees per second.
    [SerializeField] private float RotateSpeed = 25.0f;
    [SerializeField] private D3PlotLoader Target;

    private Camera _camera;
    private float _orbitDistance;
    private Transform _cameraXform;
    private Transform _xform;
    private bool _loaded;
    private float _heading;
    
    private void Awake() {
        Target.OnDatabaseLoaded += OnDatabaseLoaded;
        _camera = GetComponentInChildren<Camera>();
        _cameraXform = _camera.transform;
        _xform = transform;
    }

    private void OnDatabaseLoaded(StateDatabase database) {
        _xform.position = database.BoundingBox.Center;
        float radius = database.BoundingBox.Extent.Length;
        float vfov = (_camera.fieldOfView / 2.0f) * Mathf.Deg2Rad;
        _orbitDistance = radius / Mathf.Atan(vfov);
        _cameraXform.position = _cameraXform.forward * -_orbitDistance;
        _loaded = true;
        _heading = 0.0f;
    }

    private void Update() {
        if (!_loaded) {
            return;
        }

        _heading += RotateSpeed * Time.deltaTime;
        
        _xform.rotation = Quaternion.AngleAxis(_heading, Vector3.up) * Quaternion.AngleAxis(30.0f, Vector3.right);
    }
}
