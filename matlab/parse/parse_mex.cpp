

#include "parse.h"
#include <mex.h>



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	// [ cmudata ] = mex()

	vector<mocapframe> data;
	data = loadcmudata();

	int allframes = data.size();


	// output
	plhs[0] = mxCreateDoubleMatrix(45, allframes, mxREAL);
	double *outData;
	outData = mxGetPr(plhs[0]);


	// we need 15 joints
	int ind_wangchuyu[] = { 16, 14, 18, 19, 20, 25, 26, 27, 0, 2, 3, 4, 7, 8, 9 };

	for (int frame = 0; frame < allframes; frame++)
	{
		for (int i = 0; i < 15; i++)
		{
			int r = ind_wangchuyu[i];

			outData[frame * 45 + i * 3 + 0] = data[frame].data[r][0];
			outData[frame * 45 + i * 3 + 1] = data[frame].data[r][1];
			outData[frame * 45 + i * 3 + 2] = data[frame].data[r][2];
		}
	}

	return;
}
