function tests = testTriangle
    tests = functiontests(localfunctions);
end

function testIntvarAtC

% 2d
[uVar,vVar] = meshgrid(1:10);
dim = 2;


cVar = Interpolate.uVarAtC(uVar,dim);
cVarInt = uVar+0.5;
cVarInt(:,end) = nan;
assert(all(cVar ==cVarInt))

dim = 1;
cVar = Interpolate.uVarAtC(uVar',dim);
cVar = cVar';
assert(all(cVar ==cVarInt));

dim = 2;
cVar = Interpolate.uVarAtC(vVar,dim);
cVarInt = vVar;
cVarInt(:,end) = nan;
assert(all(cVar ==cVarInt))

%With NaNs
dim = 2;
uVar(:,2) = nan;
cVar = Interpolate.uVarAtC(uVar,dim);
cVarInt = uVar+0.5;
cVarInt(:,1) = 1;
cVarInt(:,2) = 3;
cVarInt(:,end) = nan;

assert(all(cVar ==cVarInt))


% 3d




function testInterpolate

xIn = 1:10;
yIn = 1:10;
zIn = xIn+yIn;
[xTri,yTri] = meshgrid(xIn,yIn);
connection = delaunay(xTri,yTri);
x = 1:0.5:5;
y = 2:0.5:6;
z = x+y;

sctInterp = Triangle.interpTrianglePrepare(connection,xTri,yTri,x,y);
zInt = Triangle.interpTriangle(sctInterp,zIn);

assert(all(zInt==z))

