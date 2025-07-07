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
%Convert latitude (and longitude) from sexagesimal to decimal.

function out=convert_latlon(varargin)

if nargin==3
    deg=varargin{1};
    min=varargin{2};
    sec=varargin{3};

    out=deg+min/60+sec/3600;
else
    error('Implement')
end


end %function
