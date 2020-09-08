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
%Converts chainage to river kilometers. Given the x-y coordinates a location
%it gives the river-kilometer of this location. 
%
%Input:
%   -path_rkm: path to the file with x, y, and river kilometers. Default file has 1 headerlines, delimiter by ',', and the input is x-coordinate, y-coordinate, string-not-used, rkm
%	-cord_br: coordinates of the chainage; [number of points,2]; column 1 = x; column 2 = y 
%
%Output:
%	-rkm_br: river kilometer [number of points,1]
%
%e.g.
%rkm_br=convert2rkm('C:\Users\rkm.csv',cord_br);
%rkm_br=convert2rkm('C:\Users\rkm.csv',cord_br,'delimiter',',');

function varargout=convert2rkm(path_rkm,cord_br,varargin)

%input
parin=inputParser;

addOptional(parin,'TolMinDist',500,@isnumeric);
addOptional(parin,'headerlines',1,@isnumeric);
addOptional(parin,'delimiter',',');
addOptional(parin,'readString','%f %f %s %f');
addOptional(parin,'XCol',1);
addOptional(parin,'YCol',2);
addOptional(parin,'rkmCol',4);

parse(parin,varargin{:});

TolMinDist=parin.Results.TolMinDist;
headerlines=parin.Results.headerlines;
delimiter=parin.Results.delimiter;
readString=parin.Results.readString;
XCol=parin.Results.XCol;
YCol=parin.Results.YCol;
rkmCol=parin.Results.rkmCol;

%read file
fid=fopen(path_rkm,'r');
rkm=textscan(fid,readString,'headerlines',headerlines,'delimiter',delimiter);
fclose(fid);

%loop on points
np=size(cord_br,1);

rkm_br=NaN(np,1);
for kp=1:np
    %search for closest point
    dist=sqrt((rkm{1,XCol}-cord_br(kp,1)).^2+(rkm{1,YCol}-cord_br(kp,2)).^2);
    [min_dist,min_idx]=min(abs(dist));
    rkm_br(kp)=rkm{1,rkmCol}(min_idx);
    
    if min_dist>TolMinDist
        figure 
        hold on
        scatter(rkm{1,XCol},rkm{1,YCol},10,'r','o','filled')
        scatter(cord_br(kp,1),cord_br(kp,2),50,'b','s','filled')
        axis equal
        
        error('The distance between point and the associated rkm is larger than %f m',TolMinDist)
    end

end %kp

%output
varargout{1}=rkm_br;
