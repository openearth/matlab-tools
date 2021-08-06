%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17376 $
%$Date: 2021-07-02 16:00:24 +0200 (Fri, 02 Jul 2021) $
%$Author: chavarri $
%$Id: D3D_write_tim.m 17376 2021-07-02 14:00:24Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_write_tim.m $
%
%write a tim file based on information in structure

function D3D_write_tim_2(data_loc,path_dir_out,fname_tim_v,ref_date)

%make varargin
fig_print=1;
tim_u='minutes';

nloc=numel(data_loc);
for kloc=1:nloc
    path_tim=fullfile(path_dir_out,sprintf('%s.tim',fname_tim_v{kloc}));
    fid=fopen(path_tim,'w');
    nq=numel(data_loc(kloc).quantity);
    fprintf(fid,'* Column 1: Time (%s) w.r.t. refdate=%s \n',tim_u,datestr(ref_date,'yyyy-mm-dd HH:MM:ss'));
    for kq=2:nq
        fprintf(fid,'* Column 2: %s \n',data_loc(kloc).quantity{kq});
    end
    nl=numel(data_loc(kloc).tim);
    tim_loc=data_loc(kloc).tim-ref_date;
    switch tim_u
        case 'seconds'
            tim_ref=seconds(tim_loc);
        case 'minutes'
            tim_ref=minutes(tim_loc);
        otherwise
            error('to do')
    end
    str_write=repmat('%f ',1,nq);
    str_write_2=strcat(str_write,'\n');
    for kl=1:nl
        fprintf(fid,str_write_2,tim_ref(kl),data_loc(kloc).val(kl,:));
    end %kl
    fclose(fid);
    
    %plot
    if fig_print
        for kq=2:nq
            path_fig=fullfile(path_dir_out,sprintf('%s_%s.png',fname_tim_v{kloc},data_loc(kloc).quantity{kq}));
            figure('visible',0)
            plot(data_loc(kloc).tim,data_loc(kloc).val(:,kq-1))
            ylabel(strrep(data_loc(kloc).quantity(kq),'_','\_'))
            title(strrep(fname_tim_v{kloc},'_','\_'))
            print(gcf,path_fig,'-dpng','-r300')
        end
    end
    
    %disp
    messageOut(NaN,sprintf('file written: %s',path_tim))
end %kloc