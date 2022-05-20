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
%This function returns 1 if the input filename is a script and 0 if it is a function

function iss=isscript(filename)

[folder_n,file_n]=fileparts(filename);

iss=0; %it is a script
try
    inputs=nargin(file_n);
catch exception
    iss=1;
end