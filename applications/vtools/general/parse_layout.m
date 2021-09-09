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

%function out=f(varargin)

parin=inputParser;
input.sedTrans.default=[8,1.5,0.047];
addOptional(parin,'sedTrans',input.sedTrans.default,@isnumeric);
parse(parin,varargin{:});
a_mpm=parin.Results.sedTrans(1);
b_mpm=parin.Results.sedTrans(2);
theta_c=parin.Results.sedTrans(3);

%%

OPT.ask=1;
OPT=setproperty(OPT,varargin);