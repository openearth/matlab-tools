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
%removes the points which are identical in a polyline

function [x_out,y_out,idx_get]=unique_polyline(xv,yv,varargin)

%% PARSE
parin=inputParser;
addOptional(parin,'tol',1e-10);
parse(parin,varargin{:})
tol=parin.Results.tol;

%% CALC

Pv= [xv(:) yv(:)];

% coordinates of consecutive vertices
P1=Pv(1:(end-1),:);
P2=Pv(2:end,:);
dv=P2-P1;

% vector of distances between each pair of consecutive vertices
vds=hypot(dv(:,1),dv(:,2));
bol_get=vds>tol;
idx_get=find(bol_get);

x_out=xv(bol_get);
y_out=yv(bol_get);

end %function
