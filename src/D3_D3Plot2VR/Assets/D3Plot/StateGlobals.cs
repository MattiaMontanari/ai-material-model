using g3;

namespace D3Plot {
    public struct StateGlobals {
        public double ke;
        public double ie;
        public double te;
        public Vector3d velocity;
        public double[] mat_ie;
        public double[] mat_ke;
        public Vector3d[] part_velocity;
        public double[] part_mass;
        public double[] part_hourglass_energy;
        public double[] rigid_wall_force;
        public Vector3d[] rigid_wall_position;
    }
}