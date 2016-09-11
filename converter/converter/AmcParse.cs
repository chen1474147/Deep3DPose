using System;
using System.Collections.Generic;
using System.IO;

namespace Figael.PreProcess
{
    /// <summary>
    /// 解析amc文件
    /// </summary>
    class AmcParse
    {
        public class Bone
        {
            /// <summary>
            /// 关节名称
            /// </summary>
            public string Name;
            /// <summary>
            /// 关节旋转
            /// </summary>
            public string[] Dofs;

            /// <summary>
            /// 复制自身
            /// </summary>
            /// <returns></returns>
            public Bone Clone()
            {
                Bone r = new Bone();

                r.Name = this.Name;
                r.Dofs = (string[])this.Dofs.Clone();

                return r;
            }

        }

        public class Posture
        {
            public List<Bone> Bones = new List<Bone>();

            public Posture Clone()
            {
                Posture r = new Posture();
                foreach (Bone t in this.Bones)
                {
                    r.Bones.Add(t.Clone());
                }
                return r;
            }
        }

        private List<Posture> _postures;
        private string _path;

        public AmcParse(string filename)
        {
            _path = filename;
            _postures = new List<Posture>();
        }

        public void Parse()
        {
            Posture p = new Posture();

            bool IsFirstElement = true;

            StreamReader sread = new StreamReader(_path);

            while (!sread.EndOfStream)
            {
                string buffer = sread.ReadLine();
                buffer = buffer.TrimStart();

                if ('#' == buffer[0])    // 注释行
                {
                    continue;
                }

                if (':' == buffer[0])
                {
                    continue;
                }

                string[] splitbuff = buffer.Split(new Char[] { '\t', ' ' }, StringSplitOptions.RemoveEmptyEntries);

                Bone bone = new Bone();
                bone.Name = splitbuff[0];

                if (1 == splitbuff.Length)
                {
                    if (!IsFirstElement)
                    {
                        _postures.Add(p.Clone());
                        p.Bones.Clear();
                    }

                    if (IsFirstElement)
                    {
                        IsFirstElement = false;
                    }
                    continue;
                }

                List<string> dofss = new List<string>();
                for (int i = 1; i < splitbuff.Length; i++)
                {
                    dofss.Add(splitbuff[i]);
                }
                bone.Dofs = dofss.ToArray();
                p.Bones.Add(bone.Clone());
                if (sread.EndOfStream)
                    _postures.Add(p.Clone());
            }

            sread.Close();
        }

        /// <summary>
        /// 返回各关节dof变化的所有帧集合
        /// </summary>
        public List<Posture> Postures
        {
            get
            {
                return this._postures;
            }
        }
    }
}
