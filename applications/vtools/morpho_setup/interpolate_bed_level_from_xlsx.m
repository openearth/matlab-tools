%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18819 $
%$Date: 2023-03-13 16:40:14 +0100 (Mon, 13 Mar 2023) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18819 2023-03-13 15:40:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%

function interpolate_bed_level_from_xlsx(fpath_shp,fpath_xlsx,fpath_grd,etab_year,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'xlsx_range','');

parse(parin,varargin{:});

xlsx_range=parin.Results.xlsx_range;

%% dia

[fdir,fname]=fileparts(fpath_xlsx);
fpath_dia=fullfile(fdir,sprintf('%s.log',fname));
fid_log=fopen(fpath_dia,'w');

%% read

messageOut(fid_log,'Start reading shp');
pol=D3D_io_input('read',fpath_shp,'read_val',1);

messageOut(fid_log,'Start reading bed level');
etab_pol=load_etab(fpath_xlsx,xlsx_range);

messageOut(fid_log,'Start reading grid');
gridInfo=EHY_getGridInfo(fpath_grd,{'XYcen','XYcor'});

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

%% find centroids of polygons

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

%% year

bol_year=[etab_pol.year]==etab_year;
etab_pol_y=etab_pol(bol_year);

%% bed level at each polygon

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

%% raw

fpath_xzy=fullfile(fdir,sprintf('etab_cen_%s.xyz',now_chr));
D3D_io_input('write',fpath_xzy,[xpol_cen,ypol_cen,etab_cen]);

%% interpolate

bol_n=isnan(etab_cen);

F=scatteredInterpolant(xpol_cen(~bol_n),ypol_cen(~bol_n),etab_cen(~bol_n));
xint=[gridInfo.Xcen;gridInfo.Xcor];
yint=[gridInfo.Ycen;gridInfo.Ycor];
zint=F(xint,yint);

fpath_xzy=fullfile(fdir,sprintf('etab_%s.xyz',now_chr));
D3D_io_input('write',fpath_xzy,[xint,yint,zint]);

%%

fclose(fid_log);

end %main function

%%
%% FUNCTIONS
%%

function data=load_etab(fpath_xlsx,xlsx_range)
    
[fdir,fname]=fileparts(fpath_xlsx);
fpath_mat=fullfile(fdir,sprintf('%s.mat',fname));
if exist(fpath_mat,'file')~=2
    transform2mat(fpath_xlsx,fpath_mat,xlsx_range)
end
load(fpath_mat,'data');
    
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
















