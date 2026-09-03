%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Gather the polygon averaged shapefiles produced by <tif_to_shp> into
%mat-files, one per group of polygons, in the format read by
%<plot_data_measurements>.
%
%INPUT
%   - fpath_shp_in = paths (cell string) to the shapefiles produced by
%       <tif_to_shp>, one per survey.
%   - date_v = datetime of every survey, in the same order.
%   - fpath_axis = path to the csv-file with the river axis, with columns X
%       and Y. Used to compute the streamwise coordinate. Leave it empty to
%       take the streamwise coordinate from the river kilometre of the
%       polygon file instead.
%   - fpath_output = folder where the mat-files are written.
%
%OUTPUT
%   - fpath_mat = cell string with the paths to the generated mat-files.
%
%OPTIONAL (pair input)
%   - overwrite = true: regenerate a mat-file that already exists;
%       false (default): keep it.
%   - tag_group = cell array with the groups to gather. Every entry holds
%       the values of <locatie> that make up the group. Default is the 16
%       groups of the Maas.
%
%E.G.
%
% fpath_mat=shp_LR_to_mat(fpath_shp_out,date_v,fpath_axis,fpath_output);
% fpath_mat=shp_LR_to_mat(fpath_shp_out,date_v,'',fpath_output);

function fpath_mat=shp_LR_to_mat(fpath_shp_in,date_v,fpath_axis,fpath_output,varargin)

%% CONSTANTS

%groups to gather, given as the values of <locatie> that make up each group
tag_group={ ...
    {'L1'},... %L1
    {'L2'},... %L2
    {'L3'},... %L3
    {'L4'}, ... %L4
    {'R1'},... %R1
    {'R2'},... %R2
    {'R3'},... %R3
    {'R4'}, ... %R4
    {'L1','R1'}, ... %L1R1
    {'L2','L1','R1','R2'}, ... %L2R2
    {'L3','L2','L1','R1','R2','R3'}, ... %L3R3
    {'L4','L3','L2','L1','R1','R2','R3','R4'}, ... %L4R4
    {'L1','L2'},... %L1L2
    {'L1','L2','L3'},... %L1L3
    {'L2','L3'},... %L2L3
    {'R1','R2'},... %R1R2
    {'R1','R2','R3'},... %R1R3
    {'R2','R3'},... %R2R3
    };

unit_bl='bed elevation [m+NAP]';
unit_ds='bed slope [-]';

%% PARSE

parin=inputParser;

addOptional(parin,'overwrite',false);
addOptional(parin,'tag_group',tag_group);

parse(parin,varargin{:});

overwrite=parin.Results.overwrite;
tag_group=parin.Results.tag_group;

if ischar(fpath_shp_in)
    fpath_shp_in={fpath_shp_in};
end
fpath_shp_in=cellfun(@(X)adapt_path_local_machine(X),fpath_shp_in(:),'UniformOutput',false);
fpath_output=adapt_path_local_machine(fpath_output);

do_s=~isempty(fpath_axis);
if do_s
    fpath_axis=adapt_path_local_machine(fpath_axis);
end

nshp=numel(fpath_shp_in);
if numel(date_v)~=nshp
    error('There are %d shapefiles and %d dates',nshp,numel(date_v))
end
date_v=date_v(:)';

if do_s && exist(fpath_axis,'file')~=2
    error('River axis file does not exist: %s',fpath_axis)
end

mkdir_check(fpath_output,NaN,false,false);

%% READ SHAPEFILES

%a shapefile that does not exist is skipped, but then its column would be
%missing, so it is an error rather than a warning
for ks=1:nshp
    if exist(fpath_shp_in{ks},'file')~=2
        error('Shapefile does not exist: %s',fpath_shp_in{ks})
    end
end

messageOut(NaN,sprintf('Reading %s',fpath_shp_in{1}));
shp=D3D_io_input('read',fpath_shp_in{1},'read_val',true);

pol.locatie=strtrim(SHP_get_variable(shp,'polygon:locatie'));
pol.code=strtrim(SHP_get_variable(shp,'polygon:code_uniek'));
pol.rkm=SHP_get_variable(shp,'polygon:hm_punt');
pol.area=SHP_get_variable(shp,'polygon:A');
npol=numel(pol.rkm);

pol.x=cellfun(@(X)mean(X(:,1),'omitnan'),shp.xy.XY(:));
pol.y=cellfun(@(X)mean(X(:,2),'omitnan'),shp.xy.XY(:));

val=NaN(npol,nshp);
cnt=NaN(npol,nshp);
val(:,1)=SHP_get_variable(shp,'polygon:MEAN');
cnt(:,1)=SHP_get_variable(shp,'polygon:COUNT');

for ks=2:nshp
    messageOut(NaN,sprintf('Reading %s',fpath_shp_in{ks}));
    shp_loc=D3D_io_input('read',fpath_shp_in{ks},'read_val',true);

    code_loc=strtrim(SHP_get_variable(shp_loc,'polygon:code_uniek'));
    if ~isequal(code_loc,pol.code)
        error('The polygons of <%s> differ from the ones of <%s>',fpath_shp_in{ks},fpath_shp_in{1})
    end

    val(:,ks)=SHP_get_variable(shp_loc,'polygon:MEAN');
    cnt(:,ks)=SHP_get_variable(shp_loc,'polygon:COUNT');
end

%a polygon without cells has no mean
cnt(isnan(cnt))=0;
val(cnt==0)=NaN;

%% STREAMWISE COORDINATE

if do_s
    axis_t=readtable(fpath_axis);
    if ~all(ismember({'X','Y'},axis_t.Properties.VariableNames))
        error('The river axis file must have columns X and Y: %s',fpath_axis)
    end
else
    messageOut(NaN,'No river axis given, the streamwise coordinate is taken from the river kilometre');
end

%% LOOP GROUPS

ngr=numel(tag_group);
fpath_mat=cell(ngr,1);
tim_dnum=datenum(date_v); %#ok<DATNM>

for kg=1:ngr
    mem=tag_group{kg};
    tag=first_last_string(mem);
    fpath_mat{kg}=fullfile(fpath_output,sprintf('%s_measured.mat',tag));

    messageOut(NaN,sprintf('Group %d of %d: %s',kg,ngr,tag));

    if exist(fpath_mat{kg},'file')==2 && ~overwrite
        messageOut(NaN,sprintf('  output already exists, skipping: %s',fpath_mat{kg}));
        continue
    end

    [rkm_g,x_g,y_g,val_g]=gather_group(pol,val,cnt,mem);
    if isempty(rkm_g)
        messageOut(NaN,'  no polygon in this group, skipping');
        continue
    end

    if do_s
        [s_g,~]=xy_to_sn(axis_t.X,axis_t.Y,x_g,y_g);
        s_g=s_g(:);
    else
        %the river kilometre is the only distance along the river available
        s_g=rkm_g*1000;
    end

    [s_g,idx_sort]=sort(s_g);
    rkm_g=rkm_g(idx_sort);
    val_g=val_g(idx_sort,:);

    data=build_data(rkm_g,s_g,val_g,tim_dnum,fpath_shp_in,unit_bl,unit_ds);

    save(fpath_mat{kg},'data','-v7');
    messageOut(NaN,sprintf('  file written: %s',fpath_mat{kg}));
end

end %function

%% 
%% FUNCTIONS
%% 

%%
%% GATHER_GROUP
%%

%Polygons of the group. Members are merged by the part of <code_uniek> that
%all members share.

function [rkm_g,x_g,y_g,val_g]=gather_group(pol,val,cnt,mem)

nmem=numel(mem);

if nmem==1
    idx=find(strcmp(pol.locatie,mem{1}));
    rkm_g=pol.rkm(idx);
    x_g=pol.x(idx);
    y_g=pol.y(idx);
    val_g=val(idx,:);
    return
end

%<code_uniek> is the value of <locatie> followed by a key shared by all the
%polygons of the same cross section. Keep only keys present for every member.
idx_g=cell(nmem,1);
idx_g{1}=find(strcmp(pol.locatie,mem{1}));
key_g=strip_locatie(pol.code(idx_g{1}),mem{1});
for km=2:nmem
    idx_m=find(strcmp(pol.locatie,mem{km}));
    key_m=strip_locatie(pol.code(idx_m),mem{km});
    [key_g,ia,ib]=intersect(key_g,key_m,'stable');
    idx_g{1}=idx_g{1}(ia);
    idx_g{km}=idx_m(ib);
end

if isempty(key_g)
    rkm_g=[]; x_g=[]; y_g=[]; val_g=[];
    return
end

idx_g=cat(2,idx_g{:});

%the geometry is weighted with the area, which does not depend on the survey
w_g=pol.area(idx_g);
w_s=sum(w_g,2);

rkm_g=sum(pol.rkm(idx_g).*w_g,2)./w_s;
x_g=sum(pol.x(idx_g).*w_g,2)./w_s;
y_g=sum(pol.y(idx_g).*w_g,2)./w_s;

%the values are weighted with the number of cells, which does depend on the
%survey, so that a polygon without data does not count
c_s=zeros(size(cnt(idx_g(:,1),:)));
val_g=zeros(size(c_s));
for km=1:nmem
    c_m=cnt(idx_g(:,km),:);
    v_m=val(idx_g(:,km),:);
    v_m(isnan(v_m))=0;
    c_s=c_s+c_m;
    val_g=val_g+v_m.*c_m;
end

val_g=val_g./c_s;
val_g(c_s==0)=NaN;

end %function

%%
%% STRIP_LOCATIE
%%

function key=strip_locatie(code,tag)

key=regexprep(code,sprintf('^%s',tag),'');

end %function

%%
%% FIRST_LAST_STRING
%%

function tag=first_last_string(str_cell)

if numel(str_cell)==1
    tag=str_cell{1};
else
    tag=[str_cell{1},str_cell{end}];
end

end %function

%%
%% BUILD_DATA
%%

%Same layout as <create_mat_measured_bed_level_csv>.

function data=build_data(rkm,s,val,tim_dnum,source,unit_bl,unit_ds)

nt=numel(tim_dnum);

data.bl.val_mean.rkm=rkm;
data.bl.val_mean.s=s;
data.bl.val_mean.unit=unit_bl;
data.bl.val_mean.tim_dnum=tim_dnum;
data.bl.val_mean.val=val;
data.bl.source=source(:)';

data.detab_ds.val_mean.rkm=rkm;
data.detab_ds.val_mean.s=s;
data.detab_ds.val_mean.unit=unit_ds;
data.detab_ds.val_mean.tim_dnum=tim_dnum;
data.detab_ds.val_mean.val=NaN(numel(rkm),nt);
data.detab_ds.source=source(:)';

ds=diff(cen2cor(s));
for kt=1:nt
    detab=diff(cen2cor(val(:,kt)));
    data.detab_ds.val_mean.val(:,kt)=detab./ds;
end

end %function
