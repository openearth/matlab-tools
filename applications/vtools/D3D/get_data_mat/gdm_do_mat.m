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

function ret=gdm_do_mat(fid_log,flg_loc,tag,varargin)

%% PARSE

if isfield(flg_loc,'do')==0
    flg_loc.do=1;
end

if isfield(flg_loc,'do_p')==0
    flg_loc.do_p=1;
end

if numel(varargin)>0
    if isfield(flg_loc,varargin{1,1})
        flg_loc.do=[flg_loc.do,flg_loc.(varargin{1,1})];
    end
end

%% CALC

ret=0;

if ~all(flg_loc.do)
    messageOut(fid_log,sprintf('Not doing ''%s''',tag));
    ret=1;
    return
end
messageOut(fid_log,sprintf('Start ''%s''',tag));

end %function