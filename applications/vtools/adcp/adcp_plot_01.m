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

function adcp_plot_01(fdir_mat,fdir_fig)

%%

[dire1,~,dire3]=dirwalk(fdir_mat);
nd=numel(dire3);

%start from beginning
order_anl=1:1:nd;

%% loop

for kd=order_anl
    fname=dire3{kd,1};
    if ~isempty(fname)
        nf=numel(fname);
        for kf=1:nf
            fnameext=dire3{kd,1}{kf,1};
            ffolder=dire1{kd,1};
            ffullname=fullfile(ffolder,fnameext);
            [~,fnameonly,fext]=fileparts(ffullname);

            ffolder_out_fig=strrep(ffolder,fdir_mat,fdir_fig);
            mkdir_check(ffolder_out_fig)
            
            if strcmp(fext,'.mat')
                load(ffullname);
                data_block_processed=adcp_get_data_block(data_block);

                %%
                fnameprint=fullfile(ffolder_out_fig,sprintf('%s_vmag',fnameonly));

                in_p.fname=fnameprint;
                in_p.fig_print=[1,4]; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
                in_p.fig_visible=0;
                in_p.fig_size=[0,0,14,8];
                in_p.data_block_processed=data_block_processed;
                in_p.val='vmag';
                in_p.lan='es';

                fig_adcp_1_v(in_p)
            end
            
        end %kf
    end %isempty(fname)
end %kd