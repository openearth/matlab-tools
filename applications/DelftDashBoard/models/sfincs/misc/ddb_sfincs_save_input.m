function ddb_sfincs_save_input

handles=getHandles;

inp=handles.model.sfincs.domain(ad).input;

% Do some checks here
if handles.model.sfincs.domain(ad).flowboundarypoints.length==0
    inp.bndfile='';
    inp.bzsfile='';
end

% if handles.model.sfincs.domain(ad).waveboundarypoints.length==0
%     inp.bwvfile='';
%     inp.bhsfile='';
%     inp.btpfile='';
%     inp.bwdfile='';
% end
if handles.model.sfincs.domain(ad).use_subgrid==1
    inp.depfile='';
end

if handles.model.sfincs.domain(ad).discharges.number==0
    inp.srcfile='';
    inp.disfile='';
end

if handles.model.sfincs.domain(ad).nrobservationpoints==0
    inp.obsfile='';
end

% if handles.model.sfincs.domain(ad).coastline.length==0
%     inp.cstfile='';
% end

switch handles.model.sfincs.domain(ad).roughness_type
    case{'uniform'}
        inp.manning_sea=[];
        inp.manning_land=[];
        inp.rghfile='';
        inp.rgh_lev_land=[];
    case{'landsea'}
        inp.manning=[];
        inp.rghfile='';
    case{'file'}
        inp.manning=[];
        inp.manning_sea=[];
        inp.manning_land=[];
        inp.rgh_lev_land=[];
end

switch handles.model.sfincs.domain(ad).restart_option
    case{'none'}
        inp.trstout=[];
        inp.dtrstout=[];
    case{'fixed'}
        inp.dtrstout=[];
    case{'interval'}
        inp.trstout=[];
end

inp.bzifile='';

sfincs_write_input('sfincs.inp',inp);

fid=fopen('run.bat','wt');
fprintf(fid,'%s\n',['call "', handles.model.sfincs.exedir filesep 'sfincs.exe">sfincs_log.txt']);
fclose(fid);
