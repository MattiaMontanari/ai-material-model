using System.Collections.Generic;
using g3;
using UnityEngine;
using UnityEngine.Rendering;
using Random = UnityEngine.Random;

namespace D3Plot {
    [RequireComponent(typeof(D3PlotLoader))]
    public class StateRenderer : MonoBehaviour {
        public State CurrentState {
            get => _state;
            set {
                _state = value;
                if (_state == null) {
                    _coordinatesBuffer.SetData(_loader.StateDatabase.NodeCoordinates);
                } else {
                    _coordinatesBuffer.SetData(_state.NodeCoordinates);
                }
            }
        }

        public Color LineColour;
        [Range(0.5f, 5.0f)] public float LineWidth = 1.0f;
        [Range(0.0f, 1.0f)] public float PartTransparency = 1.0f;

        private State _state;
        private ComputeBuffer _coordinatesBuffer;
        private Material _material;
        private D3PlotLoader _loader;
        private int _plotLayer;

        private static readonly int PartColorProp = Shader.PropertyToID("part_colours");
        private static readonly int Verts3dProp = Shader.PropertyToID("verts3d");
        private static readonly int XformProp = Shader.PropertyToID("xform");
        private static readonly int LineColourProp = Shader.PropertyToID("line_colour");
        private static readonly int WindowScaleProp = Shader.PropertyToID("win_scale");
        private static readonly int LineWidthProp = Shader.PropertyToID("line_width");
        private static readonly int PartTransparencyProp = Shader.PropertyToID("part_transparency");

        private void Awake() {
            _material = new Material(Shader.Find("GeoSpark/D3Plot"));
            _plotLayer = LayerMask.NameToLayer("Plots");
            _loader = GetComponent<D3PlotLoader>();
            _loader.OnDatabaseLoaded += OnDatabaseLoaded;
            _loader.OnStateChanged += OnStateChanged;
        }

        private void OnStateChanged(int previousState, int newState) {
            CurrentState = _loader.StateDatabase.GetState(newState);
        }

        private void OnDatabaseLoaded(StateDatabase database) {
            int numColours = database.Control.TotalMaterialCount;
            List<Color> materialColours = new List<Color>(numColours);

            for (int i = 0; i < numColours; ++i) {
                materialColours.Add(Random.ColorHSV(0.0f, 1.0f, 0.2f, 0.5f, 0.6f, 0.8f));
            }

            _coordinatesBuffer?.Release();
            _coordinatesBuffer = new ComputeBuffer(database.Control.ndim * database.Control.numnp, 4 * 4);

            _material.SetBuffer(Verts3dProp, _coordinatesBuffer);
            _material.SetColorArray(PartColorProp, materialColours);
            CurrentState = null;
        }

        private void Update() {
            if (_loader.StateDatabase == null) {
                return;
            }

            MaterialPropertyBlock pb = new MaterialPropertyBlock();
            Transform xform = transform;
            Frame3f frame = new Frame3f(xform.position, xform.rotation);
            Box3f bounds = _state?.BoundingBox ?? _loader.StateDatabase.BoundingBox;
            bounds.Scale(xform.localScale);
            frame.FromFrame(ref bounds);
            Bounds aabb = bounds.ToAABB();

            pb.SetMatrix(XformProp, xform.localToWorldMatrix);
            pb.SetVector(WindowScaleProp, new Vector4(Screen.width, Screen.height, 0.0f, 0.0f));
            pb.SetColor(LineColourProp, LineColour);
            pb.SetFloat(LineWidthProp, LineWidth);
            pb.SetFloat(PartTransparencyProp, PartTransparency);

            for (int i = 0; i < _loader.StateDatabase.Control.TotalMaterialCount; ++i) {
                Graphics.DrawProcedural(_material, aabb, MeshTopology.Triangles,
                    _loader.StateDatabase.FaceIndexBuffers[i],
                    _loader.StateDatabase.FaceIdxCount[i], 1, null, pb, ShadowCastingMode.Off, false, _plotLayer);
            }
        }

        public void OnDestroy() {
            _coordinatesBuffer?.Dispose();
        }
    }
}