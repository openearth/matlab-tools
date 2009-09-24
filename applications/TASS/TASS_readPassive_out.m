function [data] = TASS_readPassive_out(varargin)
% TASS_READPASSIVE_OUT  Routine to read the passive plume output file
%
% Input
%
%
% See also

%% defaults
OPT = struct( ...
    'filename', 'd:\Documents and Settings\mrv\VanOord\Projecten\96.8015 TASS P15 Slibpluimmeting\Software\ExampleData\passive.out' ...
    );

%% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

if isempty(OPT.filename)
    disp('Error: Input file needed')
    return
end

disp(['Processing: ' OPT.filename])
tic

%% read some basic info from the logfile header
fid = fopen(OPT.filename);
for i = 1:22
    fgetl(fid);
end
data = fscanf(fid,'%f %f %f %f %f %f',[6 inf]);
data = data';