using System;

// ReSharper disable UnusedMember.Global

namespace g3 {
    public struct Frame3d {
        private Quaterniond _rotation;
        private Vector3d _origin;

        public static readonly Frame3d Identity = new Frame3d(Vector3d.Zero, Quaterniond.Identity);

        public Frame3d(Frame3d copy) {
            _rotation = copy._rotation;
            _origin = copy._origin;
        }

        public Frame3d(Vector3d origin) {
            _rotation = Quaterniond.Identity;
            _origin = origin;
        }

        public Frame3d(Vector3f origin) {
            _rotation = Quaterniond.Identity;
            _origin = origin;
        }

        public Frame3d(Vector3d origin, Vector3d setZ) {
            _rotation = Quaterniond.FromTo(Vector3d.AxisZ, setZ);
            _origin = origin;
        }

        public Frame3d(Vector3f origin, Vector3f setZ) {
            _rotation = Quaterniond.FromTo(Vector3d.AxisZ, setZ);
            _origin = origin;
        }

        public Frame3d(Vector3d origin, Vector3d setAxis, int nAxis) {
            if (nAxis == 0)
                _rotation = Quaterniond.FromTo(Vector3d.AxisX, setAxis);
            else if (nAxis == 1)
                _rotation = Quaterniond.FromTo(Vector3d.AxisY, setAxis);
            else
                _rotation = Quaterniond.FromTo(Vector3d.AxisZ, setAxis);
            _origin = origin;
        }

        public Frame3d(Vector3d origin, Quaterniond orientation) {
            _rotation = orientation;
            _origin = origin;
        }

        public Frame3d(Vector3d origin, Vector3d x, Vector3d y, Vector3d z) {
            _origin = origin;
            Matrix3d m = new Matrix3d(x, y, z, false);
            _rotation = m.ToQuaternion();
        }


        public Quaterniond Rotation {
            get { return _rotation; }
            set { _rotation = value; }
        }

        public Vector3d Origin {
            get { return _origin; }
            set { _origin = value; }
        }

        public Vector3d X {
            get { return _rotation.AxisX; }
        }

        public Vector3d Y {
            get { return _rotation.AxisY; }
        }

        public Vector3d Z {
            get { return _rotation.AxisZ; }
        }

        public Vector3d GetAxis(int nAxis) {
            switch (nAxis) {
                case 0:
                    return _rotation * Vector3d.AxisX;
                case 1:
                    return _rotation * Vector3d.AxisY;
                case 2:
                    return _rotation * Vector3d.AxisZ;
                default:
                    throw new ArgumentOutOfRangeException(nameof(nAxis));
            }
        }

        public void Translate(Vector3d v) {
            _origin += v;
        }

        public Frame3d Translated(Vector3d v) {
            return new Frame3d(_origin + v, _rotation);
        }

        public Frame3d Translated(double fDistance, int nAxis) {
            return new Frame3d(_origin + fDistance * GetAxis(nAxis), _rotation);
        }

        public void Scale(double f) {
            _origin *= f;
        }

        public void Scale(Vector3d scale) {
            _origin *= scale;
        }

        public Frame3d Scaled(double f) {
            return new Frame3d(f * _origin, _rotation);
        }

        public Frame3d Scaled(Vector3d scale) {
            return new Frame3d(scale * _origin, _rotation);
        }

        public void Rotate(Quaterniond q) {
            _rotation = q * _rotation;
        }

        public Frame3d Rotated(Quaterniond q) {
            return new Frame3d(_origin, q * _rotation);
        }

        public Frame3d Rotated(double fAngle, int nAxis) {
            return Rotated(new Quaterniond(GetAxis(nAxis), fAngle));
        }

        /// <summary>
        /// this rotates the frame around its own axes, rather than around the world axes,
        /// which is what Rotate() does. So, RotateAroundAxis(AxisAngleD(Z,180)) is equivalent
        /// to Rotate(AxisAngleD(My_AxisZ,180)). 
        /// </summary>
        public void RotateAroundAxes(Quaterniond q) {
            _rotation = _rotation * q;
        }

        public void RotateAround(Vector3d point, Quaterniond q) {
            Vector3d dv = q * (_origin - point);
            _rotation = q * _rotation;
            _origin = point + dv;
        }

        public Frame3d RotatedAround(Vector3d point, Quaterniond q) {
            Vector3d dv = q * (_origin - point);
            return new Frame3d(point + dv, q * _rotation);
        }

        public void AlignAxis(int nAxis, Vector3d vTo) {
            Quaterniond rot = Quaterniond.FromTo(GetAxis(nAxis), vTo);
            Rotate(rot);
        }

        public void ConstrainedAlignAxis(int nAxis, Vector3d vTo, Vector3d vAround) {
            Vector3d axis = GetAxis(nAxis);
            double fAngle = MathUtil.PlaneAngleSignedD(axis, vTo, vAround);
            Quaterniond rot = Quaterniond.AxisAngleD(vAround, fAngle);
            Rotate(rot);
        }

        /// <summary>
        /// 3D projection of point p onto frame-axis plane orthogonal to normal axis
        /// </summary>
        public Vector3d ProjectToPlane(Vector3d p, int nNormal) {
            Vector3d d = p - _origin;
            Vector3d n = GetAxis(nNormal);
            return _origin + (d - d.Dot(n) * n);
        }

        /// <summary>
        /// map from 2D coordinates in frame-axes plane perpendicular to normal axis, to 3D
        /// [TODO] check that mapping preserves orientation?
        /// </summary>
        public Vector3d FromPlaneUV(Vector2f v, int nPlaneNormalAxis) {
            Vector3d dv = new Vector3d(v[0], v[1], 0);
            if (nPlaneNormalAxis == 0) {
                dv[0] = 0;
                dv[2] = v[0];
            } else if (nPlaneNormalAxis == 1) {
                dv[1] = 0;
                dv[2] = v[1];
            }

            return _rotation * dv + _origin;
        }

        /// <summary>
        /// Project p onto plane axes
        /// [TODO] check that mapping preserves orientation?
        /// </summary>
        public Vector2f ToPlaneUV(Vector3d p, int nNormal) {
            int nAxis0 = 0, nAxis1 = 1;
            if (nNormal == 0)
                nAxis0 = 2;
            else if (nNormal == 1)
                nAxis1 = 2;
            Vector3d d = p - _origin;
            double fu = d.Dot(GetAxis(nAxis0));
            double fv = d.Dot(GetAxis(nAxis1));
            return new Vector2f(fu, fv);
        }

        ///<summary> distance from p to frame-axes-plane perpendicular to normal axis </summary>
        public double DistanceToPlane(Vector3d p, int nNormal) {
            return Math.Abs((p - _origin).Dot(GetAxis(nNormal)));
        }

        ///<summary> signed distance from p to frame-axes-plane perpendicular to normal axis </summary>
        public double DistanceToPlaneSigned(Vector3d p, int nNormal) {
            return (p - _origin).Dot(GetAxis(nNormal));
        }

        ///<summary> Map point *into* local coordinates of Frame </summary>
        public Vector3f ToFrameP(Vector3f v) {
            Vector3d x = new Vector3d(v.x - _origin.x, v.y - _origin.y, v.z - _origin.z);
            return (Vector3f)_rotation.InverseMultiply(ref x);
        }

        ///<summary> Map point *into* local coordinates of Frame </summary>
        public Vector3f ToFrameP(ref Vector3f v) {
            Vector3d x = new Vector3d(v.x - _origin.x, v.y - _origin.y, v.z - _origin.z);
            return (Vector3f)_rotation.InverseMultiply(ref x);
        }

        ///<summary> Map point *into* local coordinates of Frame </summary>
        public Vector3d ToFrameP(Vector3d v) {
            v.x -= _origin.x;
            v.y -= _origin.y;
            v.z -= _origin.z;
            return _rotation.InverseMultiply(ref v);
        }

        ///<summary> Map point *into* local coordinates of Frame </summary>
        public Vector3d ToFrameP(ref Vector3d v) {
            Vector3d x = new Vector3d(v.x - _origin.x, v.y - _origin.y, v.z - _origin.z);
            return _rotation.InverseMultiply(ref x);
        }

        /// <summary> Map point *from* local frame coordinates into "world" coordinates </summary>
        public Vector3f FromFrameP(Vector3f v) {
            return (Vector3f)(_rotation * v + _origin);
        }

        /// <summary> Map point *from* local frame coordinates into "world" coordinates </summary>
        public Vector3f FromFrameP(ref Vector3f v) {
            return (Vector3f)(_rotation * v + _origin);
        }

        /// <summary> Map point *from* local frame coordinates into "world" coordinates </summary>
        public Vector3d FromFrameP(Vector3d v) {
            return _rotation * v + _origin;
        }

        /// <summary> Map point *from* local frame coordinates into "world" coordinates </summary>
        public Vector3d FromFrameP(ref Vector3d v) {
            return _rotation * v + _origin;
        }


        ///<summary> Map vector *into* local coordinates of Frame </summary>
        public Vector3f ToFrameV(Vector3f v) {
            Vector3d x = new Vector3d(v);
            return (Vector3f)_rotation.InverseMultiply(ref x);
        }

        ///<summary> Map vector *into* local coordinates of Frame </summary>
        public Vector3f ToFrameV(ref Vector3f v) {
            Vector3d x = new Vector3d(v);
            return (Vector3f)_rotation.InverseMultiply(ref x);
        }

        ///<summary> Map vector *into* local coordinates of Frame </summary>
        public Vector3d ToFrameV(Vector3d v) {
            return _rotation.InverseMultiply(ref v);
        }

        ///<summary> Map vector *into* local coordinates of Frame </summary>
        public Vector3d ToFrameV(ref Vector3d v) {
            return _rotation.InverseMultiply(ref v);
        }

        /// <summary> Map vector *from* local frame coordinates into "world" coordinates </summary>
        public Vector3f FromFrameV(Vector3f v) {
            return (Vector3f)(_rotation * v);
        }

        /// <summary> Map vector *from* local frame coordinates into "world" coordinates </summary>
        public Vector3f FromFrameV(ref Vector3f v) {
            return (Vector3f)(_rotation * v);
        }

        /// <summary> Map vector *from* local frame coordinates into "world" coordinates </summary>
        public Vector3d FromFrameV(ref Vector3d v) {
            return _rotation * v;
        }

        /// <summary> Map vector *from* local frame coordinates into "world" coordinates </summary>
        public Vector3d FromFrameV(Vector3d v) {
            return _rotation * v;
        }


        ///<summary> Map quaternion *into* local coordinates of Frame </summary>
        public Quaterniond ToFrame(Quaterniond q) {
            return Quaterniond.Inverse(_rotation) * q;
        }

        ///<summary> Map quaternion *into* local coordinates of Frame </summary>
        public Quaterniond ToFrame(ref Quaterniond q) {
            return Quaterniond.Inverse(_rotation) * q;
        }

        /// <summary> Map quaternion *from* local frame coordinates into "world" coordinates </summary>
        public Quaterniond FromFrame(Quaterniond q) {
            return _rotation * q;
        }

        /// <summary> Map quaternion *from* local frame coordinates into "world" coordinates </summary>
        public Quaterniond FromFrame(ref Quaterniond q) {
            return _rotation * q;
        }


        ///<summary> Map ray *into* local coordinates of Frame </summary>
        public Ray3d ToFrame(Ray3d r) {
            return new Ray3d(ToFrameP(ref r.Origin), ToFrameV(ref r.Direction));
        }

        ///<summary> Map ray *into* local coordinates of Frame </summary>
        public Ray3d ToFrame(ref Ray3d r) {
            return new Ray3d(ToFrameP(ref r.Origin), ToFrameV(ref r.Direction));
        }

        /// <summary> Map ray *from* local frame coordinates into "world" coordinates </summary>
        public Ray3d FromFrame(Ray3d r) {
            return new Ray3d(FromFrameP(ref r.Origin), FromFrameV(ref r.Direction));
        }

        /// <summary> Map ray *from* local frame coordinates into "world" coordinates </summary>
        public Ray3d FromFrame(ref Ray3d r) {
            return new Ray3d(FromFrameP(ref r.Origin), FromFrameV(ref r.Direction));
        }


        ///<summary> Map frame *into* local coordinates of Frame </summary>
        public Frame3d ToFrame(Frame3d f) {
            return new Frame3d(ToFrameP(ref f._origin), ToFrame(ref f._rotation));
        }

        ///<summary> Map frame *into* local coordinates of Frame </summary>
        public Frame3d ToFrame(ref Frame3d f) {
            return new Frame3d(ToFrameP(ref f._origin), ToFrame(ref f._rotation));
        }

        /// <summary> Map frame *from* local frame coordinates into "world" coordinates </summary>
        public Frame3d FromFrame(Frame3d f) {
            return new Frame3d(FromFrameP(ref f._origin), FromFrame(ref f._rotation));
        }

        /// <summary> Map frame *from* local frame coordinates into "world" coordinates </summary>
        public Frame3d FromFrame(ref Frame3d f) {
            return new Frame3d(FromFrameP(ref f._origin), FromFrame(ref f._rotation));
        }


        ///<summary> Map box *into* local coordinates of Frame </summary>
        public Box3f ToFrame(ref Box3f box) {
            box.Center = ToFrameP(ref box.Center);
            box.AxisX = ToFrameV(ref box.AxisX);
            box.AxisY = ToFrameV(ref box.AxisY);
            box.AxisZ = ToFrameV(ref box.AxisZ);
            return box;
        }

        /// <summary> Map box *from* local frame coordinates into "world" coordinates </summary>
        public Box3f FromFrame(ref Box3f box) {
            box.Center = FromFrameP(ref box.Center);
            box.AxisX = FromFrameV(ref box.AxisX);
            box.AxisY = FromFrameV(ref box.AxisY);
            box.AxisZ = FromFrameV(ref box.AxisZ);
            return box;
        }

        ///<summary> Map box *into* local coordinates of Frame </summary>
        public Box3d ToFrame(ref Box3d box) {
            box.Center = ToFrameP(ref box.Center);
            box.AxisX = ToFrameV(ref box.AxisX);
            box.AxisY = ToFrameV(ref box.AxisY);
            box.AxisZ = ToFrameV(ref box.AxisZ);
            return box;
        }

        /// <summary> Map box *from* local frame coordinates into "world" coordinates </summary>
        public Box3d FromFrame(ref Box3d box) {
            box.Center = FromFrameP(ref box.Center);
            box.AxisX = FromFrameV(ref box.AxisX);
            box.AxisY = FromFrameV(ref box.AxisY);
            box.AxisZ = FromFrameV(ref box.AxisZ);
            return box;
        }


        /// <summary>
        /// Compute intersection of ray with plane passing through frame origin, normal
        /// to the specified axis. 
        /// If the ray is parallel to the plane, no intersection can be found, and
        /// we return Vector3d.Invalid
        /// </summary>
        public Vector3d RayPlaneIntersection(Vector3d ray_origin, Vector3d ray_direction, int nAxisAsNormal) {
            Vector3d N = GetAxis(nAxisAsNormal);
            double d = -Vector3d.Dot(Origin, N);
            double div = Vector3d.Dot(ray_direction, N);
            if (MathUtil.EpsilonEqual(div, 0, MathUtil.ZeroTolerancef))
                return Vector3f.Invalid;
            double t = -(Vector3d.Dot(ray_origin, N) + d) / div;
            return ray_origin + t * ray_direction;
        }


        /// <summary>
        /// Interpolate between two frames - Lerp for origin, Slerp for rotation
        /// </summary>
        public static Frame3d Interpolate(Frame3d f1, Frame3d f2, double t) {
            return new Frame3d(
                Vector3d.Lerp(f1._origin, f2._origin, t),
                Quaterniond.Slerp(f1._rotation, f2._rotation, t));
        }


        public bool EpsilonEqual(Frame3d f2, double epsilon) {
            return _origin.EpsilonEqual(f2._origin, epsilon) &&
                   _rotation.EpsilonEqual(f2._rotation, epsilon);
        }


        public override string ToString() {
            return ToString("F4");
        }

        public string ToString(string fmt) {
            return string.Format("[Frame3d: Origin={0}, X={1}, Y={2}, Z={3}]", Origin.ToString(fmt), X.ToString(fmt),
                Y.ToString(fmt), Z.ToString(fmt));
        }


        // finds minimal rotation that aligns source frame with axes of target frame.
        // considers all signs
        //   1) find smallest angle(axis_source, axis_target), considering all sign permutations
        //   2) rotate source to align axis_source with sign*axis_target
        //   3) now rotate around alined_axis_source to align second-best pair of axes
        public static Frame3d SolveMinRotation(Frame3d source, Frame3d target) {
            int best_i = -1, best_j = -1;
            double fMaxAbsDot = 0, fMaxSign = 0;
            for (int i = 0; i < 3; ++i) {
                for (int j = 0; j < 3; ++j) {
                    double d = source.GetAxis(i).Dot(target.GetAxis(j));
                    double a = Math.Abs(d);
                    if (a > fMaxAbsDot) {
                        fMaxAbsDot = a;
                        fMaxSign = Math.Sign(d);
                        best_i = i;
                        best_j = j;
                    }
                }
            }

            Frame3d R1 = source.Rotated(
                Quaterniond.FromTo(source.GetAxis(best_i), fMaxSign * target.GetAxis(best_j)));
            Vector3d vAround = R1.GetAxis(best_i);

            int second_i = -1, second_j = -1;
            double fSecondDot = 0, fSecondSign = 0;
            for (int i = 0; i < 3; ++i) {
                if (i == best_i)
                    continue;
                for (int j = 0; j < 3; ++j) {
                    if (j == best_j)
                        continue;
                    double d = R1.GetAxis(i).Dot(target.GetAxis(j));
                    double a = Math.Abs(d);
                    if (a > fSecondDot) {
                        fSecondDot = a;
                        fSecondSign = Math.Sign(d);
                        second_i = i;
                        second_j = j;
                    }
                }
            }

            R1.ConstrainedAlignAxis(second_i, fSecondSign * target.GetAxis(second_j), vAround);

            return R1;
        }
    }
}