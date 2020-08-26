% The functions in this file tests the Class calculation using xUnit. In
% order to run the tests, ne should:
%1) add x-unit, this file and the class to the matlab path
%2) execute the tests by typing runtests




function test_suite = TestCalculation
initTestSuite;

% Test preprocess

function TestPreprocess
xin =  [3 1 1 2 3 4 6 8];
yin =xin;
xexp =  [1  2 3 4 6 8];
yexp = xexp;
[xout,yout] = Calculate.preprocess(xin,yin);

assertEqual(xout,xexp);
assertEqual(yout,yexp);

function TestMakeCoordinates
% Test makeCoordinates

options.start = 1;
options.end = 10;
options.interval = 2;

xout  = Calculate.makeCoordinates(options);
xorg = 1:2:10;


assertEqual(xout,xorg);

% Test    interpThreshold

function TestInterpThreshold
options.method = 'linear';
options.threshold = 1.5;


xin =  [1  2 3 4 6 8];
yin = xin;

xnew = 1:3:10;
yexp =  [1 4 nan nan ];

ynew = Calculate.interpThreshold(xin,yin,xnew,options);

assertEqual(ynew,yexp);


%% Resampling methods;

function TestResampleMean

xorg = 1:10;
yorg = 1:10;
xnew = 0.5:2:8.5;
yexp = 1.5:2:7.5;

ynew = Calculate.resampleMean(xorg,yorg,xnew);
assertEqual(ynew,yexp');


function TestResampleSum

xorg = 1:10;
yorg = 1:10;
xnew = 0.5:2:8.5;
yexp = [3 7 11 15];


ynew = Calculate.resampleSum(xorg,yorg,xnew);
assertEqual(ynew,yexp');

function TestResampleMin

xorg = 1:10;
yorg = 1:10;
xnew = 0.5:2:8.5;
yexp = 1:2:7;


ynew = Calculate.resampleMin(xorg,yorg,xnew);
assertEqual(ynew,yexp');


function TestResampleMax

xorg = 1:10;
yorg = 1:10;
xnew = 0.5:2:8.5;
yexp = 2:2:8;


ynew = Calculate.resampleMax(xorg,yorg,xnew);
assertEqual(ynew,yexp');

% function TestResampleInt
%
% xorg = 1:10;
% yorg = 1:10;
% xnew = 1:2:9;
% yexp = 2:2:10;
%
%
% ynew = Calculate.resampleInt(x,y,xnew)
% assertAlmostEqual(ynew,yexp);

function TestTrapeziumRule

xorg = 1:0.01:10;
yorg = xorg;
yexp = 0.5.*(10.^2 -1 );% analytical solution of intergral

ynew = Calculate.TrapeziumRule(xorg,yorg) ;
assertAlmostEqual(ynew,yexp);

%% masking function


function TestInterpNan

xin = 1:20;
yin = 1:20;
yexp = yin;
yin([1  5 6 7 12]) = nan;
options.extrapmethod = 'linear';
ynew = Calculate.interpNan(xin, yin, options);

assertAlmostEqual(ynew,yexp);


function TestApplyFlags

% possible methods
% 'delete
% 'set to nan'
% 'interpolate'

xin = 1:10;
flagsin = [1 1 1 1 2 3 2 1 1 1 ];

method = 'delete';
xexp = [1:4,6,8:10];
maskexp = logical([1 1 1 1 0 1 0 1 1 1]);
[xout,maskout] = Calculate.ApplyFlags(xin,flagsin,method);
assertEqual(xout,xexp);
assertEqual(maskout,maskexp);

method = 'nan';
xexp = [1:4,nan,6,nan,8:10];
[xout,maskout] = Calculate.ApplyFlags(xin,flagsin,method);
assertEqual(xout,xexp);
assertEqual(maskout,maskexp);

method = 'interp';
xexp = 1:10;
[xout,maskout] = Calculate.ApplyFlags(xin,flagsin,method);
assertEqual(xout,xexp);
assertEqual(maskout,maskexp);

%% 
function TestProjectVector


xRef = [0;1;2;3;4;];
yRef = [0;2;4;4;4;];

uOld = [0  0 0  0; 2  2 2 2 ;4  4 4 4]';
vOld = [1 -1 1 -1;-1 -1 -1 0;-2 -2 -2 0]';
s5 = sqrt(5);
[uCross,uAlong] = Calculate.projectVector(uOld,vOld,xRef,yRef);
uAlongExp = [2/s5 -2/s5 0 0;0 0 2 2; 0 0 4 4]';
uCrossExp = [1/s5 -1/s5 1 -1;s5 s5 -1 0;2*s5 2*s5 -2 0]';

disp(uCross')
disp(uCrossExp')
disp(uAlong')
disp(uAlongExp')

%plot
i =2 ;figure;subplot(1,2,1);plot(xRef,yRef);hold on; quiver(xRef(1:end-1),yRef(1:end-1),uOld(:,i),vOld(:,i));axis equal;subplot(1,2,2); quiver(1:4,[1 1 1 1],uCross(:,i)',uAlong(:,i)');axis equal;

%% Time stamps


function TestTimeStampDay
options.start = datenum([2012 4 15 8 45 02]);
options.end = datenum([2012 4 21 9 32 02]);
xexp = datenum([2012 4 15]):1:datenum([2012 4 22]);
xout = Calculate.TimeStampDay(options);

assertEqual(xout,xexp);

function  TestTimeStampWeek

options.start =datenum( [2012 8 7 11 11 11]);%tuesday
options.end = datenum([2012 8 22 11 11 11]);%wednesday
xexp = datenum([2012 8 6]):7:datenum([2012 8 27]);
xout = Calculate.TimeStampWeeks(options);

assertEqual(xout,xexp);



function  TestTimeStampYears

options.start = datenum([1999 8 7 11 11 11]);%tuesday
options.end = datenum([2003 8 22 11 11 11]);%wednesday
xout = Calculate.TimeStampYears(options);
xexp = datenum([1999 1 1 0 0 0;...
    2000 1 1 0 0 0;...
    2001 1 1 0 0 0;...
    2002 1 1 0 0 0;...
    2003 1 1 0 0 0;...
    2004 1 1 0 0 0;...
    ]);

assertEqual(xout,xexp);



function TestTimeStampQuarter

options.start = datenum([1999 8 7 11 11 11]);
options.end = datenum([2001 3 22 11 11 11]);
xexp = datenum([1999 7 1 0 0 0;...
    1999 10 1 0 0 0;...
    2000 1 1 0 0 0;...
    2000 4 1 0 0 0;...
    2000 7 1 0 0 0;...
    2000 10 1 0 0 0;...
    2001 1 1 0 0 0;...
    2001 4 1 0 0 0;...
    ]);

xout = Calculate.TimeStampQuarter(options);

assertEqual(xout,xexp);


function TestTimeStampMonth

options.start = datenum([1999 8 7 11 11 11]);
options.end = datenum([2000 3 22 11 11 11]);
xexp = datenum([1999 8 1 0 0 0;...
    1999 9 1 0 0 0;...
    1999 10 1 0 0 0;...
    1999 11 1 0 0 0;...
    1999 12 1 0 0 0;...
    2000 1 1 0 0 0;...
    2000 2 1 0 0 0;...
    2000 3 1 0 0 0;...
    2000 4 1 0 0 0;...
    ]);

xout = Calculate.TimeStampMonth(options);

assertEqual(xout,xexp);

%% low pass filters

% moving average

% godin filter

%% fitting methods

% equationString
% applyFit
% deriveFit

% linear fit

function TestFitPolynomial

xIn = 1:10;
yIn = 2.*xIn+4;
yIn ([3 6]) = nan;
coefExp = [2 4];
coefOut = Calculate.fitPolynomial(xIn,yIn);

assertAlmostEqual(coefOut,coefExp);

function TestEquationPolynomial

options.format = '%2.1f';
coef = [2.1 -3.0 6.1];
equationOut = Calculate.equationPolynomial(coef,options);
equationExp = 'y = 2.1 x^2 - 3.0 x + 6.1';

assertEqual(equationOut,equationExp);

function TestApplyPolynomial

x = 1:10;
coef = [2 1 0.5];
yOut = Calculate.applyPolynomial(x,coef);
yExp = 2.*x.^2+x+0.5;

assertAlmostEqual(yOut,yExp);

function TestRSquared

yOrg = 1:10;
yFit = 10:-1:1;
yFit(3) = nan;
rExp = 1;
rOut = Calculate.rSquared(yOrg,yFit);


assertAlmostEqual(rOut,rExp);

%% log fit

function TestNegative2Nan

x = -3:3;
yOut = Calculate.negative2nan(x);
% Note that also zero values are deleted!
yExp = [nan nan nan nan 1 2 3];

assertEqual(yOut,yExp);


function TestFitLog
x = 1:10;
y  = 3.5*log(x)+2.5;
coefOut = Calculate.fitLog(x,y);
coefExp = [3.5 2.5];

assertAlmostEqual(coefOut,coefExp);

function  TestApplyLog

x = -3:10;
coef = [3.5,2.5];
yExp  = 3.5*log(x)+2.5;
yExp(1:4) = nan;
yOut = Calculate.applyLog(x,coef);

assertAlmostEqual(yOut,yExp);


function  TestEquationLog


coef = [3.5,-2.5];
options.format = '%2.1f';
equationExp = 'y = 3.5 ln(x) - 2.5';
equationOut = Calculate.equationLog(coef,options);

assertEqual(equationOut,equationExp);

%% exponential fit

function TestFitExp
x = -5:1:10;
y = 2.1.*exp(-0.31.*x);
coefExp = [-0.31,2.1];
coefOut = Calculate.fitExp(x,y);

assertAlmostEqual(coefOut,coefExp);


function TestApplyExp

x = -5:1:10;
yExp = 2.1.*exp(-0.31.*x);
coef = [-0.31,2.1];

yOut = Calculate.applyExp(x,coef);

assertAlmostEqual(yOut,yExp);

function TestEquationExp

coef = [-0.5,3.1];
options.format = '%2.1f';
equationOut = Calculate.equationExp(coef,options);
equationExp   = 'y = 3.1 exp(-0.5 x)';

assertEqual(equationOut,equationExp);

%% power law fit


function TestFitPower

x = 1:10;
y = 9.1.*x.^-9.5;

coefOut = Calculate.fitPower(x,y);
coefExp = [-9.5,9.1];

assertAlmostEqual(coefOut,coefExp);


function TestApplyPower

x = 1:10;
yExp = 9.1.*x.^-9.5;
coef = [-9.5 9.1];
yOut = Calculate.applyPower(x,coef);

assertAlmostEqual(yOut,yExp);



function  TestEquationPower

options.format= '%2.1f';
coef = [-9.5 9.1];

equationExp = 'y = 9.1 x^{-9.5}';
equationOut = Calculate.equationPower(coef,options);

assertEqual(equationOut,equationExp);




%% lowess method (opzoeken)
function TestLowess

x = 1:0.05:10;
y = [sin(0.25.*x)-0.1,sin(0.25.*x),sin(0.25.*x)+0.1];
x = repmat(x,1,3);

options.filtersize = 0.5;
options.method = 'lowess';
xNew = 4:0.5:7;
yNew = Filter.lowess(x,y,xNew,options);


yExp = sin(0.25.*xNew);


% 5% deviation is allowed
assertAlmostEqual(yNew,yExp,0.05);


%verwijderen nans uit data

function TestDeleteNans

x = 1:20;
y = 2.*x; z= 3.*x;
xExp = x; yExp = y; zExp = z;
x([2 3]) = nan;
y ([5 6]) = nan;
z (11) = nan;
xExp([2 3 5 6 11])= [];
yExp([2 3 5 6 11])= [];
zExp([2 3 5 6 11])= [];

[xOut,yOut,zOut] = Calculate.deleteNans(x,y,z);
assertEqual(xOut,xExp);
assertEqual(yOut,yExp);
assertEqual(zOut,zExp);



