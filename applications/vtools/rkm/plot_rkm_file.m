%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19197 $
%$Date: 2023-10-18 06:59:30 +0200 (Wed, 18 Oct 2023) $
%$Author: chavarri $
%$Id: plot_rkm.m 19197 2023-10-18 04:59:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rkm/plot_rkm.m $
%
%Plot rkm file

function plot_rkm_file(path_rkm,varargin)

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