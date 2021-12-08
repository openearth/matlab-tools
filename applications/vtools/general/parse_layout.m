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

addOptional(parin,'sedTrans',0,@isnumeric);

parse(parin,varargin{:});

sedTrans=parin.Results.sedTrans;

%%

OPT.ask=1;
OPT=setproperty(OPT,varargin);