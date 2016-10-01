

#include <iostream>
using namespace std;

#include <assert.h>
#include <vector>
#include <string>
#include <map>


// data structure
// every frame has 31 joints
typedef struct
{
	double data[31][3];
} mocapframe;



// load data
vector<mocapframe> loadcmudata()
{
	// joints index
	map<string, int> joints;
	joints["root"] = 0;
	joints["lhipjoint"] = 1;
	joints["lfemur"] = 2;
	joints["ltibia"] = 3;
	joints["lfoot"] = 4;
	joints["ltoes"] = 5;
	joints["rhipjoint"] = 6;
	joints["rfemur"] = 7;
	joints["rtibia"] = 8;
	joints["rfoot"] = 9;
	joints["rtoes"] = 10;
	joints["lowerback"] = 11;
	joints["upperback"] = 12;
	joints["thorax"] = 13;
	joints["lowerneck"] = 14;
	joints["upperneck"] = 15;
	joints["head"] = 16;
	joints["lclavicle"] = 17;
	joints["lhumerus"] = 18;
	joints["lradius"] = 19;
	joints["lwrist"] = 20;
	joints["lhand"] = 21;
	joints["lfingers"] = 22;
	joints["lthumb"] = 23;
	joints["rclavicle"] = 24;
	joints["rhumerus"] = 25;
	joints["rradius"] = 26;
	joints["rwrist"] = 27;
	joints["rhand"] = 28;
	joints["rfingers"] = 29;
	joints["rthumb"] = 30;
	// joints["RightHand_dum2"] = 31;
	// joints["RightHandThumb"] = 32;


	// result
	vector<mocapframe> data;

	int framenum, nowframe;
	int jointnum, nowjoint;


	// load file
	FILE *fp = fopen("result.txt", "r");

	while (!feof(fp))
	{
		fscanf(fp, "%d\t%d\n", &framenum, &jointnum);

		assert(jointnum == 31);

		for (int i = 0; i < framenum; i++)
		{
			fscanf(fp, "%d\n", &nowframe);

			assert(nowframe == i);


			// frame
			mocapframe tmp;
			char buf[50];
			float x, y, z;

			for (int j = 0; j < jointnum; j++)
			{
				fscanf(fp, "%s\t%f\t%f\t%f\n", buf, &x, &y, &z);

				nowjoint = joints[buf];

				tmp.data[nowjoint][0] = x;
				tmp.data[nowjoint][1] = y;
				tmp.data[nowjoint][2] = z;
			}

			data.push_back(tmp);
		}
	}

	fclose(fp);

	return data;
}
