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
%

function [idx,min_v]=absmintol(v,o,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tol',1e-1);
addOptional(parin,'fid_log',NaN);
addOptional(parin,'do_break',1);
addOptional(parin,'dnum',0);

parse(parin,varargin{:});

tol=parin.Results.tol;
fid_log=parin.Results.fid_log;
do_break=parin.Results.do_break;
is_dnum=parin.Results.dnum;

%% CALC

[min_v,idx]=min(abs(v-o));
if min_v>tol
    if is_dnum
        messageOut(fid_log,sprintf('Desired value %s is beyond tolerance %f days',datestr(o,'yyyy-mm-dd HH:MM:SS'),tol));
        messageOut(fid_log,'Possible values, difference with objective [days]:');
    else
        messageOut(fid_log,sprintf('Desired value %f is beyond tolerance %f',o,tol));
        messageOut(fid_log,'Possible values, difference with objective:');
    end
    
    n=numel(v);
    for k=1:n
        if is_dnum
            messageOut(fid_log,sprintf('%s %f \n',datestr(v(k),'yyyy-mm-dd HH:MM:SS'),v(k)-o));
        else
            messageOut(fid_log,sprintf('%f %f \n',v(k),v(k)-o));
        end
    end
    if do_break
        error('See above')
    end
end
