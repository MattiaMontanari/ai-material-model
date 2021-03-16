using System;
using System.IO;
using g3;
using Unity.Mathematics;
using UnityEngine;

namespace D3Plot {
    public class State : IComparable<State> {
        public struct NodeData {
            public float3 position;
            public int materialIndex;
        }

        public NodeData[] NodeCoordinates => _nodeCoordinates;
        
        public Box3f BoundingBox => _boundingBox;
        
        private double _time;
        private StateGlobals _globals;
        private float[,] _nodeTemperatures;
        private float[,] _thermalData;
        private float[,] _solidElementData;
        private int[] _elementDeleted;
        private NodeData[] _nodeCoordinates;
        private float3[] _nodeVelocities;
        private float3[] _nodeAccelerations;
        private Box3f _boundingBox;

        private readonly ControlData _controlData;
        private readonly int WORDSIZE;
        private readonly StateDatabase _stateDatabase;

        public State(StateDatabase stateDatabase) {
            _stateDatabase = stateDatabase;
            _controlData = _stateDatabase.Control;
            WORDSIZE = _stateDatabase.WordSize;
            _boundingBox = Box3f.Empty;
        }

        public void Parse(double time, Stream stream) {
            _time = time;

            DeserializeGlobals(stream);
            DeserializeNodeData(stream);
        }
        
        private void DeserializeNodeData(Stream stream) {
            int n = 0;

            if (_controlData.it == 2) {
                n = 2;
            } else if (_controlData.it == 3) {
                n = 3;
            }

            if (_controlData.HasMassScaling) {
                n += 1;
            }

            int temperature_vars = (_controlData.it + n);

            if (temperature_vars > 0) {
                _nodeTemperatures = new float[_controlData.numnp, temperature_vars];

                for (int i = 0; i < _controlData.numnp; ++i) {
                    byte[] temp_buff = new byte[temperature_vars * WORDSIZE];
                    stream.Read(temp_buff, 0, temp_buff.Length);

                    for (int v = 0; v < temperature_vars; ++v) {
                        _nodeTemperatures[i, v] = _stateDatabase.GetIEEEValue(temp_buff, v);
                    }
                }
            }

            byte[] nodebuff = new byte[_controlData.numnp * _controlData.ndim * WORDSIZE];

            if (_controlData.iu == 1) {
                _nodeCoordinates = new NodeData[_controlData.numnp];
                stream.Read(nodebuff, 0, nodebuff.Length);

                for (int i = 0; i < _controlData.numnp; ++i) {
                    float x = _stateDatabase.GetIEEEValue(nodebuff, (i * 3) + 0);
                    float y = _stateDatabase.GetIEEEValue(nodebuff, (i * 3) + 1);
                    float z = _stateDatabase.GetIEEEValue(nodebuff, (i * 3) + 2);
                    NodeData nodeData = new NodeData();
                    nodeData.position = new float3(x, y, z);
                    _nodeCoordinates[i] = nodeData;
                    _boundingBox.Contain(new Vector3f(x, y, z));
                }
            }

            if (_controlData.iv == 1) {
                _nodeVelocities = new float3[_controlData.numnp];
                stream.Read(nodebuff, 0, nodebuff.Length);

                for (int i = 0; i < _controlData.numnp; ++i) {
                    float x = _stateDatabase.GetIEEEValue(nodebuff, (i * 3) + 0);
                    float y = _stateDatabase.GetIEEEValue(nodebuff, (i * 3) + 1);
                    float z = _stateDatabase.GetIEEEValue(nodebuff, (i * 3) + 2);
                    _nodeVelocities[i] = new float3(x, y, z);
                }
            }

            if (_controlData.ia == 1) {
                _nodeAccelerations = new float3[_controlData.numnp];
                stream.Read(nodebuff, 0, nodebuff.Length);

                for (int i = 0; i < _controlData.numnp; ++i) {
                    float x = _stateDatabase.GetIEEEValue(nodebuff, (i * 3) + 0);
                    float y = _stateDatabase.GetIEEEValue(nodebuff, (i * 3) + 1);
                    float z = _stateDatabase.GetIEEEValue(nodebuff, (i * 3) + 2);
                    _nodeAccelerations[i] = new float3(x, y, z);
                }
            }

            // Thermal data
            int thermdata = _controlData.extra.nt3d * _controlData.nel8;
            if (thermdata > 0) {
                Debug.Log($"Thermal data {thermdata}");
                _thermalData = new float[_controlData.nel8, _controlData.extra.nt3d];
                byte[] buff = new byte[_controlData.extra.nt3d * _controlData.nel8 * WORDSIZE];
                stream.Read(buff, 0, buff.Length);

                for (int e = 0; e < _controlData.nel8; ++e) {
                    for (int t = 0; t < _controlData.extra.nt3d; ++t) {
                        _thermalData[e, t] = _stateDatabase.GetIEEEValue(buff, (e * _controlData.extra.nt3d) + t);
                    }
                }
            }

            // CFD data
            if (_controlData.ncfdv1 != 0 || _controlData.ncfdv2 != 0) {
                throw new UnsupportedFeatureException("CFDDATA is not supported.");
            }

            // Element data
            // int elemdata = _controlData.nel8 * _controlData.nv3d + _controlData.nelt * _controlData.nv3dt +
            // _controlData.nel2 * _controlData.nv1d + _controlData.nel4 * _controlData.nv2d;

            if (_controlData.nmsph > 0) {
                // Smooth particle element data: _controlData.nmsph * num_sph_vars;
                throw new UnsupportedFeatureException("Smooth particles are not supported.");
            }

            // Solids
            int numSolidElementValues = _controlData.nv3d + _controlData.neiph;
            if (numSolidElementValues > 0) {
                _solidElementData = new float[_controlData.nel8, numSolidElementValues];
                byte[] buff = new byte[numSolidElementValues * _controlData.nel8 * WORDSIZE];
                stream.Read(buff, 0, buff.Length);

                for (int e = 0; e < _controlData.nel8; ++e) {
                    for (int v = 0; v < numSolidElementValues; ++v) {
                        _solidElementData[e, v] = _stateDatabase.GetIEEEValue(buff, (e * numSolidElementValues) + v);
                    }
                }
            }

            if (_controlData.nel2 > 0) {
                throw new UnsupportedFeatureException("Beam element data is not supported.");
            }

            if (_controlData.nelt > 0) {
                throw new UnsupportedFeatureException("Thick shell element data is not supported.");
            }

            if (_controlData.nel2 > 0) {
                throw new UnsupportedFeatureException("Thin shell element data is not supported.");
            }

            if (_controlData.mdlopt == 1) {
                throw new UnsupportedFeatureException(
                    $"Element deletion option ({_controlData.mdlopt}) is not supported.");
            } else if (_controlData.mdlopt == 2) {
                _elementDeleted = new int[_controlData.TotalNumberOfElements];
                byte[] buff = new byte[_controlData.TotalNumberOfElements * WORDSIZE];
                stream.Read(buff, 0, buff.Length);

                for (int e = 0; e < _controlData.TotalNumberOfElements; ++e) {
                    _elementDeleted[e] = (int) _stateDatabase.GetIEEEValue(buff, e);
                    int material = _elementDeleted[e] - 1;
                    // TODO: Handle deleted elements properly.
                    if (material == -1) {
                        material = 2;
                    }

                    _nodeCoordinates[_stateDatabase.ElementVertices[e].x].materialIndex = material;
                    _nodeCoordinates[_stateDatabase.ElementVertices[e].y].materialIndex = material;
                    _nodeCoordinates[_stateDatabase.ElementVertices[e].z].materialIndex = material;
                    _nodeCoordinates[_stateDatabase.ElementVertices[e].w].materialIndex = material;
                }
            } else {
                for (int e = 0; e < _controlData.TotalNumberOfElements; ++e) {
                    int material = _stateDatabase.ElementMaterial[e];

                    _nodeCoordinates[_stateDatabase.ElementVertices[e].x].materialIndex = material;
                    _nodeCoordinates[_stateDatabase.ElementVertices[e].y].materialIndex = material;
                    _nodeCoordinates[_stateDatabase.ElementVertices[e].z].materialIndex = material;
                    _nodeCoordinates[_stateDatabase.ElementVertices[e].w].materialIndex = material;
                }
                
            }
        }

        private void DeserializeGlobals(Stream stream) {
            byte[] buff = new byte[_controlData.nglbv * WORDSIZE];
            stream.Read(buff, 0, buff.Length);
            _globals = new StateGlobals();
            _globals.ke = _stateDatabase.GetIEEEValue(buff, 0);
            _globals.ie = _stateDatabase.GetIEEEValue(buff, 1);
            _globals.te = _stateDatabase.GetIEEEValue(buff, 2);
            double x = _stateDatabase.GetIEEEValue(buff, 3);
            double y = _stateDatabase.GetIEEEValue(buff, 4);
            double z = _stateDatabase.GetIEEEValue(buff, 5);
            _globals.velocity = new Vector3d(x, y, z);
            int n = 6;

            // Figure out NUMRW from total number of globals I think...
            int num_parts = _controlData.TotalMaterialCount + _stateDatabase.ElementIDs.numrbs;
            int num_non_wall_variables = 7 * num_parts;
            int num_rigid_wall_variables = (_controlData.nglbv - 6) - num_non_wall_variables;
            int num_rigid_walls = num_rigid_wall_variables;

            if (_controlData.ls_dyna_ver >= 971) {
                num_rigid_walls = num_rigid_wall_variables / 4;
            }

            _globals.mat_ie = new double[num_parts];
            _globals.mat_ke = new double[num_parts];
            _globals.part_velocity = new Vector3d[num_parts];
            _globals.part_mass = new double[num_parts];
            _globals.part_hourglass_energy = new double[num_parts];

            for (int i = 0; i < num_parts; ++i) {
                _globals.mat_ie[i] = _stateDatabase.GetIEEEValue(buff, n++);
            }

            for (int i = 0; i < num_parts; ++i) {
                _globals.mat_ke[i] = _stateDatabase.GetIEEEValue(buff, n++);
            }

            for (int i = 0; i < num_parts; ++i) {
                x = _stateDatabase.GetIEEEValue(buff, n++);
                y = _stateDatabase.GetIEEEValue(buff, n++);
                z = _stateDatabase.GetIEEEValue(buff, n++);
                _globals.part_velocity[i] = new Vector3d(x, y, z);
            }

            for (int i = 0; i < num_parts; ++i) {
                _globals.part_mass[i] = _stateDatabase.GetIEEEValue(buff, n++);
            }

            for (int i = 0; i < num_parts; ++i) {
                _globals.part_hourglass_energy[i] = _stateDatabase.GetIEEEValue(buff, n++);
            }

            _globals.rigid_wall_force = new double[num_rigid_walls];
            _globals.rigid_wall_position = new Vector3d[num_rigid_walls];

            for (int i = 0; i < num_rigid_walls; ++i) {
                _globals.rigid_wall_force[i] = _stateDatabase.GetIEEEValue(buff, n++);
            }

            if (_controlData.ls_dyna_ver >= 971) {
                for (int i = 0; i < num_rigid_walls; ++i) {
                    x = _stateDatabase.GetIEEEValue(buff, n++);
                    y = _stateDatabase.GetIEEEValue(buff, n++);
                    z = _stateDatabase.GetIEEEValue(buff, n++);
                    _globals.rigid_wall_position[i] = new Vector3d(x, y, z);
                }
            }
        }

        public int CompareTo(State other) {
            return _time.CompareTo(other._time);
        }
    }
}