%%%morphologic grid X
output = 1:1
1:LoadField:load x-grid
LowerLeft = 5 5
0 inputs
{
Delft3D-com
$FN
morphologic grid X-coordinates
AnimateFields = 1
}

%%%morphologic grid Y
output = 1:1
1:LoadField:load y-grid
LowerLeft = 5 5
0 inputs
{
Delft3D-com
$FN
morphologic grid Y-coordinates
AnimateFields = 1
}

%%%constant plane
output = 1:1
1:ConstantMatrix:constant
LowerLeft = 5 5
0 inputs
{
0
$SZ
}

%%%hydrodynamic grid X
output = 1:1
1:LoadField:load x-grid
LowerLeft = 5 5
0 inputs
{
Delft3D-com
$FN
hydrodynamic grid X-coordinates
AnimateFields = 1
}

%%%hydrodynamic grid Y
output = 1:1
1:LoadField:load y-grid
LowerLeft = 5 5
0 inputs
{
Delft3D-com
$FN
hydrodynamic grid Y-coordinates
AnimateFields = 1
}

%%%bottom Z
output = 2:1
1:LoadField:load depth
LowerLeft = 5 7
0 inputs
{
Delft3D-com
$FN
bottom
%AN
}
2:ScalarMultiply:times -1
LowerLeft = 5 5
1 inputs
1 1:1
{
-1
}

%%%bottom T
output = 1:1
1:LoadField:load depth time
LowerLeft = 5 5
0 inputs
{
Delft3D-com
$FN
bottom time
AnimateFields = 1
}

%%%general load
output = 1:1
1:LoadField:load $VAR
LowerLeft = 5 5
0 inputs
{
Delft3D-com
$FN
$VAR
$AN
}

%%%waterdepth
output = 3:1
1:LoadField:load waterlevel
LowerLeft = 5 7
0 inputs
{
Delft3D-com
$FN
waterlevel
$AN1
}
2:LoadField:load depth
LowerLeft = 12 7
0 inputs
{
Delft3D-com
$FN
bottom in waterlevel points
$AN2
}
3:Sum:sum
LowerLeft = 10 4
1 inputs
1 1:1 2:1
{
}

%%%erosion/sedimentation
output = 4:1
1:LoadField:load depth
LowerLeft = 5 9
0 inputs
{
Delft3D-com
%FN
bottom
%AN
}
2:LoadField:load reference depth
LowerLeft = 10 9
0 inputs
{
Delft3D-com
%FN
bottom
AnimateFields = 1
}
3:ScalarMultiply:times -1
LowerLeft = 5 7
1 inputs
1 1:1
{
-1
}
4:Sum:sum
LowerLeft = 8 5
1 inputs
1 3:1 2:1
{
}

%%%Froude number
output = 8:1
1:LoadField:load waterlevel
LowerLeft = 5 18
0 inputs
{
Delft3D-com
%FN
waterlevel
%AN1
}
2:LoadField:load depth
LowerLeft = 12 18
0 inputs
{
Delft3D-com
%FN
bottom in waterlevel points
%AN2
}
3:Sum:sum
LowerLeft = 10 16
1 inputs
1 1:1 2:1
{
}
4:ScalarMultiply:times 9.81
LowerLeft = 8 14
1 inputs
1 3:1
{
9.81
}
5:Power:sqrt
LowerLeft = 9 12
1 inputs
1 4:1
{
0.5
}
6:Inverse:inverse
LowerLeft = 8 10
1 inputs
1 5:1
{
}
7:LoadField:load velocity
LowerLeft = 2 10
0 inputs
{
Delft3D-com
%FN
velocity magnitude
%AN1
}
8:Multiply:multiply
LowerLeft = 5 5
1 inputs
1 7:1 6:1
{
}
