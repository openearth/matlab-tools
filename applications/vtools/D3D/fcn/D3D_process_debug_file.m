%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18680 $
%$Date: 2023-01-30 13:29:13 +0100 (Mon, 30 Jan 2023) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18680 2023-01-30 12:29:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Processes and plots a debug file with D3D variables written from source. 
%
%The writing statement in Fortran must be e.g.:
%```
% write(42,"(A)") 'update_constituents-end'                             !name of the location where file is written
% write(42,"(E19.12E2)") time1                                          !time 
% write(42,"(A)") 'xz, yz, sinksetot, dts_store '                       !variables written to file
% write(42,"(A)") 'ndx, lsed'                                           !variables over which it is looped (e.g., space and sediment fraction)
% write(42,"(I6.6,X,I6.6,X,I6.6,X,I6.6)") 10600, 10800, ISED1, ISEDN    !limits of the variables over which it is looped.
% do nm=10600,10800                                                     !loop 1
%     do j=ISED1,ISEDN                                                  !loop 2 
%         write(42,"(X,E15.8E2,X,E15.8E2,X,E15.8E2,X,E15.8E2)") xz(nm), yz(nm), sinksetot(j,nm), dts_store
%     enddo
% enddo
%```
%
%Important (can be generalized):
%   -The character length must be 16 (1 space plus 15 for number).
%   -x and y must be in first and second column, respectively.
%   -Maximum there can be 3 loops for writing (spatial and two indices such as `lsed`).
%   -The loop on space must be identified with `ndx` or `ndxi`. 
%
%E.G. Read and plot per parts
%
% %% read
% fpath_db='p:\dflowfm\projects\230128_issue_11200\02_runs\r009\fort.42';
% data=D3D_process_debug_file(fpath_db,'do','read');
% 
% %% filter
% data_fil=struct('nam','','time1',[],'vars','','loop_vars','','data',[]);
% 
% % var_name_search='vol1';
% var_name_search='constituents';
% 
% idx_var=cellfun(@(X)find(contains(X,var_name_search)),{data.vars},'UniformOutput',false);
% ne=numel(data);
% kc=0;
% for ke=1:ne
%     if isempty(idx_var{ke}); continue; end
%     kc=kc+1;
%     data_fil(kc).nam=data(ke).nam;
%     data_fil(kc).time1=data(ke).time1;
%     data_fil(kc).vars=data(ke).vars([1,2,idx_var{1}]);
%     data_fil(kc).loop_vars=data(ke).loop_vars;
%     data_fil(kc).data=data(ke).data(:,:,:,[1,2,idx_var{1}]); %[x,y,var]
% end %ke
% 
% %% plot
% D3D_process_debug_file(fpath_db,'do','plot','data',data_fil,'clims',[0,1]*1e-4);

function data=D3D_process_debug_file(fpath_db,varargin)

%% PARSE

parin=inputParser;

data_block_empty=struct('nam','','time1',[],'vars','','loop_vars','','data',[]);

addOptional(parin,'do','all');
addOptional(parin,'data',data_block_empty);
addOptional(parin,'clims',[NaN,NaN]);

parse(parin,varargin{:});

what_do=parin.Results.do;
data=parin.Results.data;
clims=parin.Results.clims;

%%

switch what_do
    case 'all'
        what_read=1;
        what_plot=1;
    case 'read'    
        what_read=1;
        what_plot=0;
    case 'plot'
        what_read=0;
        what_plot=1;
        
        if isempty(fieldnames(data))
            error('Provide data for plotting');
        end
        
    otherwise
        error('I do not know what do you want to do')
end

%%

fig_visible=false;
% fig_visible=true;

% in_p.fig_visible=fig_visible;

%% READ

if what_read
    
fid=fopen(fpath_db,'r');
kb=0;
while ~feof(fid)

%block starts
kb=kb+1;
data(kb)=D3D_read_debug_block(fid);

messageOut(NaN,sprintf('Reading block %4d',kb));
end %feof

end

%% PLOT

if what_plot
    
nclim=size(clims,1);
    
%% open figure
xp=1;
yp=1;
vp=1;
var_str='';
loop_var_str_1='';
loop_var_str_2='';
kloopvar_1=1;
kloopvar_2=1;
nam='';
tim=1;
cbar_str=sprintf('%s, %s=%d, %s=%d',strrep(var_str,'_','\_'),loop_var_str_1,kloopvar_1,loop_var_str_2,kloopvar_2);
tit_str={sprintf('time1=%f',tim),strrep(nam,'_','\_')};

han.fig=figure('visible',fig_visible);
han.s=scatter(xp,yp,10,vp,'filled');
han.sfig=han.fig.CurrentAxes;
hold(han.sfig,'on')
han.s0=scatter(xp,yp,10,'r','x');
han.cbar=colorbar;
han.cbar.Label.String=cbar_str;
han.tit=title(tit_str);

%% loop
messageOut(NaN,'Start plotting');
nb=numel(data);
for kb=1:nb

    col_x=1; %can be searched in data_block
    col_y=2; %can be searched in data_block

    tim=data(kb).time1;
    nam=data(kb).nam;
    tit_str={sprintf('time1=%f',tim),strrep(nam,'_','\_')};
    han.tit.String=tit_str;

    %search for spatial index
    idx_ndx=find_str_in_cell(data(kb).loop_vars,{'ndxi','ndx'});
    if isnan(idx_ndx)
        error('Cannot find spatial variable')
    end
    
    %search for dimensions to loop
    ntot=size(data(kb).data); %the first three ones are spatial and the two loops, but we do not know in which location is spatial
    if numel(ntot)~=4
        error('Dimensions do not match expectations')
    end
    
    nloop=ntot(1:3);
    nloop(idx_ndx)=[];
    nvar=ntot(4)-2; %x and y are the first 2
    
    idx_loop=1:3;
    idx_loop(idx_ndx)=[];
    
    if nloop(1)~=1
        loop_var_str_1=data(kb).loop_vars{idx_loop(1)};
    else
        loop_var_str_1='';
    end

    if nloop(2)~=1
        loop_var_str_2=data(kb).loop_vars{idx_loop(2)};
    else
        loop_var_str_2='';
    end

    %loop on non-spatial indices
    for kloopvar_1=1:nloop(1) 
        val_1=submatrix(data(kb).data,idx_loop(1),kloopvar_1);
        for kloopvar_2=1:nloop(2)
            val_2=submatrix(val_1,idx_loop(2),kloopvar_2);

            xp=val_2(:,:,:,col_x);
            xp=squeeze(xp);

            yp=val_2(:,:,:,col_y);
            yp=squeeze(yp);

            han.s.XData=xp;
            han.s.YData=yp;

            for kv=1:nvar %variable written
                col_v=2+kv; %x,y and then variables
                
                var_str=data(kb).vars{col_v};
                cbar_str=sprintf('%s, %s=%d, %s=%d',strrep(var_str,'_','\_'),loop_var_str_1,kloopvar_1,loop_var_str_2,kloopvar_2);

                vp=val_2(:,:,:,col_v);
                vp=squeeze(vp);
                
                %Modify an open figure
                han.s.CData=vp;
%                 if any(vp<0)
%                     a=1;
%                 end
%                 han.s.CData=log10(vp);
%                 han.s.CData=sign(vp);
                
                bol0=vp==0;
                han.s0.XData=xp;
                han.s0.YData=yp;
                han.s0.XData(~bol0)=NaN;
                han.s0.YData(~bol0)=NaN;
                
                han.cbar.Label.String=cbar_str;
                
                for kclim=1:nclim
                    if isnan(clims(kclim,1))
                        tol=1e-12;
                        clims_loc=[min(vp)-tol,max(vp)+tol];
                    else
                        clims_loc=clims(kclim,:);
                    end
                    han.cbar.Limits=clims_loc;
                    han.sfig.CLim=clims_loc;
                    fpath_fig=sprintf('%s_%s_%d_%s_%d_%s_%f_%03d_clim_%02d.png',nam,loop_var_str_1,kloopvar_1,loop_var_str_2,kloopvar_2,var_str,tim,kb,kclim);
                    print(han.fig,fpath_fig,'-dpng','-r150');
                end
                
                %A figure each time. It is time consuming
%                 in_p.xp=xp;
%                 in_p.yp=yp;
%                 in_p.vp=vp;
%                 in_p.var_str=var_str;
%                 in_p.loop_var_str=loop_var_str;
%                 in_p.tim=tim;
%                 in_p.nam=nam;
%                 in_p.idx_loop_var_str=kd;

%                 figure_db(in_p);
        
            end %kv
        end %kloopvar_2
    end %kloopvar_1
    messageOut(NaN,sprintf('Figures printed %4.2f %% \n',kb/nb*100));
end %kb

close(han.fig);

end %function

end %what plot

%%
%% END FUNCTION
%%

%% 

function data_block=D3D_read_debug_block(fid)

num_char=15+1; %X,E15.8E2 = 1 space + 15
fill_in=1e99;

%name
lin=fgetl(fid);
if strcmp(lin(1),'#')==0 
%     error('ups')
end
nam=strrep(lin,'#','');

%time
lin=fgetl(fid);
time1=str2double(lin);

%var
lin=fgetl(fid);
vars=regexp(lin,',','split');
vars=cellfun(@(X)strtrim(X),vars,'UniformOutput',false);
nv=numel(vars);

%loop variables
lin=fgetl(fid);
loop_vars=regexp(lin,',','split');
loop_vars=cellfun(@(X)strtrim(X),loop_vars,'UniformOutput',false);

%loop limits
lin=fgetl(fid);
loop_lim=regexp(lin,' ','split');
loop_lim=cellfun(@(X)str2double(X),loop_lim);
    %make it max for 3D arrays. Could be generalized.
loop_lim_3d=ones(1,6); 
loop_lim_3d(1:numel(loop_lim))=loop_lim;

%data
n1=loop_lim_3d(2)-loop_lim_3d(1)+1;
n2=loop_lim_3d(4)-loop_lim_3d(3)+1;
n3=loop_lim_3d(6)-loop_lim_3d(5)+1;
data=NaN(n1,n2,n3,nv);

kc=0;
for k1=1:n1
    for k2=1:n2
        for k3=1:n3
            kc=kc+1;
            lin=fgetl(fid);
%             data_loc=regexp(lin,'([+-]?(\d+(\.\d+)?)E[+-]?\d+)','tokens');
%             data_loc=cellfun(@(X)str2double(X),data_loc);

%             data_loc=regexp(lin,' ','split');
%             data_block(kc,:)=data_loc;

%             data(k1,k2,k3,:)=data_loc;
            for kv=1:nv
                idx0=(kv-1)*num_char+1;
                lin_l=lin(idx0:idx0+num_char-1);
                if contains(lin_l,'*')
                    num=fill_in;
                else
                    num=str2double(lin_l);
                end
                data(k1,k2,k3,kv)=num;
            end %kv
        end %k3
    end %k2
end %k1

%join
data_block=v2struct(nam,time1,vars,loop_vars,data);

end %function

%%

function figure_db(in_p)

v2struct(in_p);

han.fig=figure('visible',fig_visible);
scatter(xp,yp,10,vp,'filled')
han.cbar=colorbar;
cbar_str=sprintf('%s, %s %d',strrep(var_str,'_','\_'),loop_var_str,idx_loop_var_str);
han.cbar.Label.String=cbar_str;

title({sprintf('time1=%f',tim),strrep(nam,'_','\_')});

%                 pause
fpath_fig=sprintf('%s_%s_%d_%s_%f.png',nam,loop_var_str,idx_loop_var_str,var_str,tim);
print(han.fig,fpath_fig,'-dpng','-r150');
close(han.fig)

end

