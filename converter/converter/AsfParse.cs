using System;
using System.Collections.Generic;
using System.IO;

namespace Figael.PreProcess
{
    enum ReadStage
    {
        Header,
        Root,
        Bonedata,
        Hierarchy
    };

    /// <summary>
    /// 解析asf文件
    /// </summary>
    class AsfParse
    {
        public class Bone
        {
            public String Name;
            public String Length;
            public String[] Direction;
            public String[] Axis;
            public String[] Dofs;

            public Bone Clone()
            {
                Bone r = new Bone();

                r.Name = this.Name;
                r.Length = this.Length;
                if (this.Direction != null)
                    r.Direction = (String[])this.Direction.Clone();
                if (this.Axis != null)
                    r.Axis = (String[])this.Axis.Clone();
                if (this.Dofs != null)
                    r.Dofs = (String[])this.Dofs.Clone();

                return r;
            }
        }

        public class HierarchyItem
        {
            public String Parent;
            public List<string> Children = new List<string>();

            public HierarchyItem Clone()
            {
                HierarchyItem r = new HierarchyItem();
                r.Parent = this.Parent;

                if (this.Children != null)
                {
                    r.Children = new List<string>();
                    foreach (string name in this.Children)
                    {
                        r.Children.Add(name);
                    }
                }

                return r;
            }
        }


        private List<HierarchyItem> _hierarchyitems;
        private List<Bone> _bones;
        private string _path;

        public AsfParse(string filename)
        {
            _path = filename;
            _hierarchyitems = new List<HierarchyItem>();
            _bones = new List<Bone>();
        }

        public void Parse()
        {
            ReadStage stage = ReadStage.Header;

            Bone tempbone = new Bone();

            HierarchyItem hierarchyitem = new HierarchyItem();

            StreamReader sread = new StreamReader(this._path);

            while (!sread.EndOfStream)
            {
                string buffer = sread.ReadLine();
                buffer = buffer.TrimStart();
                buffer = buffer.TrimEnd();

                if ('#' == buffer[0])  // 注释
                {
                    continue;
                }

                string[] splitbuff = buffer.Split();
                switch (stage)
                {
                    #region Parse
                    case ReadStage.Header:
                        switch (splitbuff[0])
                        {
                            #region Header
                            case ":version":
                                break;
                            case ":name":
                                break;
                            case ":units":
                                break;
                            case "mass":    // of :units
                                break;
                            case "length":  // of :units
                                goto case "mass";
                            case "angle":   // of :units
                                goto case "mass";
                            case ":documentation":
                                break;
                            case ":root":
                                stage = ReadStage.Root;
                                break;

                            default:
                                break;
                            #endregion
                        }
                        break;
                    case ReadStage.Root:
                        switch (splitbuff[0])
                        {
                            #region Root
                            case "order":
                                break;
                            case "axis":
                                break;
                            case "position":
                                break;
                            case "orientation":
                                break;
                            case ":bonedata":
                                stage = ReadStage.Bonedata;
                                break;
                            #endregion
                        }
                        break;
                    case ReadStage.Bonedata:
                        switch (splitbuff[0])
                        {
                            #region Bonedata
                            case "begin":
                                break;
                            case "id":
                                break;
                            case "name":
                                tempbone.Name = splitbuff[1];
                                break;
                            case "direction":
                                tempbone.Direction = new string[]{
                                    splitbuff[1],
                                    splitbuff[2],
                                    splitbuff[3]
                                };
                                break;
                            case "length":
                                tempbone.Length = splitbuff[1];
                                break;
                            case "axis":
                                tempbone.Axis = new string[]{
                                    splitbuff[1],
                                    splitbuff[2],
                                    splitbuff[3]
                                };
                                break;
                            case "dof":
                                List<string> dofnames = new List<string>();
                                for (int i = 1; i < splitbuff.Length; ++i)
                                {
                                    dofnames.Add(splitbuff[i]);
                                }
                                tempbone.Dofs = dofnames.ToArray();
                                break;
                            case "limits":
                                break;
                            case "end":
                                _bones.Add(tempbone.Clone());
                                tempbone = new Bone();
                                break;
                            case ":hierarchy":
                                stage = ReadStage.Hierarchy;
                                break;
                            default:
                                break;
                            #endregion
                        }
                        break;
                    case ReadStage.Hierarchy:
                        switch (splitbuff[0])
                        {
                            #region Hierarchy
                            case "begin":
                                break;
                            case "end":
                                break;
                            default:
                                hierarchyitem.Parent = splitbuff[0];

                                for (int i = 1; i < splitbuff.Length; ++i)
                                {
                                    hierarchyitem.Children.Add(splitbuff[i]);
                                }

                                _hierarchyitems.Add(hierarchyitem.Clone());
                                hierarchyitem.Children.Clear();
                                break;
                            #endregion
                        }
                        break;
                    default:
                        break;
                    #endregion
                }
            }

            sread.Close();
        }

        /// <summary>
        /// 返回关节关联信息
        /// </summary>
        public List<HierarchyItem> HierarchyItems
        {
            get
            {
                return _hierarchyitems;
            }
        }

        /// <summary>
        /// 返回关节信息
        /// </summary>
        public List<Bone> Bones
        {
            get
            {
                return _bones;
            }
        }


    }
}
