using System;
using System.Collections.Concurrent;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Debug = UnityEngine.Debug;

namespace D3Plot {
    public class StateFactory : IDisposable {
        private static StateFactory _instance;

        public delegate void StatesLoaded();

        public event StatesLoaded OnStatesLoaded;

        private readonly BlockingCollection<string> _stateFileNameQueue;
        private readonly ConcurrentQueue<State> _stateQueue;
        private readonly CancellationTokenSource _tokenSource;
        private StateDatabase _stateDatabase;

        public static StateFactory Instance {
            get {
                if (_instance == null) {
                    _instance = new StateFactory();
                }

                return _instance;
            }
        }

        public StateDatabase StateDatabase {
            set => _stateDatabase = value;
        }

        private StateFactory() {
            _tokenSource = new CancellationTokenSource();
            _stateQueue = new ConcurrentQueue<State>();
            ConcurrentQueue<string> q = new ConcurrentQueue<string>();
            _stateFileNameQueue = new BlockingCollection<string>(q);
        }

        public void Produce() {
            SemaphoreSlim semaphore = new SemaphoreSlim(4, 4);

            BackgroundWorker worker = new BackgroundWorker();

            worker.DoWork += (sender, args) => {
                Debug.Log("Starting worker");
                while (!_stateFileNameQueue.IsCompleted) {
                    try {
                        semaphore.Wait(_tokenSource.Token);
                        string fileName = _stateFileNameQueue.Take(_tokenSource.Token);
                        Task.Run(() => {
                            LoadStates(fileName);
                            semaphore.Release();
                            OnStatesLoaded?.Invoke();
                        }, _tokenSource.Token);
                    } catch (OperationCanceledException) {
                        break;
                    }
                }

                Debug.Log("Stopping worker");
            };

            worker.RunWorkerAsync();
        }

        public void AddFile(string fileName) {
            if (_stateDatabase == null) {
                throw new StateDatabaseNotSetException();
            }

            _stateFileNameQueue.Add(fileName);
        }

        public void FinishedAddingFiles() {
            _stateFileNameQueue.CompleteAdding();
        }

        public bool StatesAvailable() {
            if (_stateDatabase == null) {
                throw new StateDatabaseNotSetException();
            }

            return !_stateQueue.IsEmpty;
        }

        public State PopState() {
            if (_stateDatabase == null) {
                throw new StateDatabaseNotSetException();
            }

            if (!_stateQueue.TryDequeue(out State state)) {
                return null;
            }

            return state;
        }

        private void LoadStates(string fileName) {
            Stopwatch sw = Stopwatch.StartNew();
            FileStream f = File.OpenRead(fileName);
            int stateCount = 0;

            while (true) {
                double time;
                byte[] buff = new byte[_stateDatabase.WordSize];
                f.Read(buff, 0, _stateDatabase.WordSize);

                if (_stateDatabase.WordSize == 4) {
                    time = BitConverter.ToSingle(buff, 0);
                } else {
                    time = BitConverter.ToDouble(buff, 0);
                }

                if (time == -999999.0) {
                    break;
                }

                State state = new State(_stateDatabase);
                state.Parse(time, f);
                _stateQueue.Enqueue(state);
                ++stateCount;
            }

            f.Close();

            sw.Stop();
            Debug.Log($"Loaded {stateCount} states in {sw.ElapsedMilliseconds}ms");
        }

        public void Dispose() {
            _tokenSource.Cancel();
            _tokenSource.Dispose();
        }
    }
}