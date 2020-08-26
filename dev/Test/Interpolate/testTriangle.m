function tests = testTriangle
tests = functiontests(localfunctions);
end

% function testRealSolution(testCase)
% actSolution = quadraticSolver(1,-3,2);
% expSolution = [2 1];
% verifyEqual(testCase,actSolution,expSolution)
% end

function testInterpolate(testCase)

xIn = 1:10;
yIn = 1:10;
[xTri,yTri] = meshgrid(xIn,yIn);
xTri = xTri(:);
yTri = yTri(:);
zIn = xTri + yTri;
connection = delaunay(xTri,yTri);
x = (1:0.5:5)';
y = (2:0.5:6)';
z = x+y;

sctInterp = Triangle.interpTrianglePrepare(connection,xTri,yTri,x,y);
zInt = Triangle.interpTriangle(sctInterp,zIn);

verifyEqual(testCase,zInt,z)

end

function testAverage(testCase)
% test the Volume Area and Average of a Mesh

% make a mesh
[x,y] = meshgrid(0:10);
Z = x;
XY =[x(:),y(:)];
connection = delaunay(x,y);

% apply functions
volume = sum(Triangle.triangleVolume(connection,XY,Z));
avg    = mean(Triangle.triangleAverage(connection,Z));
area  = sum(Triangle.triangleArea(connection,XY));

% compare to the analytical solutions
verifyEqual(testCase,area,100);
verifyEqual(testCase,volume,500);
verifyEqual(testCase,avg,5);

end