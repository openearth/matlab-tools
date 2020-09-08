%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%slope2elevation computes the bed elevation given the slope

%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.

function etab=slope2elevation(slopeb,etab0,input,fid_log)
%comment out fot improved performance if the version is clear from github
% version='1';
% fprintf(fid_log,'slope2elevation version: %s\n',version);

%%

etab=NaN(1,input.mdv.nx);
etab(end)=etab0+slopeb(end)*input.grd.dx/2;
for kx=input.mdv.nx-1:-1:1
    etab(kx)=etab(kx+1)+slopeb(kx)*input.grd.dx;
end