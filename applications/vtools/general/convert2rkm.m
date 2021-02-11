%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: convert2rkm.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/convert2rkm.m $
%
%Given the x-y coordinates of a location it gives the 
%river-kilometer (rkm) of this location and viceversa.
%
%Input:
%   -path_rkm: path to the file with x, y, and river kilometers. Default file has 1 headerlines, delimiter by ',', and the input is x-coordinate, y-coordinate, river-branch, rkm
%       For x-y to rkm
%	-input 2: coordinates of the points; double(number of points,2); column 1 = x; column 2 = y 
%       For rkm to x-y
%   -input 2: rkm of the points; double(number of points,1)
%   -input 3: branch of the points; cell(number of points,1)
%       accepted branch names (capitals are not considered):
%           -Rhein: rhein
%           -Waal: wa
%           -Pannerdensch Kanaal: pk
%           -Nederrijn: nr
%           -Lek: lek, le
%           -IJssel: ij
%
%Optional:
%	-'TolMinDist'
%	-'headerlines'
%	-'delimiter'
%	-'readString'
%	-'XCol'
%	-'YCol'
%	-'branchCol'
%	-'rkmCol'
%
%Output:
%       For x-y to rkm
%	-output 1: river kilometer; double(number of points,1)
%       For rkm to x-y
%   -output 1: x-y coordinates; double(number of points,2)
%
%e.g.
%rkm_br=convert2rkm('C:\Users\rkm.csv',cord_br);
%rkm_br=convert2rkm('C:\Users\rkm.csv',cord_br,'delimiter',',');
%xy=convert2rkm('C:\Users\rkm.csv',[985,750],{'lek','Rhein'});

function varargout=convert2rkm(path_rkm,varargin)

%% PARSE

ni=numel(varargin);
%if no input it is wrong
if ni==0
    error('Not enough input.');
end
%number of input is multiple of 2
if mod(ni,2)==0 %convert from rkm to xy
    rkm2xy=true;
    var_in=varargin{1}; %rkm
    branch_in=varargin{2};
    idx_varargin=3;
    
    if ~iscell(branch_in)
        error('The branch of the rkm should be a cell array.');
    end
    branch_in=deblank(lower(branch_in));
    idx_change=cell2mat(cellfun(@(X)strcmp(X,'lek'),branch_in,'UniformOutput',false));
    branch_in(idx_change)={'le'};
    %add others!
    
else
    rkm2xy=false;
    var_in=varargin{1}; %xy
    idx_varargin=2;
    
    if size(var_in,2)~=2
        error('In the columns of the input coordinates there should be x and y (i.e., 2 columns are expected).');
    end
end

%parser
parin=inputParser;

addOptional(parin,'TolMinDist',500,@isnumeric);
addOptional(parin,'headerlines',1,@isnumeric);
addOptional(parin,'delimiter',',');
addOptional(parin,'readString','%f %f %s %f');
addOptional(parin,'XCol',1);
addOptional(parin,'YCol',2);
addOptional(parin,'branchCol',3);
addOptional(parin,'rkmCol',4);

parse(parin,varargin{idx_varargin:end});

TolMinDist=parin.Results.TolMinDist;
headerlines=parin.Results.headerlines;
delimiter=parin.Results.delimiter;
readString=parin.Results.readString;
XCol=parin.Results.XCol;
YCol=parin.Results.YCol;
branchCol=parin.Results.branchCol;
rkmCol=parin.Results.rkmCol;

%% READ FILE

fid=fopen(path_rkm,'r');
rkm_file=textscan(fid,readString,'headerlines',headerlines,'delimiter',delimiter);
fclose(fid);

nvc=numel(rkm_file{1,XCol});

if rkm2xy
    var_compare=rkm_file{1,rkmCol};
    var_out=[rkm_file{1,XCol},rkm_file{1,YCol}];

    %branch
    tok=cellfun(@(X)regexp(X,'_','split'),rkm_file{1,branchCol},'UniformOutput',false); %e.g. 850.0_Rhein 
    tok=cellfun(@(X)X{1,2},tok,'UniformOutput',false);
    branch=cellfun(@(X)deblank(lower(X)),tok,'UniformOutput',false);
    
else
    var_compare=[rkm_file{1,XCol},rkm_file{1,YCol}];
    var_out=rkm_file{1,rkmCol};
    
    bol_branch=true(nvc,1);
end

%loop on points
np=size(var_in,1);
var_get=NaN(np,size(var_out,2));

for kp=1:np
    if rkm2xy
        %get branch
        bol_branch=strcmp(branch,branch_in{kp});
    end
    var_out_branch=var_out(bol_branch,:);

    %search for closest point
    dist=sqrt(sum((var_compare(bol_branch,:)-var_in(kp,:)).^2,2));
    [min_dist,min_idx]=min(dist);
    var_get(kp,:)=var_out_branch(min_idx,:);

    if min_dist>TolMinDist
        figure 
        hold on
        scatter(rkm_file{1,XCol},rkm_file{1,YCol},10,'r','o','filled')
        if rkm2xy
            
        else
            scatter(var_in(kp,1),var_in(kp,2),50,'b','s','filled')
        end
        axis equal

        error('The distance between point and the associated rkm is larger than %f m',TolMinDist)
    end

end %kp

%% OUTPUT

varargout{1}=var_get;

