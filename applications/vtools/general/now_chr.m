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
%String of now

function nowchr=now_chr(varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'random',0)
% addOptional(parin,'long',0)

parse(parin,varargin{:})

radd=parin.Results.random;
% lstr=parin.Results.long;

if radd
    rng('shuffle')
    r=rand(1);
else 
    r=0;
end

nw=sprintf('%15.10f',datenum(datetime('now'))+r);
nowchr=strrep(nw,'.','_');

end %function