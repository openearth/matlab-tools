function testresult = getIterationBoundaries_test()
% GETITERATIONBOUNDARIES_TEST  Checks basic functionalities of getIterationBoundaries
%  
% This test checks the most basic functionalities of getIterationBoundaries. It should of course
% provide the correct boundaries, but also important.. It should not crash when there is no solution
% at all and it should provide us possible channel points that can influence the solution.
%
%   See also  getIterationBoundaries getDuneErosion DuneErosionSettings

%% Credentials
%   --------------------------------------------------------------------
%   2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   --------------------------------------------------------------------
% This test is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 20 Aug 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = getIterationBoundaries function test)
% This test checks the basic functionalities of getIterationBoundaries. It should provide the
% correct boundaries, but also should not crash whem there is no solution. It involves 6 testcases:
%
% * Reference Profile
% * No points above the water line
% * Limited by lack of information at landward side
% * Limited by lack of information at seaward side
% * Limited by point of contact with the initial profile
% * Possible problems with a channel slope
%
% For more information see the documentation of the testcases individually

%% $RunCode
testresult(1) = SimpleProfile();
testresult(2) = ProfileBelowWl();
testresult(3) = CroppedLandward();
testresult(4) = ChannelSlope();
testresult(5) = CroppedSeaward();
testresult(6) = LWBByPointOfContact();

testresult = all(testresult);

%% $PublishResult
% Look at results of the testcases instead
end

function testresult = SimpleProfile()
%% $Description (Name = Reference profile)
% This is a basic test of the getIterationBoundaries function. Input is the Dutch reference profile.
% Other parameters:
%
% # Hs = 9 (m)
% # Tp = 12 (s)
% # SSL = 5 (m + NAP)
%
% The profile looks as follows:

xInitial = [-250 -24.375 5.625 55.725 230.625 1950]';
zInitial = [15 15 3 0 -3 -14.4625]';
xparab = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
zparab = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
Hsig_t = 9;
Tp_t = 12;
WL_t = 5;
w = 0.0246782;
figure('Color','w');
hold on;
box on;
grid on;
xlabel('Cross-shore distance [m w.r.t. RSP]');
ylabel('Heigth [m w.r.t. NAP]');
patch([xInitial;max(xInitial);min(xInitial)],[zInitial;min(zInitial);min(zInitial)],[255 222 111]/255,'DisplayName','Reference profile','LineWidth',2);
tmp = plot(xparab,zparab,'DisplayName','Parabolic profile','Color','r','LineWidth',2);
ylim([min(ylim)-0.1*diff(ylim) max(ylim)+0.1*diff(ylim)]);
plot(xlim,ones(1,2)*WL_t,'Color','b','LineWidth',2,'DisplayName','Maximum Storm Surge Level (SSL = 5 m+NAP)');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Hs = 9 [m]');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Tp = 12 [s]');
legend(gca,'show');
%% Iteration boundaries
% We would expect the two iteration boundaries to be as follows:
% 
% _LandwardBoundary_
% The landward boundary is limited by the fact that the toe of the parabolic profile still needs to 
% cross the initial profile. There is no solution possible more seaward. In this case that means a
% landward boundary of x0 = -166.1438 [m]
%
% _SeawardBoundary_
% The most seaward solution is achieved when the x0 is literally at the crossing between the SSL and
% the initial profile (x0 = 0.625 m)
%
% This is illustrated in the following figure:

delete(tmp);
plot(xparab-166.1438,zparab,'Color',[0.6 1 0.6],'DisplayName','Most landward solution','LineWidth',2);
plot([-176.1438 -166.1438],[15,WL_t],'Color',[0.6 1 0.6],'HandleVisibility','off','LineWidth',2);
plot(xparab+0.625,zparab,'Color',[1 0.6 0.6],'DisplayName','Most seaward solution','LineWidth',2);
legend(gca,'off');
legend(gca,'show');
snapnow
close(gcf);

%% $RunCode
% Write test script here
[x00min, x0min, x0max, x0except, xInitial, zInitial, SeawardBoundaryofInterest, chpoints_new] = getIterationBoundaries(xInitial,zInitial,xparab,zparab,Hsig_t,Tp_t,WL_t,w);

testresult = all([...
    x00min == -240,...
    roundoff(x0min,4) == -166.1438,...
    roundoff(x0max,4) == 0.625,...
    isempty(x0except),...
    SeawardBoundaryofInterest == 1950,...
    isempty(chpoints_new)]);

%% $PublishResult
% The results of this test are visualized in the following figure:
figure('Color','w');
hold on;
box on;
grid on;
xlabel('Cross-shore distance [m w.r.t. RSP]');
ylabel('Heigth [m w.r.t. NAP]');
patch([xInitial;max(xInitial);min(xInitial)],[zInitial;min(zInitial);min(zInitial)],[255 222 111]/255,'DisplayName','Reference profile','LineWidth',2);
plot(xparab,zparab,'DisplayName','Parabolic profile','Color','r','LineWidth',2);
ylim([min(ylim)-0.1*diff(ylim) max(ylim)+0.1*diff(ylim)]);
plot(xlim,ones(1,2)*WL_t,'Color','b','LineWidth',2,'DisplayName','Maximum Storm Surge Level (SSL = 5 m+NAP)');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Hs = 9 [m]');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Tp = 12 [s]');
plot(xparab+x0min,zparab,'Color',[0.6 1 0.6],'DisplayName','Most landward solution','LineWidth',2);
plot([x0min-10 x0min],[15,WL_t],'Color',[0.6 1 0.6],'HandleVisibility','off','LineWidth',2);
plot(xparab+x0max,zparab,'Color',[1 0.6 0.6],'DisplayName','Most seaward solution','LineWidth',2);
vline(x0min,'k:');
vline(x0max,'k:');
legend(gca,'show');
snapnow
close(gcf);

end

function testresult = ProfileBelowWl()
%% $Description (Name = Profile below water level)
% This is a test to check if the function does not crash if the profile is below the SSL.

xInitial = [-250 1.875 5.625 55.725 230.625 1950]';
zInitial = [4.5 4.5 3 0 -3 -14.4625]';
xparab = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
zparab = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
Hsig_t = 9;
Tp_t = 12;
WL_t = 5;
w = 0.0246782;
figure('Color','w');
hold on;
box on;
grid on;
xlabel('Cross-shore distance [m w.r.t. RSP]');
ylabel('Heigth [m w.r.t. NAP]');
patch([xInitial;max(xInitial);min(xInitial)],[zInitial;min(zInitial);min(zInitial)],[255 222 111]/255,'DisplayName','Reference profile','LineWidth',2);
ylim([min(ylim)-0.1*diff(ylim) max(ylim)+0.1*diff(ylim)]);
plot(xlim,ones(1,2)*WL_t,'Color','b','LineWidth',2,'DisplayName','Maximum Storm Surge Level (SSL = 5 m+NAP)');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Hs = 9 [m]');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Tp = 12 [s]');
legend(gca,'show');
snapnow;
close(gcf);

%% $RunCode
[x00min, x0min, x0max, x0except, xInitial, zInitial, SeawardBoundaryofInterest, chpoints_new] = getIterationBoundaries(xInitial,zInitial,xparab,zparab,Hsig_t,Tp_t,WL_t,w);

testresult = all([...
    isempty(x00min),...
    isempty(x0min),...
    isempty(x0max),...
    isempty(x0except),...
    isempty(SeawardBoundaryofInterest),...
    isempty(chpoints_new)]);

%% $PublishResult
% Testresult speaks for itself...
disp(testresult)
end

function testresult = CroppedLandward()
%% $Description (Name = Profile cropped landward)
% This testcase has less information at the landward side. This causes the most landward solution to
% be limited, since the dunecrest of the most landward solution cannot be more landward than we have
% information. 
xInitial = [-150 -24.375 5.625 55.725 230.625 1950]';
zInitial = [15 15 3 0 -3 -14.4625]';
xparab = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
zparab = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
Hsig_t = 9;
Tp_t = 12;
WL_t = 5;
w = 0.0246782;
figure('Color','w');
hold on;
box on;
grid on;
xlabel('Cross-shore distance [m w.r.t. RSP]');
ylabel('Heigth [m w.r.t. NAP]');
patch([xInitial;max(xInitial);min(xInitial)],[zInitial;min(zInitial);min(zInitial)],[255 222 111]/255,'DisplayName','Reference profile','LineWidth',2);
ylim([min(ylim)-0.1*diff(ylim) max(ylim)+0.1*diff(ylim)]);
plot(xlim,ones(1,2)*WL_t,'Color','b','LineWidth',2,'DisplayName','Maximum Storm Surge Level (SSL = 5 m+NAP)');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Hs = 9 [m]');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Tp = 12 [s]');
legend(gca,'show');
snapnow;
close(gcf);

%% $RunCode
[x00min, x0min, x0max, x0except, xInitial, zInitial, SeawardBoundaryofInterest, chpoints_new] = getIterationBoundaries(xInitial,zInitial,xparab,zparab,Hsig_t,Tp_t,WL_t,w);

testresult = all([...
    x00min == -140,...
    roundoff(x0min,4) == -140,...
    roundoff(x0max,4) == 0.625,...
    isempty(x0except),...
    SeawardBoundaryofInterest == 1950,...
    isempty(chpoints_new)]);

%% $PublishResult
% The test result is visualized in the following figure:

figure('Color','w');
hold on;
box on;
grid on;
xlabel('Cross-shore distance [m w.r.t. RSP]');
ylabel('Heigth [m w.r.t. NAP]');
patch([xInitial;max(xInitial);min(xInitial)],[zInitial;min(zInitial);min(zInitial)],[255 222 111]/255,'DisplayName','Reference profile','LineWidth',2);
ylim([min(ylim)-0.1*diff(ylim) max(ylim)+0.1*diff(ylim)]);
plot(xlim,ones(1,2)*WL_t,'Color','b','LineWidth',2,'DisplayName','Maximum Storm Surge Level (SSL = 5 m+NAP)');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Hs = 9 [m]');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Tp = 12 [s]');
plot(xparab+x0min,zparab,'Color',[0.5 1 0.5],'LineWidth',2,'DisplayName','most landward solution');
plot([x0min-10 x0min],[zInitial(1),WL_t],'Color',[0.5 1 0.5],'LineWidth',2,'HandleVisibility','off');
legend(gca,'show');
snapnow;
close(gcf);
end

function testresult = CroppedSeaward()
%% $Description (Name = SWB limited by profile)
% This time the profile is shortened at the seaward side. The most seaward solution is now dominated
% by the fact that do not have enough information. The profile looks as follows:

xInitial = [-250 -24.375 5.625 55.725 230.625 300]';
zInitial = [15 15 3 0 -3 -3.4625]';
xparab = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
zparab = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
Hsig_t = 9;
Tp_t = 12;
WL_t = 5;
w = 0.0246782;
figure('Color','w');
hold on;
box on;
grid on;
xlabel('Cross-shore distance [m w.r.t. RSP]');
ylabel('Heigth [m w.r.t. NAP]');
patch([xInitial;max(xInitial);min(xInitial)],[zInitial;min(zInitial);min(zInitial)],[255 222 111]/255,'DisplayName','Reference profile','LineWidth',2);
ylim([min(ylim)-0.1*diff(ylim) max(ylim)+0.1*diff(ylim)]);
plot(xlim,ones(1,2)*WL_t,'Color','b','LineWidth',2,'DisplayName','Maximum Storm Surge Level (SSL = 5 m+NAP)');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Hs = 9 [m]');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Tp = 12 [s]');
legend(gca,'show');
snapnow;
close(gcf);
%%
% When determining the iteration boundaries the mpst seaward boundary is determined by the toe of
% the profile (plus the 1:12,5 slope towards the initial profile). and becomes x0max = -46.2311 [m].

%% $RunCode
[x00min, x0min, x0max, x0except, xInitial, zInitial, SeawardBoundaryofInterest, chpoints_new] = getIterationBoundaries(xInitial,zInitial,xparab,zparab,Hsig_t,Tp_t,WL_t,w);

testresult = all([...
    x00min == -240,...
    roundoff(x0min,4) == -166.1438,...
    roundoff(x0max,4) == -46.2311,...
    isempty(x0except),...
    SeawardBoundaryofInterest == 300,...
    isempty(chpoints_new)]);

%% $PublishResult
% The determined iteration boundaries are plotted in the following figure:
figure('Color','w');
hold on;
box on;
grid on;
xlabel('Cross-shore distance [m w.r.t. RSP]');
ylabel('Heigth [m w.r.t. NAP]');
patch([xInitial;max(xInitial);min(xInitial)],[zInitial;min(zInitial);min(zInitial)],[255 222 111]/255,'DisplayName','Reference profile','LineWidth',2);
ylim([min(ylim)-0.1*diff(ylim) max(ylim)+0.1*diff(ylim)]);
plot(xlim,ones(1,2)*WL_t,'Color','b','LineWidth',2,'DisplayName','Maximum Storm Surge Level (SSL = 5 m+NAP)');
plot(xparab+x0max,zparab,'Color','r','lineWidth',2);
plot([max(xparab)+x0max max(xInitial)],[min(zparab) zInitial(end)],'Color','r','LineWidth',2);
snapnow;
close(gcf);
end

function testresult = LWBByPointOfContact()
%% $Description (Name = LWB limited by profile info)
% This time the landward boundary is limited by the shape of the profile. The profile looks as
% follows. 

xInitial = [-250 -24.375 0.625 5.625 55.725 75 230.625 351.116 1950]';
zInitial = [15 15 5 3 0 -1 -3 -3.80327 -14.4625]';
xparab = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
zparab = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
Hsig_t = 9;
Tp_t = 12;
WL_t = 5;
w = 0.0246782;
figure('Color','w');
hold on;
box on;
grid on;
xlabel('Cross-shore distance [m w.r.t. RSP]');
ylabel('Heigth [m w.r.t. NAP]');
patch([xInitial;max(xInitial);min(xInitial)],[zInitial;min(zInitial);min(zInitial)],[255 222 111]/255,'DisplayName','Reference profile','LineWidth',2);
ylim([min(ylim)-0.1*diff(ylim) max(ylim)+0.1*diff(ylim)]);
plot(xlim,ones(1,2)*WL_t,'Color','b','LineWidth',2,'DisplayName','Maximum Storm Surge Level (SSL = 5 m+NAP)');
plot(xparab,zparab,'DisplayName','Parabolic profile','Color','r','LineWidth',2);
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Hs = 9 [m]');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Tp = 12 [s]');
legend(gca,'show');
snapnow;
close(gcf);
%% 
% Since a solution is only possible when we have two crossings between the initial profile and the
% DUROS+ profile (parabolic profile), steep parabolic profiles limit the boundaries due to the fact
% that they have to remain in contact with the initial profile at least at one location. The LWB now
% becomes x0min = -193.8054

%% $RunCode
[x00min, x0min, x0max, x0except, xInitial, zInitial, SeawardBoundaryofInterest, chpoints_new] = getIterationBoundaries(xInitial,zInitial,xparab,zparab,Hsig_t,Tp_t,WL_t,w);

testresult = all([...
    x00min == -240,...
    roundoff(x0min,4) == -193.8054,...
    roundoff(x0max,4) == 0.625,...
    isempty(x0except),...
    SeawardBoundaryofInterest == 1950,...
    isempty(chpoints_new)]);

%% $PublishResult
% The result of this test is visualized below:
figure('Color','w');
hold on;
box on;
grid on;
xlabel('Cross-shore distance [m w.r.t. RSP]');
ylabel('Heigth [m w.r.t. NAP]');
patch([xInitial;max(xInitial);min(xInitial)],[zInitial;min(zInitial);min(zInitial)],[255 222 111]/255,'DisplayName','Reference profile','LineWidth',2);
ylim([min(ylim)-0.1*diff(ylim) max(ylim)+0.1*diff(ylim)]);
plot(xlim,ones(1,2)*WL_t,'Color','b','LineWidth',2,'DisplayName','Maximum Storm Surge Level (SSL = 5 m+NAP)');
plot(xparab+x0min,zparab,'DisplayName','Parabolic profile','Color','r','LineWidth',2);
legend(gca,'show');
snapnow;
close(gcf);
end

function testresult = ChannelSlope()
%% $Description (Name = Channel slope)
% SomeTimes a channel (defined by having a slope steeper than 1:12,5) can cause no solution.
% getIterationBoundaries should provide the poinst where this could be the case...

xInitial = [-250 -24.375 5.625 55.725 290 300 400]';
zInitial = [15 15 3 0 -3 -14.4625 -14.4625]';
xparab = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
zparab = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
Hsig_t = 9;
Tp_t = 12;
WL_t = 5;
w = 0.0246782;
figure('Color','w');
hold on;
box on;
grid on;
xlabel('Cross-shore distance [m w.r.t. RSP]');
ylabel('Heigth [m w.r.t. NAP]');
patch([xInitial;max(xInitial);min(xInitial)],[zInitial;min(zInitial);min(zInitial)],[255 222 111]/255,'DisplayName','Reference profile','LineWidth',2);
ylim([min(ylim)-0.1*diff(ylim) max(ylim)+0.1*diff(ylim)]);
plot(xlim,ones(1,2)*WL_t,'Color','b','LineWidth',2,'DisplayName','Maximum Storm Surge Level (SSL = 5 m+NAP)');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Hs = 9 [m]');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Tp = 12 [s]');
legend(gca,'show');
snapnow;
close(gcf);

%% $RunCode
[x00min, x0min, x0max, x0except, xInitial, zInitial, SeawardBoundaryofInterest, chpoints_new] = getIterationBoundaries(xInitial,zInitial,xparab,zparab,Hsig_t,Tp_t,WL_t,w);

testresult = all([...
    x00min == -240,...
    roundoff(x0min,4) == -147.4162,...
    roundoff(x0max,4) == -50.4499,...
    isempty(x0except),...
    SeawardBoundaryofInterest == 400,...
    roundoff(chpoints_new,4) == [-50.4499 290 -3]]);

%% $PublishResult
% getIterationBoundaries found the following channel points:
figure('Color','w');
hold on;
box on;
grid on;
xlabel('Cross-shore distance [m w.r.t. RSP]');
ylabel('Heigth [m w.r.t. NAP]');
patch([xInitial;max(xInitial);min(xInitial)],[zInitial;min(zInitial);min(zInitial)],[255 222 111]/255,'DisplayName','Reference profile','LineWidth',2);
ylim([min(ylim)-0.1*diff(ylim) max(ylim)+0.1*diff(ylim)]);
plot(xlim,ones(1,2)*WL_t,'Color','b','LineWidth',2,'DisplayName','Maximum Storm Surge Level (SSL = 5 m+NAP)');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Hs = 9 [m]');
plot(min(xlim),min(ylim),'lineStyle','none','DisplayName','Tp = 12 [s]');
plot(chpoints_new(:,2),chpoints_new(:,3),'LineStyle','none','Marker','o','Color','r','DisplayName','Channel points');
legend(gca,'show');
snapnow;

end

