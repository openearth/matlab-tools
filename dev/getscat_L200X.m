% getscat_L200X reads in and corrects scattering data from a LISST-200X RBN file
% 
% Usage:
%   RBNdata = getscat_L200X(datafile)  
%   OR
%   RBNdata = getscat_L200X(datafile,backgroundFile)
%
% Inputs:
%   getscat_L200X accepts a string with the location of a 200X .RBN data
%   file. Calibration information and background measurements are
%   contained in the .RBN file, therefore no other information is required.
%   Optionally, a background file (.BGT) different from the one contained 
%   in the .RBN file can be specified as the second argument. The data in 
%   the .RBN will then be processed using the supplied background file.
%
% Output:
%   getscat_L200X outputs a structure containing the following data.
%       cscat:           Corrected scattering
%       date:            Timestamp in Matlab datenum
%       transmission:    Optical transmission
%       depth:           Depth in meters
%       temperature:     Temperature in degrees Celsius
%       estMeanDiameter: Estimated Sauter mean diameter (um)
%       estTotalConc:    Estimated total concentration (uL/L)
%       Lp:              Transmitted laser power (mW)
%       Lref:            Laser power reference (mW)
%       analog1:         Analog input 1
%       analog2:         Analog input 2
%       supplyVolts:     Supply voltage (V)
%       humidity:        Internal instrument relative humidity (%)
%       accelXYZ:        Accelerometer X, Y, and Z
%       raw:             Raw data as it appears in the RBN file
%       factory_bkgrd:   The factory background (corrections applied to aux data)
%       bkgrd:           User collected background (corrections applied to aux data)
%       ambientLight:    Counts of ambient light removed from rings values
%       config:          Structure containing various instrument information
%       dcal:            Ring area coefficients
%       Ta:              Vector to convert corrected scattering to estimated total area concentration
%       Tv:              Vector to convert corrected scattering to estimated total volume concentration
%
%
% Sequoia Scientific, Inc. - 04/18/2017

function RBNdata = getscat_L200X(varargin)

%**************************************************************************
%1: Read the binary data file, check for user supplied background file
%**************************************************************************

[zsc,fzs,dcal,rawData,Tv,Ta,config,housek] = parse200XBinary(varargin{1});

% if supplied, load an external background file
if length(varargin) == 2
    zsc = load(varargin{2},'-ascii')';
    zsc(1:36) = zsc(1:36) .* 10;
elseif length(varargin) > 2
    error('Error: getscat_L200X only accepts up to two input arguments');
end

% check for the necessary information
if (isempty(zsc) || isempty(fzs) || isempty(dcal) || isempty(rawData))
    error(['Error: Data file contains no data or is missing critical ' ...
        'information such as the background or factory background']);
end

% Divide rings 1-36 by 10 to match L100 convention
data = rawData;
data(:,1:36) = data(:,1:36)./10;       
fzs(1:36) = fzs(1:36)./10;
zsc(1:36) = zsc(1:36)./10;

%************************************************************************
%2: Compute optical transmission, raw scattering, and corrected scatting
%************************************************************************

rows = size(data,1);

LaserRatio = zsc(37)/zsc(40);   % ratio of transmitted power / laser ref
tau = data(:,37)./LaserRatio./data(:,40); % compute optical transmission, taking the eventual drift in laser power into account

scat = data(:,1:36)./repmat(tau,1,36);                                     % correct for attenuation
scat = scat - repmat(zsc(1:36),rows,1) .* repmat(data(:,40)./zsc(40),1,36);% subtract the background
cscat = scat .* repmat(dcal,rows,1);                                       % apply ring area file
cscat = cscat .* repmat(fzs(40)./data(:,40),1,36);                         % normilize to factory LREF
cscat = cscat ./ config.VCC;                                                      % apply concentration calibration

cscat(cscat<0) = 0; %negative cscats are not possible, so set them to 0.

%**************************************************************************
%3: Apply corrections to auxiliary data
%**************************************************************************

if ~isempty(housek)
% create scale and offset correction arrays
scale = ones(1,23);
scale(1) = housek(17);   % Laser Transmission
scale(2) = 0.01;         % Supply Voltage
scale(3) = 0.0001;       % Analog Input 1
scale(4) = housek(16);   % Laser Reference
scale(5) = housek(3);    % Depth
scale(6) = housek(12);   % Temperature
scale(13) = 0.0001;      % Analog Input 2
scale(14) = housek(15);  % Sauter Mean Diameter
scale(15) = housek(14);  % Total Volume Concentration

offset = zeros(1,23);
offset(5) = housek(4);   % Depth
offset(6) = housek(13);  % Temperature

% apply corrections
Cdata(:,37:59) = data(:,37:59) .* repmat(scale,rows,1) + repmat(offset,rows,1);
scale(15) = 0.01; % total concentration replaced by path length (x100) in background records 
zsc(1,37:59) = zsc(1,37:59) .* scale + offset;
fzs(1,37:59) = fzs(1,37:59) .* scale + offset;
else
    warning(['auxiliary correction factors were not found in the ' ...
        'RBN file, auxiliary parameters will remain uncorrected.']);
end

%**************************************************************************
%4: Save the data in a structure
%**************************************************************************

RBNdata.cscat = cscat;
RBNdata.date = datenum(Cdata(:,43:48));
RBNdata.transmission = tau;
RBNdata.depth = Cdata(:,41);
RBNdata.temperature = Cdata(:,42);
RBNdata.estMeanDiameter = Cdata(:,50);
RBNdata.estTotalConc = Cdata(:,51);
RBNdata.Lp = Cdata(:,37);
RBNdata.Lref = Cdata(:,40);
RBNdata.analog1 = Cdata(:,39);
RBNdata.analog2 = Cdata(:,49);
RBNdata.supplyVolts = Cdata(:,38);
RBNdata.humidity = Cdata(:,52);
RBNdata.accelXYZ = Cdata(:,53:55);
RBNdata.raw = rawData;
RBNdata.factory_bkgrd = fzs;
RBNdata.bkgrd = zsc;
RBNdata.ambientLight = Cdata(:,58);
RBNdata.config = config;
RBNdata.dcal = dcal;
RBNdata.Ta = Ta;
RBNdata.Tv = Tv;
end

function [zsc,fzs,dcal,data,Tv,Ta,config,housek] = parse200XBinary(datafile)

[zsc,fzs,dcal,data,Tv,Ta,config,housek] = deal([]);
RecordSize = 120; % 120 bytes per record

% record IDs
DCAL_RECORD_ID = 44778;
TV1_RECORD_ID = 49391;    
TV2_RECORD_ID = 49394;    
TA1_RECORD_ID = 44047;    
TA2_RECORD_ID = 44274;    
ZSCAT_RECORD_ID = 47820;
FZSCAT_RECORD_ID = 64428;
CONFIG_RECORD_ID = 19529;
HOUSEK_RECORD_ID = 52928;
DATA_RECORD_ID = 56026;

fid = fopen(datafile,'r','b'); %open file for reading using big endian format
recordID = fread(fid,1,'uint16'); % read the first record ID

% setup variables
num16 = (RecordSize/2)-1;
num32 = floor((RecordSize-2)/4);
recordNUM = 0;

% loop through the file and read in the data according to the record ID
while (~isempty(recordID))
    recordNUM = recordNUM + 1;
    switch recordID
        case ZSCAT_RECORD_ID
            zsc = fread(fid,num16,'uint16')';
        case DATA_RECORD_ID
            data = [data; fread(fid,num16,'uint16')'];
        case DCAL_RECORD_ID
            dcal = fread(fid,num16,'uint16')';
            dcal = dcal(2:37)./dcal(1);
        case FZSCAT_RECORD_ID
            fzs = fread(fid,num16,'uint16')';
        case CONFIG_RECORD_ID
            fseek(fid,-2,'cof');
            config.name = fread(fid,20,'*char')';
            config.serialNumber = fread(fid,1,'uint16');
            config.firmwareVer = fread(fid,1,'uint16').*0.001;
            config.VCC = fread(fid,1,'uint32');
            config.fullPath = fread(fid,1,'uint16').*0.01;
            config.effPath = fread(fid,1,'uint16').*0.01;
            config.bioBlock = fread(fid,1,'uint8');
            config.sTube = fread(fid,1,'uint8');
            config.analogConcScale = fread(fid,1,'uint16');
            config.endcap = fread(fid,1,'uint16');
            config.startCond = fread(fid,1,'uint16');
            config.startCondData = fread(fid,20,'*char')';
            config.stopCond = fread(fid,1,'uint16');
            config.stopCondData = fread(fid,20,'*char')';
            config.measurementAve = fread(fid,1,'uint16');
            config.sampleInterval = fread(fid,1,'uint16');
            config.sampleMode = fread(fid,1,'uint16');
            config.burstSamples = fread(fid,1,'uint16');
            config.burstInterval = fread(fid,1,'uint16');
            config.transmitRaw = fread(fid,1,'uint16');
            config.lifetimeSamples = fread(fid,1,'uint32');
            config.lifetimeLaserOn = fread(fid,1,'uint32');
            config.supportBoard = fread(fid,1,'uint16');
            config.ambientLight = fread(fid,1,'uint16');
        case HOUSEK_RECORD_ID
            housek=fread(fid,num32,'float')';
        case TV1_RECORD_ID
            Tv(1:num32)=fread(fid,num32,'float')';
        case TV2_RECORD_ID
            Tv(30:36)=fread(fid,7,'float')';
        case TA1_RECORD_ID
            Ta(1:num32)=fread(fid,num32,'float')';
        case TA2_RECORD_ID
            Ta(30:36)=fread(fid,7,'float')';
    end
    fseek(fid,recordNUM * RecordSize,'bof'); % go the location of the next record ID
    recordID = fread(fid,1,'uint16');        % read the next record ID
end
fclose(fid);

% negative ring values are possible, data must be corrected
data(data>40950) = data(data>40950) - 65536;
fzs(fzs>40950) = fzs(fzs>40950) - 65536;
zsc(zsc>40950) = zsc(zsc>40950) - 65536;
end

% LOG
% 04/11/14 read LISST-200X files
% 09/30/14 read zscat, factory zscat and ring areas from
%     200X files. Divides zscat and factory by 10, same as data.
% 10/28/15 include fzs in computing cscat
% 03/17/16 added config record ID and fixed parsing of VCC value
% 07/07/16 use DCAL values stored in file.
%     [vd,dias36,dcal,scat,tau,zsc,data,cscat,fzs] = getscat_L200X('datafile');
% 02/03/16 Major overhaul. Changed how data is read in (no more
%     tt2mat), vectorized cscat computation, corrected auxiliary parameters
% 04/12/17 Added correction at the end of 'parse200XBinary', 
%     allowing for negative ring values. Changed 'config' from a cell array
%     to a structure.