%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17077 $
%$Date: 2021-02-19 06:31:11 +0100 (Fri, 19 Feb 2021) $
%$Author: chavarri $
%$Id: messageOut.m 17077 2021-02-19 05:31:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/messageOut.m $
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
