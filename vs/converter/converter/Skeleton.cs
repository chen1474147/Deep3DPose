using System;
using System.Collections.Generic;
using System.IO;
using Math3D;
using Figael.PreProcess;

namespace Figael.WorldTransfrom
{
    public class Skeleton
    {
        /// <summary>
        /// 关节
        /// </summary>
        public class Bone
        {
            public Bone()
            {
                Length = 0f;
                Dir = Vector3.ZERO;
                Axis = Vector3.ZERO;
                ParentOrient = Quaternion.IDENTITY;
                DofNames = new List<string>();
            }
            /// <summary>
            /// 关节名称
            /// </summary>
            public string Name;
            /// <summary>
            /// 关节长度
            /// </summary>
            public float Length;
            /// <summary>
            /// 方向向量
            /// </summary>
            public Vector3 Dir;
            /// <summary>
            /// 坐标系
            /// </summary>
            public Vector3 Axis;
            /// <summary>
            /// 旋转系
            /// </summary>
            public List<string> DofNames;
            /// <summary>
            /// 父节点朝向
            /// </summary>
            public Quaternion ParentOrient;
            /// <summary>
            /// 父节点
            /// </summary>
            public Bone Parent;
            /// <summary>
            /// 所有的子节点
            /// </summary>
            public List<Bone> Children;

            public Bone Clone()
            {
                Bone b = new Bone();

                b.Name = this.Name;
                b.Length = this.Length;
                b.Axis = new Vector3(this.Axis.x, this.Axis.y, this.Axis.z);
                b.Dir = new Vector3(this.Dir.x, this.Dir.y, this.Dir.z);
                b.DofNames = this.DofNames;
                b.ParentOrient = new Quaternion(this.ParentOrient.w, this.ParentOrient.x, this.ParentOrient.y, this.ParentOrient.z);
                b.Parent = this.Parent;
                b.Children = this.Children;

                return b;

            }
        };

        /// <summary>
        /// 关节名称
        /// </summary>
        public string Name;
        /// <summary>
        /// 骨头的集合
        /// </summary>
        public Dictionary<string, Bone> Bones;

        public Skeleton()
        {
            Name = "NONAME";
            Bones = new Dictionary<string, Bone>();
        }

        /// <summary>
        /// 根据文件建立骨架
        /// </summary>
        /// <param name="filename">asf文件的绝对路径</param>
        /// <returns>Skeleton 对象</returns>
        public static Skeleton CreateSkeletonFromAsfFile(string filename)
        {
            AsfParse gap = new AsfParse(filename);
            gap.Parse();

            Skeleton ske = new Skeleton();

            Bone root = new Bone();
            root.Name = "root";
            root.DofNames.Add("tx"); root.DofNames.Add("ty"); root.DofNames.Add("ty");
            root.DofNames.Add("rx"); root.DofNames.Add("ry"); root.DofNames.Add("rz");
            ske.Bones.Add(root.Name, root);

            // 关节信息
            int numbone = gap.Bones.Count;
            for (int indbone = 0; indbone < numbone; ++indbone)
            {
                Bone bone = new Bone();

                bone.Name = gap.Bones[indbone].Name;
                bone.Length = float.Parse(gap.Bones[indbone].Length);

                bone.Dir.x = float.Parse(gap.Bones[indbone].Direction[0]);
                bone.Dir.y = float.Parse(gap.Bones[indbone].Direction[1]);
                bone.Dir.z = float.Parse(gap.Bones[indbone].Direction[2]);

                bone.Axis.x = float.Parse(gap.Bones[indbone].Axis[0]);
                bone.Axis.y = float.Parse(gap.Bones[indbone].Axis[1]);
                bone.Axis.z = float.Parse(gap.Bones[indbone].Axis[2]);


                int numdof = 0;
                if (gap.Bones[indbone].Dofs != null)
                    numdof = gap.Bones[indbone].Dofs.Length;

                for (int inddof = 0; inddof < numdof; ++inddof)
                {
                    string namedof = gap.Bones[indbone].Dofs[inddof];

                    bone.DofNames.Add(namedof);
                }
                ske.Bones.Add(bone.Name, bone.Clone());
            }

            // -- 关节关联
            int numhier = gap.HierarchyItems.Count;

            for (int indhier = 0; indhier < numhier; ++indhier)
            {
                string bonename = gap.HierarchyItems[indhier].Parent;
                int numchildren = gap.HierarchyItems[indhier].Children.Count;
                for (int indchild = 0; indchild < numchildren; ++indchild)
                {
                    string childname = gap.HierarchyItems[indhier].Children[indchild];

                    Skeleton.Bone parent = ske.Bones[bonename];
                    Skeleton.Bone child = ske.Bones[childname];
                    if (parent.Children == null)
                        parent.Children = new List<Bone>();
                    parent.Children.Add(child);
                    child.Parent = parent;

                    Matrix3 childmx = new Matrix3();
                    Matrix3 childmy = new Matrix3();
                    Matrix3 childmz = new Matrix3();
                    Matrix3 parentinvmx = new Matrix3();
                    Matrix3 parentinvmy = new Matrix3();
                    Matrix3 parentinvmz = new Matrix3();

                    childmx.FromAxisAngle(Vector3.UNIT_X, child.Axis.x);//子节点：从局部坐标系到全局坐标系			
                    childmy.FromAxisAngle(Vector3.UNIT_Y, child.Axis.y);
                    childmz.FromAxisAngle(Vector3.UNIT_Z, child.Axis.z);
                    parentinvmx.FromAxisAngle(Vector3.UNIT_X, -parent.Axis.x);	//父节点：从全局坐标系到局部坐标系	
                    parentinvmy.FromAxisAngle(Vector3.UNIT_Y, -parent.Axis.y);
                    parentinvmz.FromAxisAngle(Vector3.UNIT_Z, -parent.Axis.z);
                    child.ParentOrient.FromRotationMatrix(parentinvmx * parentinvmy * parentinvmz * childmz * childmy * childmx);


                    Matrix3 childinvmx = new Matrix3();
                    Matrix3 childinvmy = new Matrix3();
                    Matrix3 childinvmz = new Matrix3();

                    childinvmx.FromAxisAngle(Vector3.UNIT_X, -child.Axis.x);//子节点：从全局坐标系到局部坐标系
                    childinvmy.FromAxisAngle(Vector3.UNIT_Y, -child.Axis.y);
                    childinvmz.FromAxisAngle(Vector3.UNIT_Z, -child.Axis.z);
                    child.Dir = childinvmx * childinvmy * childinvmz * child.Dir;
                    child.Dir.Normalize();
                }
            }

            return ske;
        }
    };
}
