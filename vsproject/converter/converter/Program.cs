using System;
using Figael.WorldTransfrom;

namespace Figael
{
    public class Program
    {
        public static void Main(string[] agrv)
        {
            if (agrv.Length == 2)
            {
                Animation p = new Animation();

                //根据骨骼文件创建骨架
                p.Skeleton = Skeleton.CreateSkeletonFromAsfFile(agrv[0]);
                //根据动作文件建立动作
                p.Motion = Motion.CreateMotionFromAmcFile(agrv[1]);

                //开始转化
                p.Generate(Animation.CoordinateType.Global);

                try
                {
                    using (System.IO.StreamWriter sw = new System.IO.StreamWriter("result.txt"))
                    {
                        sw.WriteLine(p.Postures.Count + "\t" + p.Postures[0].Bones.Keys.Count);
                        for (int i = 0; i < p.Postures.Count; i++)
                        {
                            sw.WriteLine(i);
                            foreach (string key in p.Postures[i].Bones.Keys)
                            {
                                sw.Write(key + "\t");
                                sw.Write(p.Postures[i].Bones[key].WorldTranslate.x + "\t");
                                sw.Write(p.Postures[i].Bones[key].WorldTranslate.y + "\t");
                                sw.Write(p.Postures[i].Bones[key].WorldTranslate.z + Environment.NewLine);
                            }
                        }
                        sw.Close();
                    }
                }
                catch (Exception ex)
                {

                    Console.WriteLine(ex.Message);
                }

                Console.WriteLine("Translation Completed!");
            }
        }

    }
}
