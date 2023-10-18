%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Plot rkm file

function plot_rkm(path_rkm,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'headerlines',1,@isnumeric);
addOptional(parin,'delimiter',',');
addOptional(parin,'readString','%f %f %s %f');
addOptional(parin,'XCol',1);
addOptional(parin,'YCol',2);
addOptional(parin,'branchCol',3);
addOptional(parin,'rkmCol',4);

parse(parin,varargin{:});

headerlines=parin.Results.headerlines;
delimiter=parin.Results.delimiter;
readString=parin.Results.readString;
XCol=parin.Results.XCol;
YCol=parin.Results.YCol;
% rkmCol=parin.Results.rkmCol;
branchCol=parin.Results.branchCol;

%%

fid=fopen(path_rkm,'r');
rkm_file=textscan(fid,readString,'headerlines',headerlines,'delimiter',delimiter);
fclose(fid);

%% PLOT

figure 
hold on
scatter(rkm_file{1,XCol},rkm_file{1,YCol},10,'r','o','filled')
nt=numel(rkm_file{1,XCol});
for kt=1:nt
text(rkm_file{1,XCol}(kt),rkm_file{1,YCol}(kt),strrep(rkm_file{1,branchCol}(kt),'_','\_'))
end %kt
axis equal

end %function