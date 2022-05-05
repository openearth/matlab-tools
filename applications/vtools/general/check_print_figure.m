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

function do_fig=check_print_figure(in_p)

fname=in_p.fname;
fig_print=in_p.fig_print; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
fig_overwrite=in_p.fig_overwrite; 
fid_log=in_p.fid_log;

if numel(fig_print)>1 && any(fig_print==0)
    error('you cannot ask for not printing and printing')
end

if any(fig_print==0) %it can actually be only only in position 1, see above
    do_fig=1;
    return
end

next=numel(fig_print);
do_fig=0;

if ~fig_overwrite
    for kext=1:next
        fext=ext_of_fig(fig_print(kext));              
        fpath_fig_ext=sprintf('%s%s',fname,fext);
        if exist(fpath_fig_ext,'file')~=2
            do_fig=1;
            return
        end
        if do_fig==0
            messageOut(fid_log,sprintf('Figure already exists: %s',fpath_fig_ext));
        end
    end   
else
    do_fig=1;
end

end