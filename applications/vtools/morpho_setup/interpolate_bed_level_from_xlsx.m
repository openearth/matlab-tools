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
%Interpolate bed levels on a grid.
%
%There are two options:
%   1. Provide a shapefile and Excel file together with a year. 
%   2. Provide a shapefile and a dbf-file with the data for a year.
%
%INPUT:
%   -fpath_shp: shapefile.
%   -fpath_data: Excel or dbf-file.
%   -fpath_grd: netcdf-file with the grid.
%
%PAIR-INPUT:
%   -Option 1:
%       -xlsx_range (optional): range to read from the Excel file.
%       -year (compulsory): year for which data is needed.
%   -Option 2:

function interpolate_bed_level_from_xlsx(fpath_shp,fpath_data,fpath_grd,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'xlsx_range','');
addOptional(parin,'year','');
addOptional(parin,'polygon_in','');
addOptional(parin,'polygon_out','');
addOptional(parin,'polygon_in_bl','');
addOptional(parin,'ds',NaN);
addOptional(parin,'rkmi',NaN);
addOptional(parin,'rkmf',NaN);
addOptional(parin,'br','');
addOptional(parin,'fdir_out','');
addOptional(parin,'do_debug',0);

parse(parin,varargin{:});

xlsx_range=parin.Results.xlsx_range;
etab_year=parin.Results.xlsx_range;
fpath_pol_in=parin.Results.polygon_in;
fpath_pol_out=parin.Results.polygon_out;
fpath_pol_in_bl=parin.Results.polygon_in_bl;
ds=parin.Results.ds;
rkmi=parin.Results.rkmi;
rkmf=parin.Results.rkmf;
br=parin.Results.br;
fdir_out=parin.Results.fdir_out;
do_debug=parin.Results.do_debug;

%%

do_pol_in=1;
if isempty(fpath_pol_in)
    do_pol_in=0;
end

do_pol_out=1;
if isempty(fpath_pol_out)
    do_pol_out=0;
end

do_rol_mean=1;
if isnan(ds)
    do_rol_mean=0;
end
%2DO: add that all data is available. Maybe better inside the right function.

[fdir,fname]=fileparts(fpath_data);
if isempty(fdir_out)
    fdir_out=fdir;
end

%% dia

fpath_dia=fullfile(fdir,sprintf('%s.log',fname));
fid_log=fopen(fpath_dia,'w');

%% read bed level

fpath_mat_tmp=fullfile(pwd,'rbl.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug
    messageOut(fid_log,'Start reading bed level');
    [etab_cen,pol]=load_etab(fpath_shp,fpath_data,xlsx_range,etab_year);
    if do_debug
        save(fpath_mat_tmp,'etab_cen','pol')
    end
else
    messageOut(fid_log,'Start loading bed level');
    load(fpath_mat_tmp,'etab_cen','pol')
end

%% read grid

fpath_mat_tmp=fullfile(pwd,'rg.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug
    messageOut(fid_log,'Start reading grid');
    gridInfo=EHY_getGridInfo(fpath_grd,{'XYcen','XYcor','Zcen','Zcor','grid'}); %`Zcen` gives you `Zcor`
    if do_debug
        save(fpath_mat_tmp,'gridInfo')
    end
else
    messageOut(fid_log,'Start loading grid');
    load(fpath_mat_tmp,'gridInfo')
end

%% find centroids of polygons

fpath_mat_tmp=fullfile(pwd,'fc.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug
    messageOut(fid_log,'Start finding centroids');
    [xpol_cen,ypol_cen]=centroid_polygons(pol);
    if do_debug
        save(fpath_mat_tmp,'xpol_cen','ypol_cen')
    end
else
    messageOut(fid_log,'Start loading centroids');
    load(fpath_mat_tmp,'xpol_cen','ypol_cen')
end

%% BEGIN DEBUG

% load('data.mat')
% save('data.mat','pol','etab_cen','gridInfo','xpol_cen','ypol_cen')

% END DEBUG

%% roling mean

fpath_mat_tmp=fullfile(pwd,'rm.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug
    messageOut(fid_log,'Start computing rolling mean');
    if do_rol_mean
        etab_cen_mod=rolling_mean(fid_log,pol,ds,rkmi,rkmf,br,etab_cen);
    else
        etab_cen_mod=etab_cen;
    end
    if do_debug
        save(fpath_mat_tmp,'etab_cen_mod')
    end
else
    messageOut(fid_log,'Start loading rolling mean');
    load(fpath_mat_tmp,'etab_cen_mod')
end

%% read polygons of points to include

fpath_mat_tmp=fullfile(pwd,'polin.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug 
    bol_in=true(numel(gridInfo.Xcen),1);
    if do_pol_in
        messageOut(fid_log,'Start finding points in polygon')    
        bol_in=points_in_shp_and_grid(fpath_pol_in,gridInfo.Xcen,gridInfo.Ycen);
    else
        messageOut(fid_log,'Skip finding points in polygon')
    end
    if do_debug
        save(fpath_mat_tmp,'bol_in')
    end
else
    messageOut(fid_log,'Start loading points in polygon')   
    load(fpath_mat_tmp,'bol_in')
end

%% read polygons of points to exclude

fpath_mat_tmp=fullfile(pwd,'polout.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug 
    bol_out=false(numel(gridInfo.Xcen),1);
    if do_pol_out
        messageOut(fid_log,'Start finding points out polygon')
        bol_out=points_in_shp_and_grid(fpath_pol_out,gridInfo.Xcen,gridInfo.Ycen);
    else
        messageOut(fid_log,'Skip finding points out polygon')
    end
    if do_debug
        save(fpath_mat_tmp,'bol_out')
    end
else
    messageOut(fid_log,'Start loading points out polygon')   
    load(fpath_mat_tmp,'bol_out')
end

%% read polygons of point to include in interpolation of bed level polygon

fpath_mat_tmp=fullfile(pwd,'polin_pol.mat');
if ~isfile(fpath_mat_tmp) || ~do_debug 
    bol_in_pol=true(numel(xpol_cen),1);
    if do_pol_in
        messageOut(fid_log,'Start finding points in polygon (bed level)')    
        bol_in_pol=points_in_shp_and_grid(fpath_pol_in_bl,xpol_cen,ypol_cen);
    else
        messageOut(fid_log,'Skip finding points in polygon (bed level)')
    end
    if do_debug
        save(fpath_mat_tmp,'bol_in_pol')
    end
else
    messageOut(fid_log,'Start loading points in polygon (bed level)')   
    load(fpath_mat_tmp,'bol_in_pol')
end

%% BEGIN DEBUG

% % pol_xy=polcell2nan(pol.xy.XY);
% % shp=D3D_io_input('read','p:\11209261-rivierkunde-2023-morerijn\05_data\230321_bed_level\07_pol_in_bl\waal.shp','xy_only',1);
% %
% figure
% hold on
% % plot(pol_xy(:,1),pol_xy(:,2),'k')
% % plot(gridInfo.grid(:,1),gridInfo.grid(:,2),'r')
% % scatter(xint,yint,10,'b');
% % scatter(gridInfo.Xcor,gridInfo.Ycor,10,gridInfo.Zcor,'filled')
% % scatter(xpol_cen,ypol_cen,10,etab_cen,'s','filled')
% scatter(xpol_cen(bol_cen_int),ypol_cen(bol_cen_int),10,etab_cen(bol_cen_int),'s','filled')
% plot(shp(:,1),shp(:,2))
% % scatter(xpol_cen,ypol_cen,20,etab_cen_mod,'s','filled')
% % scatter(xint,yint,10,zint,'filled')
% colorbar
% axis equal
% 
% % END DEBUG


%% interpolate polygon bed level at grid centres 

bol_n=isnan(etab_cen);

bol_cen_int=~bol_n & bol_in_pol;

F_fil=scatteredInterpolant(xpol_cen(bol_cen_int),ypol_cen(bol_cen_int),etab_cen_mod(bol_cen_int),'linear','none'); %filtered
F_ori=scatteredInterpolant(xpol_cen(bol_cen_int),ypol_cen(bol_cen_int),etab_cen(bol_cen_int),'linear','none'); %original

bol_grd_int=bol_in & ~bol_out;

xint=gridInfo.Xcen(bol_grd_int);
yint=gridInfo.Ycen(bol_grd_int);

etab_cengrd_mod=F_fil(xint,yint);
etab_cengrd_ori=F_ori(xint,yint);

%% write

%1) bed level from polygons

    %1.1) original on polygon centres
bol_nn=~isnan(etab_cen);
fpath_xyz=fullfile(fdir_out,sprintf('etab_pol_cenpol_original_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[xpol_cen(bol_nn),ypol_cen(bol_nn),etab_cen(bol_nn)]);

    %1.2) filtered on polygon centres
bol_nn=~isnan(etab_cen_mod);
fpath_xyz=fullfile(fdir_out,sprintf('etab_pol_cenpol_filtered_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[xpol_cen(bol_nn),ypol_cen(bol_nn),etab_cen_mod(bol_nn)]);

    %1.3) filtered on grid centres 
bol_nn=~isnan(etab_cengrd_mod);
fpath_xyz=fullfile(fdir_out,sprintf('etab_pol_cengrd_filtered_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[xint(bol_nn),yint(bol_nn),etab_cengrd_mod(bol_nn)]);

    %1.4) original on grid centres 
bol_nn=~isnan(etab_cengrd_ori);
fpath_xyz=fullfile(fdir_out,sprintf('etab_pol_cengrd_original_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[xint(bol_nn),yint(bol_nn),etab_cengrd_ori(bol_nn)]);

%2) bed level from grid

    %2.1) original on grid corners
bol_nn=~isnan(gridInfo.Zcor);
fpath_xyz=fullfile(fdir_out,sprintf('etab_grd_corgrd_original_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[gridInfo.Xcor(bol_nn),gridInfo.Ycor(bol_nn),gridInfo.Zcor(bol_nn)]);

    %2.3) original on grid centres
bol_nn=~isnan(gridInfo.Zcen);
fpath_xyz=fullfile(fdir_out,sprintf('etab_grd_cengrd_original_%s.xyz',now_chr));
D3D_io_input('write',fpath_xyz,[gridInfo.Xcen(bol_nn),gridInfo.Ycen(bol_nn),gridInfo.Zcen(bol_nn)]);

%%

fclose(fid_log);

end %main function

%%
%% FUNCTIONS
%%

%% load_etab

function [etab_cen,pol]=load_etab(fpath_shp,fpath_data,xlsx_range,etab_year)

[~,~,ext]=fileparts(fpath_data);
switch ext
    case '.xlsx'
        messageOut(fid_log,'Start reading Excel bed level');
        etab_pol_y=load_etab_excel(fpath_xlsx,xlsx_range,etab_year);
        
        messageOut(fid_log,'Start reading shp');
        pol=D3D_io_input('read',fpath_shp,'read_val',1);

        messageOut(fid_log,'Start matching polygon with Excel');
        etab_cen=match_pol_Excel(etab_pol_y,pol);

    case '.dbf'
        [etab_cen,pol]=load_etab_dbf(fpath_shp,fpath_data);
        
    otherwise
        error('Unrecognized extension of data file: %s',ext)
end %ext

end %function

%% load_etab_dbf

function [etab_cen,pol]=load_etab_dbf(fpath_shp,fpath_data)

fid_log=NaN;

%temporary folder for renaming files
fdir_tmp=fullfile(pwd,'tmp_shp');
mkdir_check(fdir_tmp);

[fdir_shp,fname_shp,ext_shp]=fileparts(fpath_shp);
fpath_shp_tmp=fullfile(fdir_tmp,sprintf('%s%s',fname_shp,ext_shp));
copyfile_check(fpath_shp,fpath_shp_tmp);

[fdir_dbf,fname_dbf,ext_dbf]=fileparts(fpath_data);
fpath_dbf_tmp=fullfile(fdir_tmp,sprintf('%s%s',fname_shp,ext_dbf)); %rename the dbf file with the name of the shp to be able to read
copyfile_check(fpath_data,fpath_dbf_tmp);

messageOut(fid_log,'Start reading shp');
pol=D3D_io_input('read',fpath_shp_tmp,'read_val',1);
str_pol={'polygon:MEAN','polygon:COUNT'}; 
polnames=cellfun(@(X)X.Name,pol.val,'UniformOutput',false);
idx_pol=find_str_in_cell(polnames,str_pol);
if any(isnan(idx_pol))
    error('Could not find variable in shapefile %s. Maybe the variable name is different.',fpath_shp_tmp);
end
etab_cen=pol.val{idx_pol(1)}.Val;
count=pol.val{idx_pol(2)}.Val;

bol_nd=count==0;
etab_cen(bol_nd)=NaN;

end %function

%% load_etab_excel

function data_year=load_etab_excel(fpath_xlsx,xlsx_range,etab_year)
    
[fdir,fname]=fileparts(fpath_xlsx);
fpath_mat=fullfile(fdir,sprintf('%s.mat',fname));
if exist(fpath_mat,'file')~=2
    transform2mat(fpath_xlsx,fpath_mat,xlsx_range,etab_year)
end
load(fpath_mat,'data');
    
%% year

bol_year=[data.year]==etab_year;
data_year=data(bol_year);

end %function

%%

%Adapted from that by WO
%
function transform2mat(fpath_xlsx,fpath_mat,xlsx_range)

%%

if isempty(xlsx_range)
    messageOut(fid_log,'Start reading all Excel');
    M=readcell(fpath_xlsx);
else
    %There are problem when reading without limits. Also, specifying the limits is not a perfect solution
    %first and last cells change. Not nice. 
    messageOut(fid_log,sprintf('Start reading Excel range %s',xlsx_range));
    M=readcell(fpath_xlsx,'Range',xlsx_range);
end

row_year=1; %careful. WHen reading the the actual first row may change

%%
messageOut(fid_log,'Start processing Excel');

row_varname=row_year+2;
row_data1=row_varname+1;
[N1,N2]=size(M);
kyear=0;
for k = 1:N2
    year_d=M{row_year,k};
    if ~ismissing(year_d)
        kyear=kyear+1;
        if ~isa(year_d,'double')
            messageOut(fid_log,sprintf('WARNING: It should be a year (double) but it is not, I am skipping: %s',year_d));
            continue
        end
        data(kyear).year=year_d;
        for j = 0:5
            varname_c=M{row_varname,k+j};
            varname = matlab.lang.makeValidName(varname_c);
            data3 = NaN*ones(N1-3,1);
            for m = row_data1:N1
                var_c=M{m,k+j};
                switch(varname)
                    case 'code'
                        if ismissing(var_c)
                            continue
                        end
                        val=pol_str2double(var_c);
                        data3(m-3) = val;
                        data(kyear).(varname) = data3;
                    case 'letter'
                        data(kyear).(varname)(m-3)=letter2double(var_c);
                    otherwise
                        if (~any(ismissing(var_c)) && ~ischar(var_c))
                            data3(m-3)=var_c;
                        end
                        data(kyear).(varname)=data3;
                end
            end %m
        end %j
        
        %Here we rely on the name of the variable in the file.
        fn=fieldnames(data(kyear));
        str_find_c={'MEAN','STD','COUNT','uniek'};
        idx_fn=find_str_in_cell(fn,str_find_c);
        if numel(idx_fn)~=numel(str_find_c)
            error('I expect to have read variables %s',conccellstr(str_find_c))
        end
        bol_nd=data(kyear).COUNT==0;
        data(kyear).MEAN(bol_nd)=NaN;
        data(kyear).STD(bol_nd)=NaN;
        data(kyear).COUNT(bol_nd)=NaN;
        
        data(kyear).MEAN=data(kyear).MEAN/100;
        data(kyear).STD=data(kyear).STD/100;
        data(kyear).uniek=data(kyear).uniek/1000;
        
        messageOut(fid_log,sprintf('Processed year %d',data(kyear).year));
    end %missing
end %k

%% SAVE

save_check(fpath_mat,'data'); 

end %function

%%

function pol_lo=pol_str2double(pol_lo_str)

if strcmp(pol_lo_str(1),'R')
    s=1;
elseif strcmp(pol_lo_str(1),'L')
    s=-1;
else
    s=NaN;
end

pol_lo=s*str2double(pol_lo_str(2));

end %function

%%

% function pol_lo=pol_double2str(pol_lo_str)
% 
% error('do')
% 
% if strcmp(pol_lo_str(1),'R')
%     s=1;
% elseif strcmp(pol_lo_str(1),'L')
%     s=-1;
% else
%     s=NaN;
% end
% 
% pol_lo=s*str2double(pol_lo_str(2));
% 
% end %function

%%

function ld=letter2double(var_c)

ld=NaN;
if isempty(var_c)
    return
elseif strcmp(var_c(1),'N')
    ld=1;
elseif strcmp(var_c(1),'Z')
    ld=2;
end

                        
end %function

%%

function etab_cen=match_pol_Excel(etab_pol_y,pol)
        
%% get polygon names

str_pol={'polygon:hm_punt','polygon:locatie','polygon:Z_N'}; 
polnames=cellfun(@(X)X.Name,pol.val,'UniformOutput',false);
idx_pol=find_str_in_cell(polnames,str_pol);
if numel(idx_pol)~=3
    error('I cannot find one of the strings')
end
pol_hm=pol.val{idx_pol(1)}.Val;
pol_lo_str=pol.val{idx_pol(2)}.Val;
pol_lo_num=cellfun(@(X)pol_str2double(X),pol_lo_str);
pol_let_str=pol.val{idx_pol(3)}.Val;
pol_let_num=cellfun(@(X)letter2double(X),pol_let_str);

%% bed level at each polygon

npol=numel(pol.xy.XY);
etab_cen=NaN(npol,1);
for kpol=1:npol
    bol_hm=pol_hm(kpol)==etab_pol_y.uniek;
    bol_lo=pol_lo_num(kpol)==etab_pol_y.code;
    bol_get=bol_lo&bol_hm;
    if sum(bol_get)>1
        if isnan(pol_let_num(kpol))
            bol_let=isnan(etab_pol_y.letter)';
        else
            bol_let=pol_let_num(kpol)==etab_pol_y.letter';
        end
        bol_get=bol_get&bol_let;
    end
    if sum(bol_get)~=1
        error('Not 1 polygon with the same info')
    end
    etab_cen(kpol)=etab_pol_y.MEAN(bol_get);
    fprintf('Bed level in polygon %4.2f %% \n',kpol/npol*100);
end %kpol
        
end %function

%%

function rkm_pol=rkm_of_pol(rkm,br)

ds_pol=polygon_ds;
ds_m=ds_pol/1000;
rkm_pol=round(rkm/ds_m)*ds_m;

switch br
    case 'WL'
        rkm_pol=max(rkm,867.5);
end

end

%%

%rkm    = queary point. Can be any. 
%br     = branch code.
%dist   = distance to find the polygon names
%
function [rkm_pol,br_num]=get_pol_along_line(rkm,br,dist)

% rkm_pol=rkm_of_pol(rkm,br); %the rkm along a certain branch closest to the query rkm. 
ds_pol=polygon_ds; 
rkm_s=rkm-dist/2/1000:ds_pol/1000:rkm+dist/2/1000;

ns=numel(rkm_s);
% str_pol=cell(ns,1);
br_l=cell(ns,1);
br_num=NaN(ns,1);
rkm_pol=NaN(ns,1);
for ks=1:ns
    rkm_pol(ks)=rkm_of_pol(rkm_s(ks),br); %the rkm along a certain branch closest to the query rkm. 
    br_l{ks}=branch_rt(br,rkm_pol(ks)); %branch name (e.g., BO) for a given rkm and river branch (e.g. WA). 
%     str_pol{ks,1}=polygon_str(br_l,rkm_pol);
    br_num(ks)=br_str2double(br_l{ks});
end

end

%%

function br_s=branch_rt(br,rkm_s)

switch br
    case {'WL','BO','NI'}
        if rkm_s>960.15
            br_s='NI';
        elseif rkm_s>952.85
            br_s='BO';
        else
            br_s='WL';
        end
    otherwise
        error('do')
end

end %function


%% 

function ds=polygon_ds(varargin)

ds=100; 

end 

%%

% function pstr=polygon_str(rkm_pol,br_l,loc_str)
% 
% pstr=sprintf('%s_5.2f',br_l,rkm_pol);
% 
% end

%% 

function br_num=br_str2double(br_str)

% a=unique(cellfun(@(X)X(1:2),rkm_str,'UniformOutput',false));

switch br_str
    case 'BO'
        br_num=1;
    case 'BR'
        br_num=2;
    case 'IJ'
        br_num=3;
    case 'LE'
        br_num=4;
    case 'NI'
        br_num=5;
    case 'NR'
        br_num=6;
    case 'PK'
        br_num=7;
    case 'RH'
        br_num=8;
    case 'WL'
        br_num=9;
    otherwise
        br_num=NaN;
end 

end %functions

%%

function [xpol_cen,ypol_cen]=centroid_polygons(pol)

npol=numel(pol.xy.XY);
xpol_cen=NaN(npol,1);
ypol_cen=NaN(npol,1);
for kpol=1:npol
    polyin=polyshape(pol.xy.XY{kpol,1}(:,1),pol.xy.XY{kpol,1}(:,2));
    [xpol_cen(kpol),ypol_cen(kpol)]=centroid(polyin);
    fprintf('Polygon centroid %4.2f %% \n',kpol/npol*100);
end

% %% BEGIN DEBUG
% 
% figure
% hold on
% for kpol=1:100
% plot(pol.xy.XY{kpol,1}(:,1),pol.xy.XY{kpol,1}(:,2))
% scatter(xpol_cen(kpol),ypol_cen(kpol));
% end
% 
% %% END DEBUG

end %function

%%

function [ident_pol_str,rkm_pol_num,br_pol_num,loc_pol_num,area_cen]=data_pol(pol)

str_pol={'polygon:hm_nummer','polygon:Locatie','polygon:oppervlak_'}; 
polnames=cellfun(@(X)X.Name,pol.val,'UniformOutput',false);
idx_pol=find_str_in_cell(polnames,str_pol);
if any(isnan(idx_pol))
    error('Could not find variable in shapefile. Maybe the variable name is different.');
end

ident_pol_str=pol.val{idx_pol(1)}.Val;
rkm_pol_num=cellfun(@(X)str2double(X(4:end)),ident_pol_str);

br_pol_num=cellfun(@(X)br_str2double(X(1:2)),ident_pol_str);

loc_str=pol.val{idx_pol(2)}.Val;
loc_pol_num=cellfun(@(X)pol_str2double(X),loc_str);

area_cen=pol.val{idx_pol(3)}.Val;

end %function

%%

function etab_cen_mod=rolling_mean(fid_log,pol,ds,rkmi,rkmf,br,etab_cen)

[ident_pol_str,rkm_pol_num,br_pol_num,loc_pol_num,area_cen]=data_pol(pol);

loc_v=[-4:1:-1,1:1:4]; %L4-R4
etab_cen_mod=NaN(size(etab_cen));
pol_d=polygon_ds;
rkm_q_v=rkmi:pol_d/1000:rkmf; %vector of query rkm. A vector of points to assess irrespective of polygons. Make sure it is smaller than the polygons. 
nrkm=numel(rkm_q_v);
nl=numel(loc_v);
tol_rkm=1e-10;
for krkm=1:nrkm
    rkm_q=rkm_q_v(krkm); %query rkm (any) at which to compute the mean
    rkm_mod=rkm_of_pol(rkm_q,br); %rkm to modify. Along a certain branch closest to the query rkm. 
    br_mod_str=branch_rt(br,rkm_mod); %branch name to modify (e.g., BO) for a given rkm and river branch (e.g. WA). 
    br_mod_num=br_str2double(br_mod_str); %branch number
    [rkm_me,br_me]=get_pol_along_line(rkm_q,br_mod_str,ds); %rkm and branch to compute the mean
    
    bol_rkm_me=ismember_num(rkm_pol_num,rkm_me,tol_rkm); %boolean of the rkm to compute the mean
    bol_br_me=ismember(br_pol_num,br_me); %boolean of the branch to compute the mean
    bol_rkm_mod=rkm_pol_num>rkm_mod-tol_rkm & rkm_pol_num<rkm_mod+tol_rkm; %boolean rkm to modify
    bol_br_mod=ismember(br_pol_num,br_mod_num); %boolean branch to modify
    
    for kl=1:nl
        bol_loc=loc_v(kl)==loc_pol_num;
        bol_me =bol_rkm_me  & bol_loc & bol_br_me ;
        bol_mod=bol_rkm_mod & bol_loc & bol_br_mod;
        if sum(bol_mod)~=1
            str_dp=ident_pol_str(bol_mod);
            messageOut(fid_log,sprintf('Duplicate polygons: %s',str_dp{1}))
%             error('ups')
        end
        if sum(bol_me)<5
            error('ups')
        end
        etab_cen_mod(bol_mod)=sum(etab_cen(bol_me).*area_cen(bol_me))/sum(area_cen(bol_me));
        
        %disp (expensive but useful)
        fprintf(fid_log,'%s :      %s \n',conccellstr(ident_pol_str(bol_mod)),conccellstr(ident_pol_str(bol_me)));
        
        %DEBUG
%         ident_pol_str(bol_me)
%         ident_pol_str(bol_mod)
%         sum(bol_rkm_me&bol_br_me)
%         unique(ident_pol_str(bol_rkm_me&bol_br_me))
%         unique(ident_pol_str(bol_rkm_me))
        %END DEBUG
        
    end %kl
    fprintf('Rolling mean %4.2f %% \n',krkm/nrkm*100)
end %krkm

end %function