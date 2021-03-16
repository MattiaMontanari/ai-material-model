﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace g3
{
	// adapted from IntrRay3Box3
	public class IntrRay3AxisAlignedBox3
	{
		Ray3d ray;
		public Ray3d Ray
		{
			get { return ray; }
			set { ray = value; Result = IntersectionResult.NotComputed; }
		}

		AxisAlignedBox3d box;
		public AxisAlignedBox3d Box
		{
			get { return box; }
			set { box = value; Result = IntersectionResult.NotComputed; }
		}

		public int Quantity = 0;
		public IntersectionResult Result = IntersectionResult.NotComputed;
		public IntersectionType Type = IntersectionType.Empty;

		public bool IsSimpleIntersection {
			get { return Result == IntersectionResult.Intersects && Type == IntersectionType.Point; }
		}

		public double RayParam0, RayParam1;
		public Vector3d Point0 = Vector3d.Zero;
		public Vector3d Point1 = Vector3d.Zero;

		public IntrRay3AxisAlignedBox3(Ray3d r, AxisAlignedBox3d b)
		{
			ray = r; box = b;
		}

		public IntrRay3AxisAlignedBox3 Compute()
		{
			Find();
			return this;
		}


		public bool Find()
		{
			if (Result != IntersectionResult.NotComputed)
				return (Result == IntersectionResult.Intersects);

			// [RMS] if either line direction is not a normalized vector, 
			//   results are garbage, so fail query
			if ( ray.Direction.IsNormalized == false )  {
				Type = IntersectionType.Empty;
				Result = IntersectionResult.InvalidQuery;
				return false;
			}

			RayParam0 = 0.0;
			RayParam1 = double.MaxValue;
			IntrLine3AxisAlignedBox3.DoClipping(ref RayParam0, ref RayParam1, ref ray.Origin, ref ray.Direction, ref box,
			          true, ref Quantity, ref Point0, ref Point1, ref Type);

			Result = (Type != IntersectionType.Empty) ?
				IntersectionResult.Intersects : IntersectionResult.NoIntersection;
			return (Result == IntersectionResult.Intersects);
		}



		public bool Test ()
		{
            return Intersects(ref ray, ref box);
        }


        /// <summary>
        /// test if ray intersects box.
        /// expandExtents allows you to scale box for hit-testing purposes. 
        /// </summary>
        public static bool Intersects(ref Ray3d ray, ref AxisAlignedBox3d box, double expandExtents = 0)
        {
            Vector3d WdU = Vector3d.Zero;
            Vector3d AWdU = Vector3d.Zero;
            Vector3d DdU = Vector3d.Zero;
            Vector3d ADdU = Vector3d.Zero;
            Vector3d AWxDdU = Vector3d.Zero;
            double RHS;

            Vector3d diff = ray.Origin - box.Center;
            Vector3d extent = box.Extents + expandExtents;

            WdU[0] = ray.Direction.x; // ray.Direction.Dot(Vector3d.AxisX);
            AWdU[0] = Math.Abs(WdU[0]);
            DdU[0] = diff.x; // diff.Dot(Vector3d.AxisX);
            ADdU[0] = Math.Abs(DdU[0]);
            if (ADdU[0] > extent.x && DdU[0] * WdU[0] >= (double)0) {
                return false;
            }

            WdU[1] = ray.Direction.y; // ray.Direction.Dot(Vector3d.AxisY);
            AWdU[1] = Math.Abs(WdU[1]);
            DdU[1] = diff.y; // diff.Dot(Vector3d.AxisY);
            ADdU[1] = Math.Abs(DdU[1]);
            if (ADdU[1] > extent.y && DdU[1] * WdU[1] >= (double)0) {
                return false;
            }

            WdU[2] = ray.Direction.z; // ray.Direction.Dot(Vector3d.AxisZ);
            AWdU[2] = Math.Abs(WdU[2]);
            DdU[2] = diff.z; // diff.Dot(Vector3d.AxisZ);
            ADdU[2] = Math.Abs(DdU[2]);
            if (ADdU[2] > extent.z && DdU[2] * WdU[2] >= (double)0) {
                return false;
            }

            Vector3d WxD = ray.Direction.Cross(diff);

            AWxDdU[0] = Math.Abs(WxD.x); // Math.Abs(WxD.Dot(Vector3d.AxisX));
            RHS = extent.y * AWdU[2] + extent.z * AWdU[1];
            if (AWxDdU[0] > RHS) {
                return false;
            }

            AWxDdU[1] = Math.Abs(WxD.y); // Math.Abs(WxD.Dot(Vector3d.AxisY));
            RHS = extent.x * AWdU[2] + extent.z * AWdU[0];
            if (AWxDdU[1] > RHS) {
                return false;
            }

            AWxDdU[2] = Math.Abs(WxD.z); // Math.Abs(WxD.Dot(Vector3d.AxisZ));
            RHS = extent.x * AWdU[1] + extent.y * AWdU[0];
            if (AWxDdU[2] > RHS) {
                return false;
            }

            return true;
        }



    }
}
