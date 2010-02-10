%WorkingWithVolt is an example of how volt works.
%   Please copy WorkingWithVolt to your working directory so you can edit 
%   the file. This is a script file, not a function. Examples of what you
%   will need to change:
%   * The name of the log file;
%   * The name of the directory were the log file has been saved;
%   * The start time and the end time. If you leave them empty, volt will
%     use the start time and the end time of the log file itself.

clear all
close all
clc

dbstop if error

global volt

%% Read data
volt.file = 'VOX MAXIMA200911251652.log';
% volt.file = 'RDAM Trip1010 01-May-2007 07h04.log';
volt.path = 'D:\Documents and Settings\psh\My Documents\MATLAB';
voltReadLog
% voltLoadMatFile
voltListTags

%% Time Selection
% volt.t1 = [];
% volt.t2 = [];
volt.t1 = datenum(2009, 11, 25, 17, 20,  0);
volt.t2 = datenum(2009, 11, 25, 17, 50,  0);
voltSetTimeSelection

%% Data analysis and plotting
% voltPlot('bb pompdebiet                   [m3/s   ]')

voltPlot( ...
    'BOT288 uwp rpm                         [rpm    ]', ...
    'AIN61 main engine sb speed            [rpm    ]')

tt = voltGetSignal('time');
tt = (tt - tt(1)) * 24 * 60 * 60;
Hman = voltGetSignal('BOT282 uwp head                        [kPa    ]');
figure
plot(tt, Hman)
grid on
xlabel('time [s]')
ylabel('Hman [kPa]')