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

function print_fig=check_print_figure(in_p)

fname=in_p.fname;
fig_print=in_p.fig_print; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
fig_overwrite=in_p.fig_overwrite; 
fid_log=in_p.fid_log;

next=numel(fig_print);
print_fig=0;

if ~fig_overwrite
    for kext=1:next
        switch fig_print(kext)
            case 0
                print_fig=1;
            case 1
                ext='.png';
            case 2
                ext='.fig';
            case 3
                ext='.eps';
            case 4
                ext='.jpg';
        end                
        fpath_fig_ext=sprintf('%s%s',fname,ext);
        if exist(fpath_fig_ext,'file')~=2
            print_fig=1;
        end
        if print_fig==0
            messageOut(fid_log,sprintf('Figure already exists: %s',fpath_fig_ext));
        end
    end   
else
    print_fig=1;
end

end