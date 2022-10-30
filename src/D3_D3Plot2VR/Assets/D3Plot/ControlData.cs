using System;

namespace D3Plot {
    public struct ControlData {
        public enum INUM {
            d3plot = 1,
            d3drlf = 2,
            d3thdt = 3,
            intfor = 4,
            d3part = 5,
            blstfor = 6,
            d3cpm = 7,
            d3ale = 8,
            d3eigv = 11,
            d3mode = 12,
            d3iter = 13,
            d3ssd = 21,
            d3spcm = 22,
            d3psd = 23,
            d3rms = 24,
            d3ftg = 25,
            d3acs = 26
        }
        
        public string title;
        public DateTime runtime;
        public INUM filetype;
        public int sourceversion;
        public string releasenumber;
        public double version;
        public int ls_dyna_ver;
        public int svn_number;
        public int ndim;
        public int numnp;
        public int icode;
        public int nglbv;
        public int it;
        public int iu;
        public int iv;
        public int ia;
        public int nel8;                // Count of hex elements (may include tets too).  is also the total number of solid elements
        public int nummat8;
        public int numds;
        public int numst;
        public int nv3d;
        public int nel2;
        public int nummat2;
        public int nv1d;
        public int nel4;
        public int nummat4;
        public int nv2d;
        public int neiph;
        public int neips;
        public int maxint;
        public int nmsph;
        public int ngpsph;
        public int narbs;
        public int nelt;
        public int nummatt;
        public int nv3dt;
        public int ioshl1;
        public int ioshl2;
        public int ioshl3;
        public int ioshl4;
        public int ialemat;
        public int ncfdv1;
        public int ncfdv2;
        public int nadapt;
        public int nmmat;
        public int numfluid;
        public int inn;
        public int npefg;
        public int nel48;
        public int idtdt;
        public int ExtraSize;
        public int[] words;
        public ControlDataExtra extra;

        // Derived values.
        public int mattyp;
        public bool ExternalNumbersInt64;
        public bool HasRigidRoadSurface;
        public bool HasRigidBodyData;
        public bool UnpackedElementConnectivities;
        public bool HasMassScaling;
        public bool HasNel10;
        public bool HasTemperatureGradient;
        public bool HasResidualForces;
        public bool HasPlasticStrainTensor;
        public bool HasThermalStrainTensor;
        public bool HasInternalEnergy;
        public int mdlopt;
        public int iosol1;
        public int iosol2;
        public int istrn;
        public int TotalNumberOfElements;

        public int TotalMaterialCount => nummat2 + nummat4 + nummat8 + nummatt;
    }

    public struct ControlDataExtra {
        public int nel20;
        public int nt3d;
        public int nel27;
        public int neipb;
        public int nel21p;
        public int nel15t;
        public int soleng;
        public int nel20t;
        public int nel40p;
        public int nel64;
        public int quadr;
        public int cubic;
        public int tsheng;
        public int nbranch;
        public int penout;
        public int engout;
    }
}