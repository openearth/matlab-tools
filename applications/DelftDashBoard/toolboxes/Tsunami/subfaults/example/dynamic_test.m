clear all
close all

% SeanPaul La Selle, USGS
% 30 September, 2015

% This script shows an example of how rupture and rise time data from
% subfault inversions is used to calculate the fraction of deformation that
% occurs at a given time.  This is necessary to determine when calculating 
% dynamic rupture.

%% Load Subfault Data
file = 'ucsb_subfault_2011_03_11_v3.cfg';
path = '';
event_title = 'Tohoku, Japan 11-03-2011';
subfaults = read_subfault('path',fullfile(path,file));

%% just use the first subfault to play with
rupture_time = subfaults.rupture_time(1);
rise_time = subfaults.rise_time(1);
rise_time_end = subfaults.rise_time_ending(1);
slip = subfaults.slip(1);

%% Function for calculating rise fraction as a function of t
t = [149:0.1:157]; % times for which to calculate the rise fraction

rf = rise_fraction(t, rupture_time, rise_time, rise_time_end);

% plot slip as a fraction of time
plot(t,rf,'b-','LineWidth',3)
hold on

% plot vertical line at rupture time
plot([rupture_time, rupture_time],[0,1],'k--')
text(rupture_time-0.2,0.005,'Rupture time','rotation',90)
% plot vertical line at rise time start
plot([rupture_time+rise_time,rupture_time+rise_time],[0,1],'k--')
text(rupture_time+rise_time-0.2,0.005,'Rise time','rotation',90)
% plot vertical line at rise time end
plot([rupture_time+rise_time+rise_time_end,rupture_time+rise_time+rise_time_end],...
    [0,1],'k--')
text(rupture_time+rise_time+rise_time_end-0.2,0.005,'Rise time end','rotation',90)

ylim([0 1])
ylabel('Rise fraction')
xlabel('Time after earthquake begins [sec]')

title('rise fraction(t)')
hold off