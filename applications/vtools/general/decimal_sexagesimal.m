%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 31 $
%$Date: 2022-04-08 15:56:29 +0200 (Fri, 08 Apr 2022) $
%$Author: chavarri $
%$Id: main_bring_data_back.m 31 2022-04-08 13:56:29Z chavarri $
%$HeadURL: file:///P:/11208075-002-ijsselmeer/07_scripts/svn/main_bring_data_back.m $
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