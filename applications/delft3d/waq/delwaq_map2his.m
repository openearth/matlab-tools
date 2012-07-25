function structOut = delwaq_map2his_w(FileName,File2Save,SegmentNr,SegmentNames,SubstanceNames,TimeIndex)
%DELWAQ_MAP2HIS Read Delwaq MAP file a write a Delwaq HIS file.
%
%   STRUCTOUT = DELWAQ_MAP2HIS(FILENAME,SEGEMENTNR,SEGMENTNAMES,FILE2SAVE)
%   Reads FILENAME and creates the His file FILE2SAVE, SEGEMENTNR and
%   SEGMENTNAMES.
%   If FILE2SAVE is not provided then FILE2SAVE = FILENAME.HIS
%
%   STRUCTOUT = DELWAQ_MAP2HIS(...,SUBSTANCENAMES)
%   Create the HIS file only for substances specified in SUBSTANCENAMES
%
%   See also: DELWAQ, DELWAQ_XY2SEGNR, DELWAQ_RES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com

if nargin<5
   SubstanceNames = 0;
end
if nargin<6
   TimeIndex = 0;
end

if nargin<4
   [path1, name1] = fileparts(FileName);
   File2Save = [path1 '\' name1 '.his'];
end

inot = isnan(SegmentNr);
SegmentNr = SegmentNr(~inot);
SegmentNames = {SegmentNames{~inot}}; %#ok<CCAT1>


% Opening Files
struct1 = delwaq('open',FileName);

% Matching SubsName
[SubstanceNames isub] = match_names(struct1.SubsName,SubstanceNames);

if isempty(isub)
   disp('There is any match in the substance name');
   return 
end


% Header
Header = struct1.Header;

% Setting time reference
T0 = struct1.T0;
refTime =  [T0 1];
if TimeIndex == 0 
   itime = 1:struct1.NTimes;
else
   itime = struct1.NTimes;
end

% Matching Subs
if isempty(isub)
   disp('There is no match in the substance');
   return 
end

nsub = length(isub);
nseg = length(SegmentNr);
data = nan(nsub,nseg,length(itime));

% Read data
for iseg = 1:nseg
    [time data1] = delwaq('read',struct1,isub,iseg,itime);
    data(:,iseg,:) = data1;    
end

% Writing a File
structOut = delwaq('write',File2Save,Header,SubstanceNames,SegmentNames,refTime,time,data);


%--------------------------------------------------------------------------
% Match names
%--------------------------------------------------------------------------
function [names iname1 iname2] = match_names(name1,name2)

iname1 = [];
iname2 = [];
names  = [];
name1 = lower(name1);
name2 = lower(name2);

if ischar(name2)
   name2 = cellstr(name2);
elseif isnumeric(name2);
    if length(name2)==1 && name2==0
       name2 = 1:length(name1);
    end
    name2 = name1(name2);
end

k = 0;
for i = 1:length(name2)
    isub1 = find(strcmpi(name1,name2{i}));
    if ~isempty(isub1)
       k = k+1;
       iname1(k) = isub1; %#ok<*AGROW>
       iname2(k) = i;
       names{k} = name2{i};
    end
end
