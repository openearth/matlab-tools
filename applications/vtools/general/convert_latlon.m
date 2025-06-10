%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 4 $
%$Date: 2023-10-17 07:19:37 +0200 (Tue, 17 Oct 2023) $
%$Author: chavarri $
%$Id: input_D3D_Run3.m 4 2023-10-17 05:19:37Z chavarri $
%$HeadURL: file:///P:/dflowfm/users/chavarri/231005_redolfi/07_scripts/svn/input_D3D_Run3.m $
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
