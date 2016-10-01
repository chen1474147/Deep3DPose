using System.Collections.Generic;
using System.IO;
using Figael.PreProcess;

namespace Figael.WorldTransfrom
{
    public class Motion
    {
        public class Bone
        {
            /// <summary>
            /// 关节名称
            /// </summary>
            public string Name;
            /// <summary>
            /// 旋转角度
            /// </summary>
            public List<float> DofVals;

            public Bone()
            {
                DofVals = new List<float>();
            }
        }

        public class Posture
        {
            /// <summary>
            /// 帧数
            /// </summary>
            public int Index;
            /// <summary>
            /// 关节的 信息
            /// </summary>
            public Dictionary<string, Bone> Bones;

            public Posture()
            {
                Bones = new Dictionary<string, Bone>();
            }
        }
        /// <summary>
        /// 名字
        /// </summary>
        public string Name;
        /// <summary>
        /// 所有帧的动作
        /// </summary>
        public List<Posture> Postures;

        public Motion()
        {
            Name = "NONAME";
            Postures = new List<Posture>();
        }

        /// <summary>
        /// 创建motion文件
        /// </summary>
        /// <param name="filename">AMC文件路径</param>
        /// <returns>Motion 对象</returns>
        public static Motion CreateMotionFromAmcFile(string filename)
        {
            AmcParse amcparse = new AmcParse(filename);
            amcparse.Parse();

            Motion mot = new Motion();

            int numframe = amcparse.Postures.Count;

            int numbone = amcparse.Postures[0].Bones.Count;

            for (int indfr = 0; indfr < numframe; ++indfr)
            {
                Posture pos = new Posture();
                pos.Index = indfr + 1;

                for (int indbone = 0; indbone < numbone; ++indbone)
                {
                    Bone bone = new Bone();

                    bone.Name = amcparse.Postures[indfr].Bones[indbone].Name;

                    int numdof = amcparse.Postures[indfr].Bones[indbone].Dofs.Length;

                    for (int indval = 0; indval < numdof; ++indval)
                    {
                        float val = float.Parse(amcparse.Postures[indfr].Bones[indbone].Dofs[indval]);
                        bone.DofVals.Add(val);
                    }
                    pos.Bones.Add(bone.Name, bone);
                }
                mot.Postures.Add(pos);
            }

            return mot;
        }
    }
}
