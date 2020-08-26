% Function to get the scattering, transmission and zscat from a binary (v. 2.05)
% LISST-100 or LISST-100X data file (.dat extension) and from a zscat file
% in either binary (.dat) or ASCII (.asc) format.
%
%  Usage:        [scat,tau,zsc,data,cscat] = getscat('datafile','zscfile',X,'ringarefile');
%
% Set X=1 for LISST-100X data, all other values for LISST-100 format
%
% Output:
% scat is the raw scattering signature in digital counts (i.e. NOT corrected
% with the ringarea file!!)
% tau is the optical transmission
% zsc is the loaded zscat
% data is the raw data file, converted from binary, or it can be a .LOG
% file
% cscat is the corrected scattering, computed if the ringarea file is
% supplied as input
%
% REQUIRED FILES: tt2mat.m
% Based on original getscat and getscatX by YCA
% 2008-4-14 Merged by OAM to become version 2.0
% 2008-9-29: Added option to load datafiles as log files (OAM v. 2.05).
% 2010-8-18: Added option to output cscat if the ringarea file is
%   specified (OAM v. 2.10)
% 2010-9-17: Added check to see if zscat file in dat format had
%   more than 1 row. (OAM v. 2.11)
% 2011-3-10: Forced negative cscats to 0 (OAM)
% 2011-8-9: OAM
% 2015-1-21 DRD corrected interpretation of negative temperatures

function [scat,tau,zsc,data,cscat] = getscat(datafile,zscfile,X,ringareafile)
%check to see if at least 3 input arguments exists
if nargin < 3
    error('You must specify at least datafile, zscfile, and X.')
end

%check to see if cscat is being output if ringarea file is not supplied.
if nargin < 4
    if nargout > 4
        error('You have not specified a ringarea filename, yet have specified cscat as output. You must specify a ringarea file if you wish cscat to be output.')
    end
end

if nargin == 4
    dcal = load(ringareafile);
end

%*******************************************************
%1: Load the zscat file in either binary or ASCII format
%*******************************************************
[pathstr, name, ext] = fileparts(zscfile);%get datafile info

if sum(strcmp(ext,{'.asc','.ASC'}))>0;%if the zscat file is an ASCII file...
    zsc=load(zscfile);%go ahead and load it
    a = size(zsc,1);%get the number of rows in zsc
    if (a~=1);%if the zsc file is in ASCII format there should only be one row and 40 columns
        zsc = zsc';%if not, transpose
    end
else%if the zscat file is NOT an ASCII file then it can only be a .dat file
    zsc = tt2mat(zscfile,40);%so read it using tt2mat
    if mean(zsc(1:end,40))==0;%if SL data from the 25X board
        X = 0;%then we DO NOT want to treat data as x10 because they are not...
    end
    if X == 1;%do we have LISST-100X data format?
        zsc(:,1:32) = zsc(:,1:32)./10;%then divide rings 1-32 by 10.
    end
    if size(zsc,1) > 1%are there more than 1 row in the zsc dat file? (OAM 9/17/10)
        zsc = mean(zsc);%compute mean so that zsc always is a 1 x 40 vector
    end
end
r = zsc(33)/zsc(36);%compute the laser power/laser reference ratio (to adjust for drift in laser output power over time)

%****************************
%2: Read the binary data file
%****************************
[pathstr, name, ext] = fileparts(datafile);%get datafile info
if sum(strcmp(ext,{'.log','.LOG'}))>0;%if the data file is a log file
    data=load(datafile);%load it right away
else
    data = tt2mat(datafile,40);%read the binary data file using tt2mat
    if X == 1;%do we have LISST-100X data format?
        data(:,1:32) = data(:,1:32)./10;%then divide rings 1-32 by 10.
    end
end
%note: log files are by default stored in LISST-100 format so they do
%not need to be divided by 10 after being loaded.

% DRD 2015-1-21 added the following to correct negative temperatures.
% Values are loaded as unsigned integers with range 0 to 65535, but
% the original values were signed 2's complement with range -32768 to
% 32767. A value > 32767 actually represents a negative value with
% 65536 added to it.
data(data(:,38)>32767,38) = data(data(:,38)>32767,38) - 65536;

%************************************************************************
%3: Compute optical transmission, raw scattering, and cscat if applicable
%************************************************************************
tau = data(:,33)./r./data(:,36);%compute optical transmission, taking the eventual drift in laser power into account
row = size(data,1);
scat = zeros(row,32);%pre-allocate scat matrix

if nargin ~=4
    for i = 1:row
        scat(i,:)=data(i,1:32)/tau(i)-(zsc(1:32)*data(i,36)/zsc(36));
    end
else
    cscat = zeros(row,32);%pre-allocate cscat matrix
    for i = 1:row
        scat(i,:)=data(i,1:32)/tau(i)-(zsc(1:32)*data(i,36)/zsc(36));
        cscat(i,:) = dcal.*scat(i,:);
    end
    cscat(cscat<0)=0;%negative cscats are not possible, so set them to 0.
end
