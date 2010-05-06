function testresult = getAdditionalErosion_test()
% GETADDITIONALEROSION_TEST  simple profile with valley (duros result) and conditions
%  
% This test checks that basic functionalities of getAdditionalErosion.
%
%
%   See also getAdditionalErosion getDuneErosion

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 28 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = getAdditionalErosion)
% This test chacks the basic functionalities of getAdditionalErosion.
%
% At this moment the test contains 8 testcases:
%
% * Basic test with reference profile
% * Additional erosion restricted by maximum length
% *
% *
% *
% *
% *
% *
% * Should not crash with horizontal dune face at waterline
%

%% $RunCode
xInitial = [-250;-110;-102.307692307692;-100;-65;-62.6923076923077;-55.9905800951909;-55;-47.2783342163304;-35.8266671081652;-24.3750000000000;-11.8750000000000;0.624999999999993;5.37746066940475;5.62500000000000;22.3250000000000;39.0250000000000;55.7250000000000;70.4693417612857;85.2136835225713;99.9580252838569;114.702367045143;129.446708806428;144.191050567714;158.935392329000;173.273313863200;187.611235397400;201.949156931600;216.287078465800;230.625000000000;246.350208007841;262.075416015681;277.800624023522;298.857508547580;351.115691289108;2780.62500000000;];
zInitial = [15;15;5;2;2;5;13.7122458800000;12.7216657846795;5;4.47810936000000;4.03699772000000;3.61421016000000;3.23443804000000;3.09901573000000;3.09196205000000;2.64715264000000;2.24078538000000;1.86433908000000;1.55219366000000;1.25596793000000;0.973449230000000;0.702894400000000;0.442901150000000;0.192321420000000;-0.0497987899999997;-0.277895940000000;-0.499383040000000;-0.714803470000000;-0.924630000000000;-1.12927703000000;-1.34820224000000;-1.56176205000000;-1.77033263000000;-3.45488339000000;-3.80327127500000;-20;];
x0DUROS = -47.2783342163304;
WL_t = 5;
%{
Hsig_t = 9;
Tp_t = 12;
D50 = 0.000225;
%}
precision = 1e-2;
maxiter = 50;
slope = 1;
poslndwrd = -1;
%% perform tests

tr(1) = addvolumecase1(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd);
tr(2) = addvolumecase2(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd);
tr(9) = addvolumecase9(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd);
tr(3) = addvolumecase3(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd);
tr(4) = addvolumecase4(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd);
tr(5) = addvolumecase5(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd);
tr(6) = addvolumecase6(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd);
tr(7) = addvolumecase7(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope);
tr(8) = addvolumecase8(WL_t,precision,maxiter,slope);

testresult = all(tr);

%% $PublishResult
% Publishable code that describes the test.

end

function testresult = addvolumecase1(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd)
%% $Description (Name = Basic test (Ref profile))
TargetVolume = -100.81;

%% $RunCode
try
    testresult = nan;
    writemessage init
    result = getAdditionalErosion(xInitial,zInitial,...
        'TargetVolume',TargetVolume,...
        'poslndwrd',poslndwrd,...
        'precision',precision,...
        'maxiter',maxiter,...
        'slope',slope,...
        'x0min',min(xInitial),...
        'x0max',x0DUROS,...
        'zmin',WL_t);
    if result.info.resultinboundaries
        testresult = true;
    end
catch me 
    testresult = false;
end


%% $PublishResult (EvaluateCode = true & IncludeCode = false)
figure('Color','w');
hold on
ylim([0 16]);
xlim([-150, 250]);
plot(xInitial,zInitial,'DisplayName','Initial profile','Color',[255 222 111]/255,'LineWidth',2);
plot(xlim,ones(1,2)*WL_t,'DisplayName',['maximum storm surge level (NAP + ' num2str(WL_t) ' m)']);
patchx = [result.xActive; flipud(result.xActive)];
patchz = [result.zActive; flipud(result.z2Active)];
patch(patchx,patchz,'g','EdgeColor','none','FaceColor', [0 0.6 0],'DisplayName','Aditional Erosion')
legend show
end

function testresult = addvolumecase2(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd)
%% $Description (Name = restricted by max length)
TargetVolume = -100.81;
maxRetreat = 10;


%% $RunCode
try
    testresult = false;
    writemessage('init');
    result = getAdditionalErosion(xInitial,zInitial,...
        'TargetVolume',TargetVolume,...
        'poslndwrd',poslndwrd,...
        'precision',precision,...
        'maxiter',maxiter,...
        'slope',slope,...
        'x0min',x0DUROS-maxRetreat,...
        'x0max',x0DUROS,...
        'zmin',WL_t);
    testresult = ~result.info.resultinboundaries;
catch me %#ok<*NASGU>
    testresult = false;
end

%% $PublishResult
figure('Color','w');
hold on
ylim([0 16]);
xlim([-150, 250]);
plot(xInitial,zInitial,'DisplayName','Initial profile','Color',[255 222 111]/255,'LineWidth',2);
plot(xlim,ones(1,2)*WL_t,'DisplayName',['maximum storm surge level (NAP + ' num2str(WL_t) ' m)']);
patchx = [result.xActive; flipud(result.xActive)];
patchz = [result.zActive; flipud(result.z2Active)];
patch(patchx,patchz,'g','EdgeColor','none','FaceColor', [0 0.6 0],'DisplayName','Aditional Erosion')
legend show


end

function testresult = addvolumecase3(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd)
%% $Description (Name = Restricted in dune valley)

TargetVolume = -100.81;
maxRetreat = 20;

%% $RunCode
try
    testresult = false;
    result = getAdditionalErosion(xInitial,zInitial,...
        'TargetVolume',TargetVolume,...
        'poslndwrd',poslndwrd,...
        'precision',precision,...
        'maxiter',maxiter,...
        'slope',slope,...
        'x0min',x0DUROS-maxRetreat,...
        'x0max',x0DUROS,...
        'zmin',WL_t);
    testresult = true;
    
catch me
    testresult = false;
end

%% $PublishResult
figure('Color','w');
hold on
ylim([0 16]);
xlim([-150, 250]);
plot(xInitial,zInitial,'DisplayName','Initial profile','Color',[255 222 111]/255,'LineWidth',2);
plot(xlim,ones(1,2)*WL_t,'DisplayName',['maximum storm surge level (NAP + ' num2str(WL_t) ' m)']);
patchx = [result.xActive; flipud(result.xActive)];
patchz = [result.zActive; flipud(result.z2Active)];
patch(patchx,patchz,'g','EdgeColor','none','FaceColor', [0 0.6 0],'DisplayName','Aditional Erosion')
legend show
end

function testresult = addvolumecase4(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd)
%% $Description (Name = x0 DUROS inside dune valley)
TargetVolume = -100.81;
maxRetreat = 500;
zTemp = zInitial;
zTemp(xInitial > -70 & zInitial > WL_t) = WL_t - 1;

%% $RunCode
try 
    testresult = false;
    result = getAdditionalErosion(xInitial,zTemp,...
        'TargetVolume',TargetVolume,...
        'poslndwrd',poslndwrd,...
        'precision',precision,...
        'maxiter',maxiter,...
        'slope',slope,...
        'x0min',x0DUROS-maxRetreat,...
        'x0max',x0DUROS - 20,...
        'zmin',WL_t);
    % TODO adjust assert
    testresult = true;
catch me
    testresult = false;
end

%% $PublishResult
figure('Color','w');
hold on
ylim([0 16]);
xlim([-150, 250]);
plot(xInitial,zTemp,'DisplayName','Initial profile','Color',[255 222 111]/255,'LineWidth',2);
plot(xlim,ones(1,2)*WL_t,'DisplayName',['maximum storm surge level (NAP + ' num2str(WL_t) ' m)']);
patchx = [result.xActive; flipud(result.xActive)];
patchz = [result.zActive; flipud(result.z2Active)];
patch(patchx,patchz,'g','EdgeColor','none','FaceColor', [0 0.6 0],'DisplayName','Aditional Erosion')
legend show

end

function testresult = addvolumecase5(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd)
%% $Description (Name = x0 Duros within valley, but also restricted in valley)

TargetVolume = -100.81;
maxRetreat = 30;
zTemp = zInitial;
zTemp(xInitial > -70 & zInitial > WL_t) = WL_t - 1;

%% $RunCode
try
    testresult = false;
    
    result = getAdditionalErosion(xInitial,zTemp,...
        'TargetVolume',TargetVolume,...
        'poslndwrd',poslndwrd,...
        'precision',precision,...
        'maxiter',maxiter,...
        'slope',slope,...
        'x0min',x0DUROS-maxRetreat,...
        'x0max',x0DUROS - 20,...
        'zmin',WL_t);
    testresult = ~result.info.resultinboundaries;
catch me
    testresult = nan;
end
%% $PublishResult
figure('Color','w');
hold on
ylim([0 16]);
xlim([-150, 250]);
plot(xInitial,zTemp,'DisplayName','Initial profile','Color',[255 222 111]/255,'LineWidth',2);
plot(xlim,ones(1,2)*WL_t,'DisplayName',['maximum storm surge level (NAP + ' num2str(WL_t) ' m)']);
patchx = [result.xActive; flipud(result.xActive)];
patchz = [result.zActive; flipud(result.z2Active)];
patch(patchx,patchz,'g','EdgeColor','none','FaceColor', [0 0.6 0],'DisplayName','Aditional Erosion')
legend show

end

function testresult = addvolumecase6(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd)
%% $Description (Name = No points above the waterline)
% There should be no result, but the function should not crash.

TargetVolume = -100.81;
maxRetreat = 30;
zTemp = zInitial;
zTemp(zInitial >= WL_t) = WL_t - 1;

%% $RunCode
testresult = false;
result = getAdditionalErosion(xInitial,zTemp,...
'TargetVolume',TargetVolume,...
'poslndwrd',poslndwrd,...
'precision',precision,...
'maxiter',maxiter,...
'slope',slope,...
'x0min',x0DUROS-maxRetreat,...
'x0max',x0DUROS - 20,...
'zmin',WL_t);
testresult = true;

%% $PublishResult
% No result, since the profile is below the water level
end

function testresult = addvolumecase7(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope)
%% $Description (Name = Switched x direction)
maxRetreat = 20;
TargetVolume = -100.81;
xTemp = -xInitial;
 
%% $RunCode
try
    testresult = false;
   
    result = getAdditionalErosion(xTemp,zInitial,...
        'TargetVolume',TargetVolume,...
        ...    'poslndwrd',-poslndwrd,...
        'precision',precision,...
        'maxiter',maxiter,...
        'slope',slope,...
        'x0min',0-(x0DUROS - maxRetreat),...
        'x0max',0-x0DUROS + 100,...
        'zmin',WL_t);
    testresult = true;
catch me
    testersult = false;
end

%% $PublishResult
figure('Color','w');
title('Testcase 4: Duros x0 value within dune valley');
hold on
ylim([0 16]);
xlim([-150, 250]);
plot(xTemp,zInitial,'DisplayName','Initial profile','Color',[255 222 111]/255,'LineWidth',2);
plot(xlim,ones(1,2)*WL_t,'DisplayName',['maximum storm surge level (NAP + ' num2str(WL_t) ' m)']);
patchx = [result.xActive; flipud(result.xActive)];
patchz = [result.zActive; flipud(result.z2Active)];
patch(patchx,patchz,'g','EdgeColor','none','FaceColor', [0 0.6 0],'DisplayName','Aditional Erosion')
legend show

end

function testresult = addvolumecase8(WL_t,precision,maxiter,slope)
%% $Description (Name = Switched xdir 2)
xInitial = (0:5:6300)';
zInitial = [-15.7 -15.65 -15.6 -15.65 -15.7 -15.7 -15.7 -15.65 -15.6 -15.65 -15.7 -15.65 -15.6 -15.65 -15.7 -15.7 -15.7 -15.65 -15.6 -15.65 -15.7 -15.65 -15.6 -15.6 -15.6 -15.65 -15.7 -15.7 -15.7 -15.65 -15.6 -15.55 -15.5 -15.6 -15.7 -15.65 -15.6 -15.65 -15.7 -15.6 -15.5 -15.55 -15.6 -15.65 -15.7 -15.65 -15.6 -15.65 -15.7 -15.65 -15.6 -15.65 -15.7 -15.7 -15.7 -15.6 -15.5 -15.5 -15.5 -15.55 -15.6 -15.6 -15.6 -15.55 -15.5 -15.55 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.55 -15.5 -15.55 -15.6 -15.6 -15.6 -15.55 -15.5 -15.55 -15.6 -15.6 -15.6 -15.6 -15.6 -15.65 -15.7 -15.7 -15.7 -15.65 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.6 -15.65 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.75 -15.8 -15.7 -15.6 -15.65 -15.7 -15.7 -15.7 -15.75 -15.8 -15.75 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.75 -15.8 -15.75 -15.7 -15.75 -15.8 -15.8 -15.8 -15.8 -15.8 -15.85 -15.9 -15.85 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.85 -15.9 -15.95 -16 -16.05 -16.1 -16 -15.9 -15.9 -15.9 -15.9 -15.9 -15.95 -16 -16 -16 -15.95 -15.9 -15.95 -16 -15.95 -15.9 -15.95 -16 -16 -16 -16.05 -16.1 -16.05 -16 -16 -16 -16.05 -16.1 -16.1 -16.1 -16 -15.9 -15.95 -16 -16 -16 -16 -16 -15.95 -15.9 -15.95 -16 -15.95 -15.9 -15.95 -16 -15.95 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.85 -15.8 -15.85 -15.9 -15.8 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.65 -15.6 -15.6 -15.6 -15.6 -15.6 -15.65 -15.7 -15.65 -15.6 -15.6 -15.6 -15.55 -15.5 -15.5 -15.5 -15.5 -15.5 -15.45 -15.4 -15.45 -15.5 -15.5 -15.5 -15.45 -15.4 -15.35 -15.3 -15.25 -15.2 -15.25 -15.3 -15.3 -15.3 -15.3 -15.3 -15.3 -15.3 -15.25 -15.2 -15.2 -15.2 -15.2 -15.2 -15.2 -15.2 -15.2 -15.2 -15.2 -15.2 -15.2 -15.2 -15.25 -15.3 -15.25 -15.2 -15.15 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.05 -15 -15.05 -15.1 -15.15 -15.2 -15.15 -15.1 -15 -14.9 -14.95 -15 -15 -15 -15.1 -15.2 -15.15 -15.1 -15.05 -15 -15.05 -15.1 -15.1 -15.1 -15.15 -15.2 -15.15 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.1 -15.05 -15 -15.05 -15.1 -15.1 -15.1 -15.15 -15.2 -15.2 -15.2 -15.2 -15.2 -15.15 -15.1 -15.15 -15.2 -15.2 -15.2 -15.2 -15.2 -15.25 -15.3 -15.3 -15.3 -15.3 -15.3 -15.25 -15.2 -15.25 -15.3 -15.3 -15.3 -15.35 -15.4 -15.35 -15.3 -15.35 -15.4 -15.4 -15.4 -15.4 -15.4 -15.4 -15.4 -15.45 -15.5 -15.45 -15.4 -15.45 -15.5 -15.5 -15.5 -15.55 -15.6 -15.55 -15.5 -15.55 -15.6 -15.6 -15.6 -15.6 -15.6 -15.55 -15.5 -15.6 -15.7 -15.65 -15.6 -15.6 -15.6 -15.7 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.8 -15.75 -15.7 -15.75 -15.8 -15.85 -15.9 -15.85 -15.8 -15.85 -15.9 -15.9 -15.9 -15.85 -15.8 -15.8 -15.8 -15.9 -16 -15.95 -15.9 -15.9 -15.9 -15.9 -15.9 -15.95 -16 -15.95 -15.9 -15.95 -16 -16 -16 -16 -16 -15.95 -15.9 -15.95 -16 -16 -16 -16 -16 -16.05 -16.1 -16.05 -16 -16.05 -16.1 -16.1 -16.1 -16.05 -16 -16 -16 -15.95 -15.9 -16 -16.1 -16.05 -16 -16.05 -16.1 -16 -15.9 -15.95 -16 -16 -16 -16 -16 -15.95 -15.9 -15.95 -16 -15.95 -15.9 -15.95 -16 -15.95 -15.9 -15.9 -15.9 -15.9 -15.9 -15.85 -15.8 -15.9 -16 -15.9 -15.8 -15.85 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.9 -15.85 -15.8 -15.8 -15.8 -15.8 -15.8 -15.75 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.7 -15.65 -15.6 -15.6 -15.6 -15.55 -15.5 -15.5 -15.5 -15.55 -15.6 -15.55 -15.5 -15.5 -15.5 -15.5 -15.5 -15.45 -15.4 -15.4 -15.4 -15.4 -15.4 -15.4 -15.4 -15.35 -15.48 -15.55 -15.62 -15.535 -15.45 -15.43 -15.41 -15.455 -15.5 -15.45 -15.4 -15.44 -15.48 -15.325 -15.17 -15.24 -15.31 -15.345 -15.38 -15.29 -15.2 -15.17 -15.14 -15.19 -15.24 -15.19 -15.14 -15.11 -15.08 -15.085 -15.09 -15.05 -15.01 -15 -14.99 -15.02 -15.05 -15.005 -14.96 -14.915 -14.87 -14.87 -14.87 -14.81 -14.75 -14.81 -14.87 -14.685 -14.5 -14.59 -14.68 -14.685 -14.69 -14.64 -14.59 -14.475 -14.36 -14.39 -14.42 -14.55 -14.68 -14.49 -14.3 -14.245 -14.19 -14.31 -14.43 -14.335 -14.24 -14.25 -14.26 -14.105 -13.95 -14.02 -14.09 -14.16 -14.23 -14.09 -13.95 -13.82 -13.92 -13.9 -13.88 -13.86 -13.84 -13.785 -13.73 -13.705 -13.68 -13.655 -13.63 -13.605 -13.58 -13.55 -13.52 -13.495 -13.47 -13.435 -13.4 -13.365 -13.33 -13.31 -13.29 -13.27 -13.25 -13.185 -13.12 -13.1 -13.08 -13.005 -12.93 -12.9 -12.87 -12.855 -12.84 -12.8 -12.76 -12.73 -12.7 -12.675 -12.65 -12.64 -12.63 -12.59 -12.55 -12.52 -12.49 -12.43 -12.37 -12.325 -12.28 -12.26 -12.24 -12.215 -12.19 -12.16 -12.13 -12.08 -12.03 -11.965 -11.9 -11.905 -11.91 -11.865 -11.82 -11.765 -11.71 -11.67 -11.63 -11.56 -11.49 -11.49 -11.49 -11.425 -11.36 -11.34 -11.32 -11.27 -11.22 -11.19 -11.16 -11.08 -11 -10.965 -10.93 -10.88 -10.83 -10.795 -10.76 -10.715 -10.67 -10.635 -10.6 -10.55 -10.5 -10.46 -10.42 -10.345 -10.27 -10.265 -10.26 -10.225 -10.19 -10.125 -10.06 -10.03 -10 -9.97 -9.94 -9.875 -9.81 -9.79 -9.77 -9.72 -9.67 -9.62 -9.57 -9.55 -9.53 -9.49 -9.45 -9.395 -9.34 -9.27 -9.2 -9.135 -9.07 -9.025 -8.98 -8.935 -8.89 -8.845 -8.8 -8.77 -8.74 -8.675 -8.61 -8.5 -8.39 -8.305 -8.22 -8.13 -8.04 -7.965 -7.89 -7.87 -7.85 -7.78 -7.71 -7.58 -7.45 -7.38 -7.31 -7.235 -7.16 -7.045 -6.93 -6.815 -6.7 -6.61 -6.52 -6.42 -6.32 -6.215 -6.11 -5.985 -5.86 -5.745 -5.63 -5.515 -5.4 -5.3 -5.2 -5.09 -4.98 -4.9 -4.82 -4.735 -4.65 -4.59 -4.53 -4.495 -4.46 -4.47 -4.48 -4.505 -4.53 -4.63 -4.73 -4.835 -4.94 -5.085 -5.23 -5.355 -5.48 -5.68 -5.88 -5.97 -6.06 -6.19 -6.32 -6.35 -6.38 -6.415 -6.45 -6.425 -6.4 -6.41 -6.42 -6.38 -6.34 -6.265 -6.19 -6.095 -6 -5.9 -5.8 -5.715 -5.63 -5.575 -5.52 -5.435 -5.35 -5.43 -5.51 -5.51 -5.51 -5.435 -5.36 -5.195 -5.03 -4.83 -4.63 -4.44 -4.25 -4.12 -3.99 -3.86 -3.73 -3.605 -3.48 -3.31 -3.14 -3 -2.86 -2.74 -2.62 -2.525 -2.43 -2.325 -2.22 -2.23 -2.24 -2.385 -2.53 -2.635 -2.74 -2.795 -2.85 -2.915 -2.98 -2.995 -3.01 -3.05 -3.09 -3.115 -3.14 -3.17 -3.2 -3.24 -3.28 -3.305 -3.33 -3.355 -3.38 -3.35 -3.32 -3.17 -3.02 -2.82 -2.62 -2.41 -2.2 -2.005 -1.81 -1.62 -1.43 -1.33 -1.23 -1.15 -1.07 -0.975 -0.88 -0.815 -0.75 -0.7 -0.65 -0.635 -0.62 -0.61 -0.6 -0.625 -0.65 -0.64 -0.63 -0.865 -1.1 -1.28 -1.46 -1.38 -1.27 -1.03 -0.8 -0.44 -0.1 0.2 0.44 0.51 0.61 0.73 0.83 0.82 0.82 0.88 1 1.14 1.3 1.38 1.49 1.61 1.7 1.91 2.13 2.48 3.04 3.8 5.46 6.94 7.11 8.12 10.69 12.96 15 17.56 18.1 17.79 17.48 17.15 16.69 16.23 15.72 15.66 15.98 16.12 15.47 15.27 15.03 15.48 15.05 14.77 15.64 16.91 17.08 16.6 16.14 14.56 13.04 13 13.31 14.01 14.41 13.07 11.32 11.25 11.02 9.95 10.21 9.67 8.69 9.1 9.58 9.95 10.51 10.21 9.49 8.66 8.73 8.77 8.84 8.86 8.79 8.11 8.91 8.69 8.14 8.14 8.72 8.9 8.93 9.43 8.81 7.2 5.52 5.52 5.19 5.19 5.23 5.55429 5.87857 6.20286 6.52714 6.85143 7.17571 7.5 10 10.4167 10.8333 11.25 11.6667 12.0833 12.5 15 15.5 16 16.5 17 17.5 16.6667 15.8333 15 14.7727 14.5455 14.3182 14.0909 13.8636 13.6364 13.4091 13.1818 12.9545 12.7273 12.5 12.25 12 11.75 11.5 11.75 12 12.25 12.5 15 17.5 18.75 20 21 20 17.5 16.25 15 14 14.5 15 16.25 17.5 18 18.5 18.1667 17.8333 17.5 17 16.5 16 15.5 15 16.25 17.5 18.75 20 21 20 19.5 19 20 20.4167 20.8333 21.25 21.6667 22.0833 22.5 22.1429 21.7857 21.4286 21.0714 20.7143 20.3571 20 19.1667 18.3333 17.5 17 16.5 16 15.5 15 14.5833 14.1667 13.75 13.3333 12.9167 12.5 11.6667 10.8333 10 9.8 9.6 9.4 9.2 9 9.2 9.4 9.6 9.8 10 10.3333 10.6667 11 10.75 10.5 10.25 10 9.75 9.5 9.25 9 9.25 9.5 9.75 10 10.25 10.5 10.75 11 11.25 11.5 11.75 12 12.25 12.5 15 15.625 16.25 16.875 17.5 18.125 18.75 19.375 20 21.25 22.5 23 23.5 24 24.5 25 26.25 27.5 27.8333 28.1667 28.5 28.25 28 27.75 27.5 26.6667 25.8333 25 23.75 22.5 20 17.5 15 14.1667 13.3333 12.5 11.25 10]';
x0DUROS = 5200;
TargetVolume = -100.81;

%% $RunCode
try
    testresult = false;
    result = getAdditionalErosion(xInitial,zInitial,...
        'TargetVolume',TargetVolume,...
        ...    'poslndwrd',-poslndwrd,...
        'precision',precision,...
        'maxiter',maxiter,...
        'slope',slope,...
        'x0min',min(xInitial),...
        'x0max',x0DUROS,...
        'zmin',WL_t);
    testresult = true;
catch me
    testresult = false;
end

%% $PublishResult
figure('Color','w');
title('Testcase 4: Duros x0 value within dune valley');
hold on
ylim([0 16]);
xlim([-150, 250]);
plot(xInitial,zInitial,'DisplayName','Initial profile','Color',[255 222 111]/255,'LineWidth',2);
plot(xlim,ones(1,2)*WL_t,'DisplayName',['maximum storm surge level (NAP + ' num2str(WL_t) ' m)']);
patchx = [result.xActive; flipud(result.xActive)];
patchz = [result.zActive; flipud(result.z2Active)];
patch(patchx,patchz,'g','EdgeColor','none','FaceColor', [0 0.6 0],'DisplayName','Aditional Erosion')
legend show
end

function testresult = addvolumecase9(xInitial,zInitial,x0DUROS,WL_t,precision,maxiter,slope,poslndwrd)
%% $Description (Name = horizontal part at waterline & EvaluateCode = true & PublishCode = false)
% There is a possibility that the profile has a horizontal part at the dune front that lies exactly 
% at the water line. In that case the valleypoints on the dune face should be ignored, to prevent
% the code from crashing.

TargetVolume = -100.81;
maxRetreat = 20;
dx = 10;
xmax = max(xInitial(zInitial == WL_t));
zInitial = interp1(xInitial,zInitial,unique(cat(1,xInitial,xmax-dx,xmax-dx+0.1)));
xInitial = unique(cat(1,xInitial,xmax-dx,xmax-dx+0.1));
zInitial(xInitial < xmax & xInitial > xmax-dx) = WL_t;

figure('Color','w');
hold on
ylim([0 16]);
xlim([-150, 250]);
plot(xInitial,zInitial,'DisplayName','Initial profile','Color',[255 222 111]/255,'LineWidth',2);
plot(xlim,ones(1,2)*WL_t,'DisplayName',['maximum storm surge level (NAP + ' num2str(WL_t) ' m)']);
scatter(xInitial(zInitial == WL_t),zInitial(zInitial == WL_t),'*r','DisplayName','Crossings with waterline (possible valley points');
legend show

%% $RunCode
try
    testresult = false;
    result = getAdditionalErosion(xInitial,zInitial,...
        'TargetVolume',TargetVolume,...
        'poslndwrd',poslndwrd,...
        'precision',precision,...
        'maxiter',maxiter,...
        'slope',slope,...
        'x0min',x0DUROS-maxRetreat,...
        'x0max',x0DUROS,...
        'zmin',WL_t);
    testresult = true;
    
catch me
    testresult = false;
end

%% $PublishResult
figure('Color','w');
hold on
ylim([0 16]);
xlim([-150, 250]);
plot(xInitial,zInitial,'DisplayName','Initial profile','Color',[255 222 111]/255,'LineWidth',2);
plot(xlim,ones(1,2)*WL_t,'DisplayName',['maximum storm surge level (NAP + ' num2str(WL_t) ' m)']);
scatter(xInitial(zInitial == WL_t),zInitial(zInitial == WL_t),'*r','DisplayName','Crossings with waterline (possible valley points');
patchx = [result.xActive; flipud(result.xActive)];
patchz = [result.zActive; flipud(result.z2Active)];
patch(patchx,patchz,'g','EdgeColor','none','FaceColor', [0 0.6 0],'DisplayName','Aditional Erosion')
legend show
end