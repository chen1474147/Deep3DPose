using System;
using System.Collections.Generic;
using Math3D;

namespace Figael.WorldTransfrom
{
    public class Animation
    {
        /// <summary>
        /// 参考坐标系
        /// </summary>
        public enum CoordinateType
        {
            /// <summary>
            /// 全局坐标系
            /// </summary>
            Global,
            /// <summary>
            /// root节点为中心坐标系
            /// </summary>
            Root
        }

        /// <summary>
        /// 关节
        /// </summary>
        public class Bone
        {
            public Bone()
            {
                WorldTransform = Matrix4.IDENTITY;
                WorldTranslate = Vector3.ZERO;
                // WorldTranslateEnd = Vector3.ZERO;
                WorldOrient = Quaternion.IDENTITY;
            }

            /// <summary>
            /// 关节名称
            /// </summary>
            public string Name;

            /// <summary>
            /// 变换矩阵
            /// </summary>
            public Matrix4 WorldTransform;

            /// <summary>
            /// 全局坐标
            /// </summary>
            public Vector3 WorldTranslate;

            //public Vector3 WorldTranslateEnd;
            /// <summary>
            /// 朝向
            /// </summary>
            public Quaternion WorldOrient;
        }

        /// <summary>
        /// 每帧动作
        /// </summary>
        public class Posture
        {
            public int Index;
            public Dictionary<string, Bone> Bones;

            public Posture()
            {
                Bones = new Dictionary<string, Bone>();
            }
        };
        /// <summary>
        /// 动作名称
        /// </summary>
        public string Name;
        /// <summary>
        /// 所有帧的动作
        /// </summary>
        public List<Posture> Postures;
        /// <summary>
        /// 坐标系的名称
        /// </summary>
        public string CoordPara;
        /// <summary>
        /// 骨架
        /// </summary>
        public Skeleton Skeleton;
        /// <summary>
        /// 动作
        /// </summary>
        public Motion Motion;

        public Animation()
        {
            Name = "NONAME";
            Skeleton = new Skeleton();
            Motion = new Motion();
            this.Postures = new List<Posture>();
        }

        /// <summary>
        /// 开始从局部坐标到全局坐标的转换
        /// </summary>
        /// <param name="ct">参考坐标系</param>
        public void Generate(CoordinateType ct)
        {
            CoordPara = ct.ToString().ToLower();

            if (null == Skeleton || null == Motion) return;

            for (int indpos = 0; indpos < Motion.Postures.Count; ++indpos)
            {
                Motion.Posture motpos = Motion.Postures[indpos];
                Posture anipos = new Posture();
                anipos.Index = motpos.Index;
                TransformBone("root", motpos, anipos);
                Postures.Add(anipos);
            }
        }

        /// <summary>
        /// 迭代得到转化坐标系
        /// </summary>
        /// <param name="name">关节名称</param>
        /// <param name="motpos">动作</param>
        /// <param name="anipos">经过转化的动作</param>
        protected void TransformBone(string name, Motion.Posture motpos, Posture anipos)
        {

            Skeleton.Bone skebone = Skeleton.Bones[name];
            Motion.Bone motbone;

            #region 判断是否存在节点
            bool bonecontains = false;
            foreach (string key in motpos.Bones.Keys)
            {
                if (key.Equals(name))
                {
                    bonecontains = true;
                    break;
                }
            }
            if (bonecontains)
            {
                motbone = motpos.Bones[name];
            }
            else
            {
                motbone = new Motion.Bone();
            }
            #endregion

            Bone anibone = new Bone();
            if ("root" == name)
            {
                if ("root" == CoordPara)
                {
                    anibone.WorldTransform.MakeTransform(Vector3.ZERO, Vector3.UNIT_SCALE, Quaternion.IDENTITY);
                }
                else if ("global" == CoordPara)
                {
                    Vector3 vec = new Vector3();
                    vec.x = motbone.DofVals[0];
                    vec.y = motbone.DofVals[1];
                    vec.z = motbone.DofVals[2];

                    Matrix3 mx = new Matrix3();
                    mx.FromAxisAngle(Vector3.UNIT_X, motbone.DofVals[3]);

                    Matrix3 my = new Matrix3();
                    my.FromAxisAngle(Vector3.UNIT_Y, motbone.DofVals[4]);

                    Matrix3 mz = new Matrix3();
                    mz.FromAxisAngle(Vector3.UNIT_Z, motbone.DofVals[5]);

                    Quaternion localorient = new Quaternion(mz * my * mx);
                    anibone.WorldTransform.MakeTransform(vec, Vector3.UNIT_SCALE, localorient);
                }

                anibone.WorldTranslate = anibone.WorldTransform.GetTrans();
                anibone.WorldOrient = anibone.WorldTransform.ExtractQuaternion();
                //anibone.WorldTranslateEnd = anibone.WorldTranslate;
            }
            else
            {
                Vector3 dof = Vector3.ZERO;
                for (int ind = 0; ind < skebone.DofNames.Count; ++ind)
                {
                    string dofname = skebone.DofNames[ind];
                    float val = motbone.DofVals[ind];

                    if ("rx" == dofname)
                        dof.x = val;
                    else if ("ry" == dofname)
                        dof.y = val;
                    else if ("rz" == dofname)
                        dof.z = val;
                }

                Matrix3 mx = new Matrix3();
                mx.FromAxisAngle(Vector3.UNIT_X, dof.x);

                Matrix3 my = new Matrix3();
                my.FromAxisAngle(Vector3.UNIT_Y, dof.y);

                Matrix3 mz = new Matrix3();
                mz.FromAxisAngle(Vector3.UNIT_Z, dof.z);

                Quaternion localorient = new Quaternion(mz * my * mx);

                string parentname = skebone.Parent.Name;
                Bone parentanibone = anipos.Bones[parentname];
                Skeleton.Bone parentskebone = skebone.Parent;

                Matrix4 parenttransform = new Matrix4();

                parenttransform.MakeTransform(
                    parentskebone.Dir * parentskebone.Length,
                    Vector3.UNIT_SCALE,
                    skebone.ParentOrient * localorient
                    );


                anibone.WorldTransform = parentanibone.WorldTransform * parenttransform;

                anibone.WorldTranslate = anibone.WorldTransform.GetTrans();

                anibone.WorldOrient = anibone.WorldTransform.ExtractQuaternion() * Vector3.UNIT_Y.GetRotationTo(skebone.Dir);

                // anibone.WorldTranslateEnd = anibone.WorldTranslate + anibone.WorldOrient * new Vector3(0, skebone.Length, 0);
            }

            anipos.Bones.Add(name, anibone);


            List<Skeleton.Bone> children = skebone.Children;
            if (children != null)
            {
                for (int ind = 0; ind < children.Count; ++ind)
                    TransformBone(children[ind].Name, motpos, anipos);
            }

        }

    }
}
