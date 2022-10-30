using System;
using System.Diagnostics;
using System.IO;
using UnityEngine;

namespace D3Plot {
    public class D3PlotLoader : MonoBehaviour {
        public StateDatabase StateDatabase => _stateDatabase;

        public delegate void StateChanged(int previousState, int newState);

        public delegate void DatabaseLoaded(StateDatabase database);

        public event StateChanged OnStateChanged;
        public event DatabaseLoaded OnDatabaseLoaded;

        [SerializeField] private int _currentStateIndex;
        [SerializeField] private int _previousStateIndex;
        private StateDatabase _stateDatabase;
        private Stopwatch _sw;
        private Quaternion _flipAxisStart;
        private Quaternion _flipAxisTarget;
        private float _flipAxisTime;

        private static float _flipDuration = 0.5f;

        private void Awake() {
            _currentStateIndex = 0;
            _previousStateIndex = -1;
        }

        public string[] EnumerateFiles(string filePath) {
            string path = Path.GetDirectoryName(Path.GetFullPath(filePath));
            string fileName = Path.GetFileName(filePath) + "*";

            string[] files = Directory.GetFiles(path ?? ".", fileName);
            Array.Sort(files);

            string[] stateFileNames = new string[files.Length - 1];
            Array.Copy(files, 1, stateFileNames, 0, files.Length - 1);

            return stateFileNames;
        }

        public void LoadDatabase(string databaseFileName) {
            using (FileStream f = File.OpenRead(databaseFileName)) {
                _stateDatabase = new StateDatabase();
                _stateDatabase.Parse(new BinaryReader(f));
                OnDatabaseLoaded?.Invoke(_stateDatabase);
                gameObject.name = _stateDatabase.Title;
            }
        }

        public void FlipAxis(Quaternion target) {
            if (_stateDatabase == null) {
                transform.rotation = target;
                _flipAxisTarget = target;
                _flipAxisStart = target;
                _flipAxisTime = _flipDuration + 0.11f;
            } else {
                _flipAxisTarget = target;
                _flipAxisStart = transform.rotation;
                _flipAxisTime = 0.0f;
            }
        }

        private void Update() {
            if (_stateDatabase == null) {
                return;
            }
            
            // Go slightly over time to ensure we're fully at the target orientation.
            if (_flipAxisTime <= _flipDuration + 0.1f) {
                transform.rotation = Quaternion.Slerp(_flipAxisStart, _flipAxisTarget, Mathf.Clamp01(_flipAxisTime / _flipDuration));
                _flipAxisTime += Time.deltaTime;
            }

            if (_stateDatabase.StateCount == 0) {
                return;
            }

            bool shiftPressed = Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift);

            if ((Input.GetButton("Frame step") && !shiftPressed) ||
                (Input.GetButtonDown("Frame step") && shiftPressed)) {
                if (Input.GetAxis("Frame step") > 0.0f) {
                    _currentStateIndex = Math.Min(_currentStateIndex + 1, _stateDatabase.StateCount - 1);
                } else if (Input.GetAxis("Frame step") < 0.0f) {
                    _currentStateIndex = Math.Max(_currentStateIndex - 1, 0);
                }
            }

            if (_previousStateIndex != _currentStateIndex) {
                // States can be loaded in arbitrary order, so ignore this state change until the desired state is loaded.
                if (_stateDatabase.GetState(_currentStateIndex) != null) {
                    OnStateChanged?.Invoke(_previousStateIndex, _currentStateIndex);
                    _previousStateIndex = _currentStateIndex;
                }
            }
        }

        private void OnDestroy() {
            _stateDatabase?.Dispose();

            StateFactory.Instance.Dispose();
        }
    }
}