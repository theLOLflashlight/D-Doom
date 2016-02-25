// This is a .c file for the model: level0

#include "level0.h"

const int level0Vertices = 66;

const float _level0Positions[198] =
{
-1.5, 0, 1.5, 
1.5, 0, 1.5, 
-1.5, 0, -1.5, 
-1.5, 0, 1.5, 
-1.1, 0, -1.14482, 
1.44, 0, -1.4, 
-1.5, 0.103718, 1.5, 
1.5, 0.103718, 1.5, 
1.44, 0.103718, -1.4, 
1.5, 0, 1.5, 
1.44, 0, -1.4, 
1.5, 0.103718, 1.5, 
-1.1, 0, -1.14482, 
-1.5, 0, 1.5, 
-1.1, 0.103718, -1.14482, 
1.44, 0, -1.4, 
-1.1, 0, -1.14482, 
1.44, 0.103718, -1.4, 
-1.5, 0, 1.5, 
1.5, 0, 1.5, 
-1.5, 0.103718, 1.5, 
-1.5, 0, -1.5, 
1.5, 0, -1.5, 
-1.5, 1.2, -1.5, 
-1.5, 0, 1.5, 
-1.5, 0, -1.5, 
-1.5, 1.2, 1.5, 
1.5, 0, 1.5, 
-1.5, 0, 1.5, 
1.5, 1.2, 1.5, 
1.5, 0, -1.5, 
1.5, 0, 1.5, 
1.5, 1.2, -1.5, 
1.5, 0, 1.5, 
1.5, 0, -1.5, 
-1.5, 0, -1.5, 
1.5, 0, 1.5, 
-1.5, 0, 1.5, 
1.44, 0, -1.4, 
-1.1, 0.103718, -1.14482, 
-1.5, 0.103718, 1.5, 
1.44, 0.103718, -1.4, 
1.44, 0, -1.4, 
1.44, 0.103718, -1.4, 
1.5, 0.103718, 1.5, 
-1.5, 0, 1.5, 
-1.5, 0.103718, 1.5, 
-1.1, 0.103718, -1.14482, 
-1.1, 0, -1.14482, 
-1.1, 0.103718, -1.14482, 
1.44, 0.103718, -1.4, 
1.5, 0, 1.5, 
1.5, 0.103718, 1.5, 
-1.5, 0.103718, 1.5, 
1.5, 0, -1.5, 
1.5, 1.2, -1.5, 
-1.5, 1.2, -1.5, 
-1.5, 0, -1.5, 
-1.5, 1.2, -1.5, 
-1.5, 1.2, 1.5, 
-1.5, 0, 1.5, 
-1.5, 1.2, 1.5, 
1.5, 1.2, 1.5, 
1.5, 0, 1.5, 
1.5, 1.2, 1.5, 
1.5, 1.2, -1.5, 
};

const float level0Texels[132] = 
{
0.001291, 0.422201, 
0, 0.001291, 
0.422201, 0.42091, 
0.830346, 0.42091, 
0.459097, 0.365927, 
0.422201, 0.009666, 
0.422201, 0.84182, 
0.423493, 0.42091, 
0.830346, 0.430576, 
0.236746, 0.829146, 
0.237994, 0.422201, 
0.251298, 0.829191, 
0.200051, 0.422201, 
0.201199, 0.796442, 
0.185499, 0.422246, 
0.235648, 0.422201, 
0.236746, 0.779917, 
0.221096, 0.422246, 
0.184207, 0.422201, 
0.185499, 0.843111, 
0.169655, 0.422246, 
0.168364, 0.422201, 
0.169655, 0.843111, 
0, 0.422718, 
0.252546, 0.843089, 
0.253837, 0.422201, 
0.42091, 0.843605, 
0.99871, 0.42091, 
1, 0.841293, 
0.830346, 0.421427, 
0.99871, 0, 
0.999998, 0.419725, 
0.830346, 0.000516, 
0, 0.001291, 
0.42091, 0, 
0.422201, 0.42091, 
0.829055, 0, 
0.830346, 0.42091, 
0.422201, 0.009666, 
0.793451, 0.786837, 
0.422201, 0.84182, 
0.830346, 0.430576, 
0.237994, 0.422201, 
0.252546, 0.422246, 
0.251298, 0.829191, 
0.201199, 0.796442, 
0.186647, 0.796486, 
0.185499, 0.422246, 
0.236746, 0.779917, 
0.222194, 0.779962, 
0.221096, 0.422246, 
0.185499, 0.843111, 
0.170947, 0.843156, 
0.169655, 0.422246, 
0.169655, 0.843111, 
0.001291, 0.843628, 
0, 0.422718, 
0.253837, 0.422201, 
0.422201, 0.422718, 
0.42091, 0.843605, 
1, 0.841293, 
0.831636, 0.841809, 
0.830346, 0.421427, 
0.999998, 0.419725, 
0.831634, 0.420242, 
0.830346, 0.000516, 
};

const float _level0Normals[198] =
{
0, 1, -0, 
0, 1, -0, 
0, 1, -0, 
0, -1, 0, 
0, -1, 0, 
0, -1, 0, 
0, 1, -0, 
0, 1, -0, 
0, 1, -0, 
0.999786, 0, -0.020685, 
0.999786, 0, -0.020685, 
0.999786, 0, -0.020685, 
-0.988756, 0, -0.149538, 
-0.988756, 0, -0.149538, 
-0.988756, 0, -0.149538, 
-0.099961, 0, -0.994991, 
-0.099961, 0, -0.994991, 
-0.099961, 0, -0.994991, 
0, 0, 1, 
0, 0, 1, 
0, 0, 1, 
0, 0, 1, 
0, 0, 1, 
0, 0, 1, 
1, 0, -0, 
1, 0, -0, 
1, 0, -0, 
0, -0, -1, 
0, -0, -1, 
0, -0, -1, 
-1, -0, -0, 
-1, -0, -0, 
-1, -0, -0, 
0, 1, -0, 
0, 1, -0, 
0, 1, -0, 
0, -1, 0, 
0, -1, 0, 
0, -1, 0, 
0, 1, -0, 
0, 1, -0, 
0, 1, -0, 
0.999786, 0, -0.020685, 
0.999786, 0, -0.020685, 
0.999786, 0, -0.020685, 
-0.988756, 0, -0.149538, 
-0.988756, 0, -0.149538, 
-0.988756, 0, -0.149538, 
-0.099961, 0, -0.994991, 
-0.099961, 0, -0.994991, 
-0.099961, 0, -0.994991, 
0, 0, 1, 
0, 0, 1, 
0, 0, 1, 
0, 0, 1, 
0, 0, 1, 
0, 0, 1, 
1, 0, -0, 
1, 0, -0, 
1, 0, -0, 
0, -0, -1, 
0, -0, -1, 
0, -0, -1, 
-1, -0, -0, 
-1, -0, -0, 
-1, -0, -0, 
};

const float *level0Positions = _level0Positions;
const float *level0Normals = _level0Normals;

