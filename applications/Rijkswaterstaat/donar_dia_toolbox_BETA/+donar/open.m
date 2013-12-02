function File = open(diafile,varargin)
%open  opens a donar file by scanning all internal blocks + detecting variables
%
% File = open (diafile) opens a file and returns contents
% in structure File, where field Blocks contains meta-data per 
% internal block, and field Variables contains an analysis
% into unique variables. 300 Mb files into 4000 blocks
% can take up to 10 min to scan.
%
% Example:
% 
% File = dona.ropen(diafile)
% Data = donar.read(File,variable_index)
%
%See also: 

OPT.disp = 100;

OPT = setproperty(OPT,varargin);

cache = strrep(diafile,'.dia','_info.mat');
if exist(cache)
   File        = load(cache);
else
   File.Blocks = donar.scan_file(diafile);
end

File.Filename = diafile;

% donar.scan_file
File.Variables = donar.merge_headers(File.Blocks);

if OPT.disp > 0
   disp([mfilename,' # of blocks = ',num2str(length(File.Blocks))])
   disp([mfilename,' # of values = ',num2str(sum([File.Blocks.nval]))])  
   disp([mfilename,' # of parameters = ',num2str(length(File.Variables))])  
end
