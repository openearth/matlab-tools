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

function varargout=decimal_sexagesimal(varargin)

if nargin==1 %from decimal to sexagesimal
    do_decsexa=1;
else
    do_decsexa=2;
end

if do_decsexa==1
    deg_f=varargin{1,1};
    deg=floor(deg_f);
    min_f=(deg_f-deg)*60;
    min=floor(min_f);
    sec=(min_f-min)*60;
    varargout{1,1}=deg;
    varargout{1,2}=min;
    varargout{1,3}=sec;
elseif do_decsexa==2
    varargout{1,1}=varargin{1,1}+varargin{1,2}./60+varargin{1,3}/3600;
else
    error('?')
end

end %function