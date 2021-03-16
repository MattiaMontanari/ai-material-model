using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using g3;
using Unity.Mathematics;
using UnityEngine;

namespace D3Plot {
    public class StateDatabase : IDisposable {
        public ControlData Control => _controlData;

        public GraphicsBuffer[] FaceIndexBuffers => _faceIndexBuffers;

        public State.NodeData[] NodeCoordinates => _nodeCoordinates;

        public Box3f BoundingBox => _boundingBox;

        public int[] FaceIdxCount => _faceIdxCount;

        public int WordSize => _wordSize;

        public UserElementIDs ElementIDs => _userElementIDs;

        public string Title => _headerTitle;

        public Dictionary<int, string> PartTitles => _partTitles;

        public Dictionary<int, string> ContactTitles => _contactTitles;

        public Dictionary<int, string> PropPartTitles => _propPartTitles;

        public List<string> Keywords => _keywords;

        public List<HigherSolidElementPart> HigherSolidElementParts => _higherSolidElementParts;

        public int StateCount => _states.Count;

        public int4[] ElementVertices => _elementVertices;

        public int[] ElementMaterial => _elementMaterial;

        private readonly struct TetrahedronFace {
            public readonly int3 indices;
            public readonly int3 faceIdx;
            public readonly int material;

            public TetrahedronFace(int3 i, int m) {
                indices = i;
                material = m;
                int a = i.x;
                int b = i.y;
                int c = i.z;
                
                if (a > c) {
                    Swap(ref a, ref c);
                }
                if (a > b) {
                    Swap(ref a, ref b);
                }
                if (b > c) {
                    Swap(ref b, ref c);
                }

                faceIdx = new int3(a, b, c);
            }

            private static void Swap(ref int a, ref int b) {
                int t = a;
                a = b;
                b = t;
            }
            
            public override int GetHashCode() {
                return faceIdx.GetHashCode();
            }
        }

        private class WingedFaceComparer : IEqualityComparer<TetrahedronFace> {
            public bool Equals(TetrahedronFace x, TetrahedronFace y) {
                return x.faceIdx.Equals(y.faceIdx);
            }

            public int GetHashCode(TetrahedronFace obj) {
                return obj.GetHashCode();
            }
        }

        private string _headerTitle;
        private readonly List<HigherSolidElementPart> _higherSolidElementParts;
        private UserElementIDs _userElementIDs;
        private ControlData _controlData;
        private int _wordSize;
        private readonly Dictionary<int, string> _partTitles;
        private readonly Dictionary<int, string> _contactTitles;
        private readonly Dictionary<int, string> _propPartTitles;
        private readonly List<string> _keywords;
        private readonly List<State> _states;
        private int[] _faceIdxCount;
        private GraphicsBuffer[] _faceIndexBuffers;
        private int4[] _elementVertices;
        private int[] _elementMaterial;
        private Box3f _boundingBox;
        private State.NodeData[] _nodeCoordinates;

        private const int SIZEFACTOR = 7;
        private const int FEMLEN = SIZEFACTOR * 512 * 512;

        public StateDatabase() {
            _partTitles = new Dictionary<int, string>();
            _contactTitles = new Dictionary<int, string>();
            _propPartTitles = new Dictionary<int, string>();
            _keywords = new List<string>();
            _higherSolidElementParts = new List<HigherSolidElementPart>();
            _states = new List<State>();
            _boundingBox = Box3f.Empty;
        }

        public void Parse(BinaryReader reader) {
            if (is64Bits(reader)) {
                _wordSize = 8;
            } else {
                _wordSize = 4;
            }

            DeserializeControlData(reader);

            if (_controlData.extra.cubic > 1 || _controlData.extra.quadr > 1) {
                DeserializeHigherSolidElements(reader);
            }

            if (_controlData.mattyp != 0) {
                throw new UnsupportedFeatureException("Materials not done yet");
            }

            if (_controlData.ialemat != 0) {
                throw new UnsupportedFeatureException("Fluid materials not done yet");
            }

            if (_controlData.nmsph > 0) {
                throw new UnsupportedFeatureException("Smooth particles not done yet");
            }

            if (_controlData.npefg > 0) {
                throw new UnsupportedFeatureException("Particle data not done yet");
            }

            DeserializeGeometry(reader);

            if (_controlData.narbs > 0) {
                DeserializeUserElementIDs(reader);
            }

            if (_controlData.HasRigidBodyData) {
                throw new UnsupportedFeatureException("Rigid body data not done yet");
            }

            if (_controlData.nadapt > 0) {
                throw new UnsupportedFeatureException("Adapted element data not done yet");
            }

            if (_controlData.nmsph > 0 || _controlData.npefg > 0) {
                throw new UnsupportedFeatureException("Shouldn't be here");
            }

            if (_controlData.HasRigidRoadSurface) {
                throw new UnsupportedFeatureException("Rigid road data not done yet");
            }

            if (_controlData.HasNel10) {
                throw new UnsupportedFeatureException("Extra 2 node connectivity not done yet");
            }

            if (_controlData.nel48 > 0) {
                throw new UnsupportedFeatureException("Extra 4 node connectivity not done yet");
            }

            if (_controlData.extra.nel20 > 0) {
                throw new UnsupportedFeatureException("Extra 12 node connectivity not done yet");
            }

            if (_controlData.extra.nel27 > 0 && _controlData.extra.quadr > 0) {
                throw new UnsupportedFeatureException("Extra 27 node connectivity not done yet");
            }

            if (_controlData.extra.nel21p > 0 && _controlData.extra.quadr > 0) {
                throw new UnsupportedFeatureException("Extra 21 node connectivity not done yet");
            }

            if (_controlData.extra.nel15t > 0 && _controlData.extra.quadr > 0) {
                throw new UnsupportedFeatureException("Extra 15 node connectivity not done yet");
            }

            if (_controlData.extra.nel20t > 0 && _controlData.extra.cubic > 0) {
                throw new UnsupportedFeatureException("Extra 20 node connectivity not done yet");
            }

            if (_controlData.extra.nel40p > 0 && _controlData.extra.cubic > 0) {
                throw new UnsupportedFeatureException("Extra 40 node connectivity not done yet");
            }

            if (_controlData.extra.nel64 > 0 && _controlData.extra.cubic > 0) {
                throw new UnsupportedFeatureException("Extra 64 node connectivity not done yet");
            }

            if (_wordSize == 4) {
                float eof = reader.ReadSingle();

                if (eof != -999999.0f) {
                    throw new FormatException("EOF not found");
                }
            } else {
                double eof = reader.ReadDouble();

                if (eof != -999999.0) {
                    throw new FormatException("EOF not found");
                }
            }

            DeserializeTitles(reader);
        }

        public void LoadStates(string[] fileNames) {
            StateFactory.Instance.StateDatabase = this;
            StateFactory.Instance.OnStatesLoaded += FactoryOnStatesLoaded;
            StateFactory.Instance.Produce();

            foreach (string stateFileName in fileNames) {
                StateFactory.Instance.AddFile(stateFileName);
            }

            StateFactory.Instance.FinishedAddingFiles();
        }

        public State GetState(int idx) {
            return _states[idx];
        }

        public void Dispose() {
            if (_faceIndexBuffers != null) {
                for (int i = 0; i < _faceIndexBuffers.Length; ++i) {
                    _faceIndexBuffers[i]?.Dispose();
                }
            }
        }

        public float GetIEEEValue(byte[] buff, int n) {
            float d;

            if (_wordSize == 4) {
                d = BitConverter.ToSingle(buff, n * 4);
            } else {
                d = (float) BitConverter.ToDouble(buff, n * 8);
            }

            return d;
        }

        private void DeserializeTitles(BinaryReader reader) {
            byte[] buff = reader.ReadBytes(FEMLEN);

            int wordIdx = 1;
            int titleType;

            if (_wordSize == 4) {
                titleType = BitConverter.ToInt32(buff, 0);
            } else {
                titleType = (int) BitConverter.ToInt64(buff, 0);
            }

            while (true) {
                switch (titleType) {
                    case 90000:
                        _headerTitle = Encoding.ASCII.GetString(buff, wordIdx * _wordSize, 72).Trim();
                        wordIdx += 72 / _wordSize;
                        break;

                    case 90001:
                        int numPart = BitConverter.ToInt32(buff, wordIdx++ * _wordSize);

                        for (int i = 0; i < numPart; ++i) {
                            int partId = BitConverter.ToInt32(buff, wordIdx++ * _wordSize);
                            string partTitle = Encoding.ASCII.GetString(buff, wordIdx * _wordSize, 72).Trim();
                            wordIdx += 72 / _wordSize;
                            _partTitles[partId] = partTitle;
                        }

                        break;

                    case 90002:
                        int numCon = BitConverter.ToInt32(buff, wordIdx++ * _wordSize);

                        for (int i = 0; i < numCon; ++i) {
                            int partId = BitConverter.ToInt32(buff, wordIdx++ * _wordSize);
                            string contactTitle = Encoding.ASCII.GetString(buff, wordIdx * _wordSize, 72).Trim();
                            wordIdx += 72 / _wordSize;
                            _contactTitles[partId] = contactTitle;
                        }

                        break;

                    case 90020:
                        throw new UnsupportedFeatureException(
                            "The documentation doesn't tell you enough about what to expect.");

                    case 90021:
                        int numProp = BitConverter.ToInt32(buff, wordIdx++ * _wordSize);

                        for (int i = 0; i < numProp; ++i) {
                            int partId = BitConverter.ToInt32(buff, wordIdx++ * _wordSize);
                            string partTitle = Encoding.ASCII.GetString(buff, wordIdx * _wordSize, 72).Trim();
                            wordIdx += 72 / _wordSize;
                            _propPartTitles[partId] = partTitle;
                        }

                        break;

                    case 90100:
                        int numKeywords = BitConverter.ToInt32(buff, wordIdx++ * _wordSize);

                        for (int i = 0; i < numKeywords; ++i) {
                            string partTitle = Encoding.ASCII.GetString(buff, wordIdx * _wordSize, 72).Trim();
                            wordIdx += 72 / _wordSize;
                            _keywords.Add(partTitle);
                        }

                        break;
                }

                if (_wordSize == 4) {
                    float eof = BitConverter.ToSingle(buff, wordIdx * _wordSize);
                    if (eof == -999999.0f) {
                        break;
                    }

                    titleType = BitConverter.ToInt32(buff, wordIdx++ * _wordSize);
                } else {
                    double eof = BitConverter.ToDouble(buff, wordIdx * _wordSize);
                    if (eof == -999999.0) {
                        break;
                    }

                    titleType = (int) BitConverter.ToInt64(buff, wordIdx++ * _wordSize);
                }
            }
        }

        private void DeserializeUserElementIDs(BinaryReader reader) {
            if (_wordSize == 4) {
                _userElementIDs.nsort = reader.ReadInt32();
            } else {
                _userElementIDs.nsort = reader.ReadInt64();
            }

            byte[] buff = reader.ReadBytes(9 * _wordSize);
            _userElementIDs.nsrh = BitConverter.ToInt64(buff, 0 * _wordSize);
            _userElementIDs.nsrb = BitConverter.ToInt64(buff, 1 * _wordSize);
            _userElementIDs.nsrs = BitConverter.ToInt64(buff, 2 * _wordSize);
            _userElementIDs.nsrt = BitConverter.ToInt64(buff, 3 * _wordSize);
            _userElementIDs.nsortd = BitConverter.ToInt32(buff, 4 * _wordSize);
            _userElementIDs.nsrhd = BitConverter.ToInt32(buff, 5 * _wordSize);
            _userElementIDs.nsrbd = BitConverter.ToInt32(buff, 6 * _wordSize);
            _userElementIDs.nsrsd = BitConverter.ToInt32(buff, 7 * _wordSize);
            _userElementIDs.nsrtd = BitConverter.ToInt32(buff, 8 * _wordSize);

            if (_userElementIDs.nsort < 0) {
                buff = reader.ReadBytes(6 * _wordSize);
                _userElementIDs.nsort = -_userElementIDs.nsort;
                _userElementIDs.nsrma = BitConverter.ToInt64(buff, 0 * _wordSize);
                _userElementIDs.nsrmu = BitConverter.ToInt64(buff, 1 * _wordSize);
                _userElementIDs.nsrmp = BitConverter.ToInt64(buff, 2 * _wordSize);
                _userElementIDs.nsrtm = BitConverter.ToInt32(buff, 3 * _wordSize);
                _userElementIDs.numrbs = BitConverter.ToInt32(buff, 4 * _wordSize);
                _userElementIDs.nmmat = BitConverter.ToInt32(buff, 5 * _wordSize);
            }

            _userElementIDs.nusern = new int[_userElementIDs.nsortd];
            buff = reader.ReadBytes(_userElementIDs.nsortd * _wordSize);

            for (int i = 0; i < _userElementIDs.nsortd; ++i) {
                _userElementIDs.nusern[i] = BitConverter.ToInt32(buff, i * _wordSize);
            }

            _userElementIDs.nuserh = new int[_userElementIDs.nsrhd];
            buff = reader.ReadBytes(_userElementIDs.nsrhd * _wordSize);

            for (int i = 0; i < _userElementIDs.nsrhd; ++i) {
                _userElementIDs.nuserh[i] = BitConverter.ToInt32(buff, i * _wordSize);
            }

            _userElementIDs.nuserb = new int[_userElementIDs.nsrbd];
            buff = reader.ReadBytes(_userElementIDs.nsrbd * _wordSize);

            for (int i = 0; i < _userElementIDs.nsrbd; ++i) {
                _userElementIDs.nuserb[i] = BitConverter.ToInt32(buff, i * _wordSize);
            }

            _userElementIDs.nusers = new int[_userElementIDs.nsrsd];
            buff = reader.ReadBytes(_userElementIDs.nsrsd * _wordSize);

            for (int i = 0; i < _userElementIDs.nsrsd; ++i) {
                _userElementIDs.nusers[i] = BitConverter.ToInt32(buff, i * _wordSize);
            }

            _userElementIDs.nusert = new int[_userElementIDs.nsrtd];
            buff = reader.ReadBytes(_userElementIDs.nsrtd * _wordSize);

            for (int i = 0; i < _userElementIDs.nsrtd; ++i) {
                _userElementIDs.nusert[i] = BitConverter.ToInt32(buff, i * _wordSize);
            }

            _userElementIDs.norder = new int[_userElementIDs.nmmat];
            buff = reader.ReadBytes(_userElementIDs.nmmat * _wordSize);

            for (int i = 0; i < _userElementIDs.nmmat; ++i) {
                _userElementIDs.norder[i] = BitConverter.ToInt32(buff, i * _wordSize);
            }

            _userElementIDs.ansrmu = new int[_userElementIDs.nmmat];
            buff = reader.ReadBytes(_userElementIDs.nmmat * _wordSize);

            for (int i = 0; i < _userElementIDs.nmmat; ++i) {
                _userElementIDs.ansrmu[i] = BitConverter.ToInt32(buff, i * _wordSize);
            }

            _userElementIDs.ansrmp = new int[_userElementIDs.nmmat];
            buff = reader.ReadBytes(_userElementIDs.nmmat * _wordSize);

            for (int i = 0; i < _userElementIDs.nmmat; ++i) {
                _userElementIDs.ansrmp[i] = BitConverter.ToInt32(buff, i * _wordSize);
            }
        }

        private void DeserializeGeometry(BinaryReader reader) {
            int numNodeDims = _controlData.ndim * _controlData.numnp;
            byte[] buff = reader.ReadBytes(numNodeDims * _wordSize);

            _nodeCoordinates = new State.NodeData[_controlData.numnp];

            if (_controlData.ndim == 3) {
                for (int i = 0; i < _controlData.numnp; ++i) {
                    float x = GetIEEEValue(buff, (i * 3) + 0);
                    float y = GetIEEEValue(buff, (i * 3) + 1);
                    float z = GetIEEEValue(buff, (i * 3) + 2);
                    State.NodeData nodeData = new State.NodeData();
                    nodeData.position = new float3(x, y, z);
                    nodeData.materialIndex = 0;
                    _nodeCoordinates[i] = nodeData;
                    _boundingBox.Contain(new Vector3f(x, y, z));
                }
            } else {
                for (int i = 0; i < _controlData.numnp; ++i) {
                    float x = GetIEEEValue(buff, (i * 2) + 0);
                    float z = GetIEEEValue(buff, (i * 2) + 1);
                    State.NodeData nodeData = new State.NodeData();
                    nodeData.position = new float3(x, 0.0f, z);
                    nodeData.materialIndex = 0;
                    _nodeCoordinates[i] = nodeData;
                    _boundingBox.Contain(new Vector3f(x, 0.0f, z));
                }
            }

            if (_controlData.nel8 >= 0) {
                // Assumes tetrahedra.
                _elementVertices = new int4[_controlData.nel8];
                _elementMaterial = new int[_controlData.nel8];
                buff = reader.ReadBytes(_controlData.nel8 * 9 * _wordSize);

                HashSet<TetrahedronFace> boundaryFaces = new HashSet<TetrahedronFace>(new WingedFaceComparer());
                _faceIdxCount = new int[_controlData.TotalMaterialCount];

                for (int i = 0; i < _controlData.nel8 * 9; i += 9) {
                    int a = BitConverter.ToInt32(buff, (i + 0) * _wordSize) - 1;
                    int b = BitConverter.ToInt32(buff, (i + 1) * _wordSize) - 1;
                    int c = BitConverter.ToInt32(buff, (i + 2) * _wordSize) - 1;
                    int d = BitConverter.ToInt32(buff, (i + 3) * _wordSize) - 1;
                    int e = BitConverter.ToInt32(buff, (i + 4) * _wordSize) - 1;

                    if (d != e) {
                        throw new UnsupportedFeatureException("Only tetrahedral elements are supported");
                    }

                    _elementVertices[i / 9] = new int4(a, b, c, d);
                    int material = BitConverter.ToInt32(buff, (i + 8) * _wordSize) - 1;
                    _elementMaterial[i / 9] = material;

                    TetrahedronFace face = new TetrahedronFace(new int3(a, c, b), material);
                    ++_faceIdxCount[material];
                    if (!boundaryFaces.Add(face)) {
                        boundaryFaces.Remove(face);
                        --_faceIdxCount[material];
                    }
                    
                    face = new TetrahedronFace(new int3(a, b, d), material);
                    ++_faceIdxCount[material];
                    if (!boundaryFaces.Add(face)) {
                        boundaryFaces.Remove(face);
                        --_faceIdxCount[material];
                    }

                    face = new TetrahedronFace(new int3(a, d, c), material);
                    ++_faceIdxCount[material];
                    if (!boundaryFaces.Add(face)) {
                        boundaryFaces.Remove(face);
                        --_faceIdxCount[material];
                    }

                    face = new TetrahedronFace(new int3(d, b, c), material);
                    ++_faceIdxCount[material];
                    if (!boundaryFaces.Add(face)) {
                        boundaryFaces.Remove(face);
                        --_faceIdxCount[material];
                    }
                }

                // Expand out the boundary faces indices.
                List<int>[] facesIndices = new List<int>[_controlData.TotalMaterialCount];
                foreach (TetrahedronFace face in boundaryFaces) {
                    if (facesIndices[face.material] == null) {
                        facesIndices[face.material] = new List<int>(_faceIdxCount[face.material]);
                    }
                    
                    facesIndices[face.material].Add(face.indices.x);
                    facesIndices[face.material].Add(face.indices.y);
                    facesIndices[face.material].Add(face.indices.z);
                    _nodeCoordinates[face.indices.x].materialIndex = face.material;
                    _nodeCoordinates[face.indices.y].materialIndex = face.material;
                    _nodeCoordinates[face.indices.z].materialIndex = face.material;
                }

                if (_faceIndexBuffers != null) {
                    for (int i = 0; i < _faceIndexBuffers.Length; ++i) {
                        _faceIndexBuffers[i]?.Release();
                    }
                }

                _faceIndexBuffers = new GraphicsBuffer[facesIndices.Length];

                for (int i = 0; i < facesIndices.Length; ++i) {
                    _faceIndexBuffers[i] = new GraphicsBuffer(GraphicsBuffer.Target.Index, _faceIdxCount[i], 4);
                    _faceIndexBuffers[i].SetData(facesIndices[i].ToArray());
                }

            } else {
                throw new UnsupportedFeatureException("Ten node solids not supported.");
            }

            if (_controlData.nelt > 0) {
                throw new UnsupportedFeatureException("Eight node thick shells not supported.");
                // for (int i = 0; i < _controlData.nelt * 9; i += 9) {
                // }
            }

            if (_controlData.nel2 > 0) {
                throw new UnsupportedFeatureException("Two node 1D elements not supported.");
                // for (int i = 0; i < _controlData.nel2 * 6; i += 6) {}
            }
        }

        private void DeserializeHigherSolidElements(BinaryReader reader) {
            int numElems = reader.ReadInt32();

            byte[] buff = reader.ReadBytes(9 * numElems * _wordSize);

            for (int i = 0; i < numElems * 9; i += 9) {
                HigherSolidElementPart part = new HigherSolidElementPart();
                part.pid = BitConverter.ToInt32(buff, (i + 0) * _wordSize);
                part.mid = BitConverter.ToInt32(buff, (i + 1) * _wordSize);
                part.eos = BitConverter.ToInt32(buff, (i + 2) * _wordSize);
                part.eform = BitConverter.ToInt32(buff, (i + 3) * _wordSize);
                part.nmnp = BitConverter.ToInt32(buff, (i + 4) * _wordSize);
                part.ngp = BitConverter.ToInt32(buff, (i + 5) * _wordSize);
                part.lengp = BitConverter.ToInt32(buff, (i + 6) * _wordSize);
                part.nhisv = BitConverter.ToInt32(buff, (i + 7) * _wordSize);
                part.istrn = BitConverter.ToInt32(buff, (i + 8) * _wordSize);
                _higherSolidElementParts.Add(part);
            }
        }

        private bool is64Bits(BinaryReader reader) {
            long pos = reader.BaseStream.Position;

            try {
                reader.BaseStream.Seek(44, SeekOrigin.Begin);
                int ft32 = reader.ReadInt32();
                if (ft32 > 1000) {
                    ft32 -= 1000;
                }

                if (ft32 == 1 || ft32 == 5 || ft32 == 11) {
                    reader.BaseStream.Seek(pos, SeekOrigin.Begin);
                    return false;
                }

                reader.BaseStream.Seek(88, SeekOrigin.Begin);
                Int64 ft64 = reader.ReadInt64();
                if (ft64 > 1000) {
                    ft64 -= 1000;
                }

                if (ft64 == 1 || ft64 == 5 || ft64 == 11) {
                    reader.BaseStream.Seek(pos, SeekOrigin.Begin);
                    return true;
                }
            } catch (EndOfStreamException) {
                throw new FormatException("The file is too small, and I cannot determine the wordsize for this file");
            }

            throw new FormatException("I cannot determine the wordsize for this file");
        }

        private void DeserializeControlData(BinaryReader reader) {
            byte[] buff = reader.ReadBytes(64 * _wordSize);

            _controlData.ncfdv1 = BitConverter.ToInt32(buff, 48 * _wordSize);
            if (_controlData.ncfdv1 == 67108864) {
                throw new UnsupportedFeatureException("Can not handle CFD Multi-Solver data.");
            }

            _controlData.title = Encoding.ASCII.GetString(buff, 0, 10 * _wordSize).Trim();

            int secsSinceEpoch = BitConverter.ToInt32(buff, 10 * _wordSize);
            DateTime dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            _controlData.runtime = dtDateTime.AddSeconds(secsSinceEpoch);

            int fileType = BitConverter.ToInt32(buff, 11 * _wordSize);

            _controlData.sourceversion = BitConverter.ToInt32(buff, 12 * _wordSize);
            double vv = _controlData.sourceversion / 1000000.0;
            _controlData.ls_dyna_ver = (int) Math.Truncate(vv);
            _controlData.svn_number = (int) Math.Round((vv - _controlData.ls_dyna_ver) * 1000000.0);

            string rn = Encoding.ASCII.GetString(buff, 13 * _wordSize, 4);
            _controlData.releasenumber = $"{rn[0]}{rn[1]}.{rn[2]}{rn[3]}".Trim();

            if (_wordSize == 4) {
                _controlData.version = BitConverter.ToSingle(buff, 14 * _wordSize);
            } else {
                _controlData.version = BitConverter.ToDouble(buff, 14 * _wordSize);
            }

            _controlData.ndim = BitConverter.ToInt32(buff, 15 * _wordSize);
            _controlData.numnp = BitConverter.ToInt32(buff, 16 * _wordSize);
            _controlData.icode = BitConverter.ToInt32(buff, 17 * _wordSize);
            _controlData.nglbv = BitConverter.ToInt32(buff, 18 * _wordSize);
            _controlData.it = BitConverter.ToInt32(buff, 19 * _wordSize);
            _controlData.iu = BitConverter.ToInt32(buff, 20 * _wordSize);
            _controlData.iv = BitConverter.ToInt32(buff, 21 * _wordSize);
            _controlData.ia = BitConverter.ToInt32(buff, 22 * _wordSize);
            _controlData.nel8 = BitConverter.ToInt32(buff, 23 * _wordSize);
            _controlData.nummat8 = BitConverter.ToInt32(buff, 24 * _wordSize);
            _controlData.numds = BitConverter.ToInt32(buff, 25 * _wordSize);
            _controlData.numst = BitConverter.ToInt32(buff, 26 * _wordSize);
            _controlData.nv3d = BitConverter.ToInt32(buff, 27 * _wordSize);
            _controlData.nel2 = BitConverter.ToInt32(buff, 28 * _wordSize);
            _controlData.nummat2 = BitConverter.ToInt32(buff, 29 * _wordSize);
            _controlData.nv1d = BitConverter.ToInt32(buff, 30 * _wordSize);
            _controlData.nel4 = BitConverter.ToInt32(buff, 31 * _wordSize);
            _controlData.nummat4 = BitConverter.ToInt32(buff, 32 * _wordSize);
            _controlData.nv2d = BitConverter.ToInt32(buff, 33 * _wordSize);
            _controlData.neiph = BitConverter.ToInt32(buff, 34 * _wordSize);
            _controlData.neips = BitConverter.ToInt32(buff, 35 * _wordSize);
            _controlData.maxint = BitConverter.ToInt32(buff, 36 * _wordSize);
            _controlData.nmsph = BitConverter.ToInt32(buff, 37 * _wordSize);
            _controlData.ngpsph = BitConverter.ToInt32(buff, 38 * _wordSize);
            _controlData.narbs = BitConverter.ToInt32(buff, 39 * _wordSize);
            _controlData.nelt = BitConverter.ToInt32(buff, 40 * _wordSize);
            _controlData.nummatt = BitConverter.ToInt32(buff, 41 * _wordSize);
            _controlData.nv3dt = BitConverter.ToInt32(buff, 42 * _wordSize);
            _controlData.ioshl1 = BitConverter.ToInt32(buff, 43 * _wordSize);
            _controlData.ioshl2 = BitConverter.ToInt32(buff, 44 * _wordSize);
            _controlData.ioshl3 = BitConverter.ToInt32(buff, 45 * _wordSize);
            _controlData.ioshl4 = BitConverter.ToInt32(buff, 46 * _wordSize);
            _controlData.ialemat = BitConverter.ToInt32(buff, 47 * _wordSize);
            _controlData.ncfdv2 = BitConverter.ToInt32(buff, 40 * _wordSize);
            _controlData.nadapt = BitConverter.ToInt32(buff, 50 * _wordSize);
            _controlData.nmmat = BitConverter.ToInt32(buff, 51 * _wordSize);
            _controlData.numfluid = BitConverter.ToInt32(buff, 52 * _wordSize);
            _controlData.inn = BitConverter.ToInt32(buff, 53 * _wordSize);
            _controlData.npefg = BitConverter.ToInt32(buff, 54 * _wordSize);
            _controlData.nel48 = BitConverter.ToInt32(buff, 55 * _wordSize);
            _controlData.idtdt = BitConverter.ToInt32(buff, 56 * _wordSize);
            _controlData.ExtraSize = BitConverter.ToInt32(buff, 57 * _wordSize);
            _controlData.words = new int[6];
            Array.Copy(buff, 58 * _wordSize, _controlData.words, 0, 6);

            if (_controlData.ExtraSize > 0) {
                byte[] extraBuff = reader.ReadBytes(_controlData.ExtraSize * _wordSize);
                _controlData.extra.nel20 = _controlData.ExtraSize > 0 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 0 * _wordSize)
                    : 0;
                _controlData.extra.nt3d = _controlData.ExtraSize > 1 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 1 * _wordSize)
                    : 0;
                _controlData.extra.nel27 = _controlData.ExtraSize > 2 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 2 * _wordSize)
                    : 0;
                _controlData.extra.neipb = _controlData.ExtraSize > 3 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 3 * _wordSize)
                    : 0;
                _controlData.extra.nel21p = _controlData.ExtraSize > 4 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 4 * _wordSize)
                    : 0;
                _controlData.extra.nel15t = _controlData.ExtraSize > 5 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 5 * _wordSize)
                    : 0;
                _controlData.extra.soleng = _controlData.ExtraSize > 6 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 6 * _wordSize)
                    : 0;
                _controlData.extra.nel20t = _controlData.ExtraSize > 7 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 7 * _wordSize)
                    : 0;
                _controlData.extra.nel40p = _controlData.ExtraSize > 8 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 8 * _wordSize)
                    : 0;
                _controlData.extra.nel64 = _controlData.ExtraSize > 9 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 9 * _wordSize)
                    : 0;
                _controlData.extra.quadr = _controlData.ExtraSize > 10 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 10 * _wordSize)
                    : 0;
                _controlData.extra.cubic = _controlData.ExtraSize > 11 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 11 * _wordSize)
                    : 0;
                _controlData.extra.tsheng = _controlData.ExtraSize > 12 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 12 * _wordSize)
                    : 0;
                _controlData.extra.nbranch = _controlData.ExtraSize > 13 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 13 * _wordSize)
                    : 0;
                _controlData.extra.penout = _controlData.ExtraSize > 14 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 14 * _wordSize)
                    : 0;
                _controlData.extra.engout = _controlData.ExtraSize > 15 * _wordSize
                    ? BitConverter.ToInt32(extraBuff, 15 * _wordSize)
                    : 0;
            }

            // Parse header.
            if (fileType > 1000) {
                fileType -= 1000;
                _controlData.ExternalNumbersInt64 = true;
            } else {
                _controlData.ExternalNumbersInt64 = false;
            }

            _controlData.filetype = (ControlData.INUM) fileType;

            if (_controlData.filetype != ControlData.INUM.d3plot && _controlData.filetype != ControlData.INUM.d3part &&
                _controlData.filetype != ControlData.INUM.d3eigv) {
                throw new UnsupportedFeatureException($"File of type {_controlData.filetype} is not supported");
            }

            switch (_controlData.ndim) {
                case 2:
                case 3:
                    break;

                case 4:
                    _controlData.UnpackedElementConnectivities = true;
                    break;
                case 5:
                    _controlData.mattyp = 1;
                    _controlData.UnpackedElementConnectivities = true;
                    break;
                case 6:
                    _controlData.HasRigidRoadSurface = true;
                    break;
                case 7:
                    _controlData.mattyp = 1;
                    _controlData.HasRigidRoadSurface = true;
                    _controlData.UnpackedElementConnectivities = true;
                    break;
                case 8:
                    _controlData.HasRigidBodyData = true;
                    break;
                case 9:
                    _controlData.HasRigidRoadSurface = true;
                    _controlData.HasRigidBodyData = true;
                    break;

                default:
                    throw new UnsupportedFeatureException($"Unexpected number of dimensions {_controlData.ndim}");
            }

            _controlData.ndim = Math.Min(_controlData.ndim, 3);

            _controlData.HasMassScaling = _controlData.it >= 10;
            _controlData.it %= 10;

            if (_controlData.nel8 < 0) {
                _controlData.nel8 = -_controlData.nel8;
                _controlData.HasNel10 = true;
            }

            if (_controlData.maxint < -10000) {
                _controlData.mdlopt = 2;
                _controlData.maxint = (-_controlData.maxint) - 10000;
            } else if (_controlData.maxint < 0) {
                _controlData.mdlopt = 1;
                _controlData.maxint = -_controlData.maxint;
            }

            if (_controlData.ioshl1 == 1000) {
                _controlData.ioshl1 = 1;
                _controlData.iosol1 = 1;
            } else if (_controlData.ioshl1 == 999) {
                _controlData.ioshl1 = 0;
                _controlData.iosol1 = 1;
            } else {
                _controlData.ioshl1 = 0;
                _controlData.iosol1 = 0;
            }

            if (_controlData.ioshl2 == 1000) {
                _controlData.ioshl2 = 1;
                _controlData.iosol2 = 1;
            } else if (_controlData.ioshl2 == 999) {
                _controlData.ioshl2 = 0;
                _controlData.iosol2 = 1;
            } else {
                _controlData.ioshl2 = 0;
                _controlData.iosol2 = 0;
            }

            _controlData.ioshl3 = _controlData.ioshl3 == 1000 ? 1 : 0;
            _controlData.ioshl4 = _controlData.ioshl4 == 1000 ? 1 : 0;

            _controlData.HasTemperatureGradient = (_controlData.idtdt % 2) == 1;
            _controlData.HasResidualForces = ((_controlData.idtdt / 10) % 2) == 1;
            _controlData.HasPlasticStrainTensor = ((_controlData.idtdt / 100) % 2) == 1;
            _controlData.HasThermalStrainTensor = ((_controlData.idtdt / 1000) % 2) == 1;

            int shellVarsBehindLayers = _controlData.nv2d -
                                        _controlData.maxint * (6 * _controlData.ioshl1 + _controlData.ioshl2 +
                                                               _controlData.neips) + 8 * _controlData.ioshl3 +
                                        4 * _controlData.ioshl4;

            if ((_controlData.HasPlasticStrainTensor || _controlData.HasThermalStrainTensor)) {
                _controlData.istrn = ((_controlData.idtdt / 10000) % 2);
            } else {
                if (_controlData.nv2d > 0) {
                    _controlData.istrn = shellVarsBehindLayers > 1 ? 1 : 0;
                } else if (_controlData.nelt > 0) {
                    int v = _controlData.nv3dt - _controlData.maxint *
                        (6 * _controlData.ioshl1 + _controlData.ioshl2 + _controlData.neips);
                    _controlData.istrn = v > 1 ? 1 : 0;
                } else {
                    _controlData.istrn = 0;
                }
            }

            if (_controlData.istrn == 0) {
                if (shellVarsBehindLayers > 1 && shellVarsBehindLayers < 6) {
                    _controlData.HasInternalEnergy = true;
                }
            } else {
                if (shellVarsBehindLayers > 12) {
                    _controlData.HasInternalEnergy = true;
                }
            }

            _controlData.TotalNumberOfElements =
                _controlData.nel8 + _controlData.nel2 + _controlData.nel4 + _controlData.nelt;
        }

        private void FactoryOnStatesLoaded() {
            while (StateFactory.Instance.StatesAvailable()) {
                State state = StateFactory.Instance.PopState();

                if (state != null) {
                    _states.Add(state);
                }
            }

            _states.Sort();
        }
    }
}