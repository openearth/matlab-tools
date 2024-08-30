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
%Interpolate grain size distribution data on a grid. 
%
%The input grain size distribution is given in a (set of) files containing the
%cumulative grain size fractions along a polyline. If there is more than one file, 
%the data must be in order. I.e., it is assumed that the polyline of the second file
%follows the one of the first file. It is also input a (set of) grid files in which
%to interpolate the data. Finally, one needs to specify the characteristic grain 
%sizes of the model in which to interpolate. 

function read_gsd(fpath,dtype,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fdir_out',pwd);
addOptional(parin,'xlims',[NaN,NaN]);

parse(parin,varargin{:});

fdir_out=parin.Results.fdir_out;
flg.xlims=parin.Results.xlims;

%% CALC

nf=numel(fpath);
for kf=1:nf
    read_gsd_single(fpath{kf},dtype(kf),fdir_out,flg);
end %kf

end %function

%%
%% FUNCTIONS
%%

function read_gsd_single(fpath,dtype,fdir_out,flg)

switch dtype
    case 1
        read_gsd_type_1(fpath,fdir_out,flg)
    case 2
        read_gsd_type_2(fpath,fdir_out,flg)
    otherwise
        error('Unknown type %d',dtype)
end %dtype

end %function

%%

function read_gsd_type_1(fpath_input_gsd,fdir_out,flg)

%% INPUT

%this could be passed throw input, but it is very file-specific. 

%fractions sheet
sheet_frac=4;
idx_col_frac_rkm=3; %column with rkm where fractions are given
idx_row_frac_head=3; %header lines to data
idx_col_frac_gsd=9:32; %columns with cumulative fractions 

%data sheet
sheet_data=2;
idx_col_data_rkm=1;
idx_col_data_pos=2;
idx_col_data_xy=3:4;
idx_row_data_head=4;

%% CALC

    %% read
gsd_raw_rkm=readcell(fpath_input_gsd,'Sheet',sheet_data); %Sheet #4 is named '2'
gsd_raw_frac=readmatrix(fpath_input_gsd,'Sheet',sheet_frac); %Sheet #4 is named '2'

    %% get frac
dk=gsd_raw_frac(idx_row_frac_head,idx_col_frac_gsd); %sieve opening is in the last line of the header
dk=check_dk(dk);

frac=gsd_raw_frac(idx_row_frac_head+1:end,idx_col_frac_gsd);
rkm=gsd_raw_frac(idx_row_frac_head+1:end,idx_col_frac_rkm);

    %% get rkm
rkm_ind=cell2mat(gsd_raw_rkm(idx_row_data_head+1:end,idx_col_data_rkm));
rkm_pos=gsd_raw_rkm(idx_row_data_head+1:end,idx_col_data_pos);
rkm_xy=cell2mat(gsd_raw_rkm(idx_row_data_head+1:end,idx_col_data_xy));

%rkm to xy
bol_as=cellfun(@(X)strcmp(X,'as'),rkm_pos);
rkm_as=rkm_ind(bol_as);
rkm_xy_as=rkm_xy(bol_as,:);

x=interp_line_vector(rkm_as,rkm_xy_as(:,1),rkm,NaN);
y=interp_line_vector(rkm_as,rkm_xy_as(:,2),rkm,NaN);

%clean
bol_out=isnan(sum(frac,2));

%% SAVE

print_and_save(x,y,rkm,frac,dk,fdir_out,bol_out,fpath_input_gsd,flg)

end %function

%%

function fig_gsd(dk,frac,rkm,fpath_out,flg)

dk_char=sqrt(dk(1:end-1).*dk(2:end));
str=cell(numel(dk_char),1);
for k=1:numel(dk_char)
    str{k,1}=sprintf('%7.3f mm',dk_char(k));
end
dfrac=abs(diff(frac,1,2));
tol=1e-6;
if any(sum(dfrac,2)>1+tol) || any(sum(dfrac,2)<1-tol)
    error('Something is wrong.')
end

figure 
hold on
han.a=area(rkm,dfrac);
ylim([0,1])
ylabel('fraction of characteristic size [-]')
xlabel('river kilometer [km]')
legend(str,'location','eastoutside')
cmap=brewermap(numel(dk_char),'RdYlBu');
for k=1:numel(dk_char)
    han.a(k).FaceColor=cmap(k,:);
end

if ~isnan(flg.xlims(1))
    xlim(flg.xlims);
end

printV(gcf,fpath_out);

end %function

%%

function save_data(x,y,rkm,frac,dk,fpath_out)

gsd=v2struct(x,y,rkm,frac,dk);
save(fpath_out,'gsd');

end %function

%%

function print_and_save(x,y,rkm,frac,dk,fdir_out,bol_out,fpath_input_gsd,flg)

[frac,x,y,rkm]=filter_output(frac,x,y,rkm,bol_out);

%dir
mkdir_check(fdir_out);
[~,fname,~]=fileparts(fpath_input_gsd);

%plot
fpath_out=fullfile(fdir_out,sprintf('%s.png',fname));
fig_gsd(dk,frac,rkm,fpath_out,flg)

%save
fpath_out=fullfile(fdir_out,sprintf('%s.mat',fname));
save_data(x,y,rkm,frac,dk,fpath_out)

end %function

%%

function read_gsd_type_2(fpath_input_gsd,fdir_out,flg)

%fractions sheet
sheet_frac=2;
idx_col_frac_rkm=4; %column with rkm where fractions are given
idx_row_frac_head=3; %header lines to data
idx_col_frac_gsd=92:116; %columns with cumulative fractions 

%data sheet
idx_col_data_rkm=4;
idx_col_data_pos=5;
    tol_pos=10;
idx_col_data_xy=6:7;
idx_col_z=10; %elevation of the sample [m]
    tol_z=1e-2;
idx_row_data_head=idx_row_frac_head;

%% CALC

    %% read
gsd_raw_frac=readmatrix(fpath_input_gsd,'Sheet',sheet_frac); %Sheet #4 is named '2'

    %% get frac
dk=gsd_raw_frac(idx_row_frac_head-1,idx_col_frac_gsd); %sieve opening is in one to the last line of the header
dk=check_dk(dk);

frac=gsd_raw_frac(idx_row_frac_head+1:end,idx_col_frac_gsd);
rkm=gsd_raw_frac(idx_row_frac_head+1:end,idx_col_frac_rkm);

%% extend GSD 
%The limit sieves have mass. We add a column at the beginning and end to make sure there is no mass. 
%It is an assumption!
dk=[362,dk,0.002]; 
np=size(frac,1);
frac=[ones(np,1),frac,zeros(np,1)];

    %% get rkm
% rkm_ind=gsd_raw_frac(idx_row_data_head+1:end,idx_col_data_rkm);
rkm_pos=gsd_raw_frac(idx_row_data_head+1:end,idx_col_data_pos);
rkm_xy=gsd_raw_frac(idx_row_data_head+1:end,idx_col_data_xy);
rkm_z=gsd_raw_frac(idx_row_data_head+1:end,idx_col_z);

%bol to exclude
bol_pos=rkm_pos>-tol_pos & rkm_pos<tol_pos;
bol_z=rkm_z>-tol_z & rkm_z<tol_z;
bol_frac=~isnan(sum(frac,2));
bol_out=~(bol_pos & bol_z & bol_frac);
% rkm_as=rkm_ind(bol_as);
% rkm_xy_as=rkm_xy(bol_as,:);

% x=interp_line_vector(rkm_as,rkm_xy_as(:,1),rkm,NaN);
% y=interp_line_vector(rkm_as,rkm_xy_as(:,2),rkm,NaN);
x=rkm_xy(:,1);
y=rkm_xy(:,2);

%% SAVE

print_and_save(x,y,rkm,frac,dk,fdir_out,bol_out,fpath_input_gsd,flg)

end %function

%% 

function dk=check_dk(dk)

if any(isnan(dk))
    error('There can be non NaN')
end
if ~mono_increase(fliplr(dk))
    error('Sieve opening is expected to be monotonically decreasing (from coarse to fine).')
end

end %function

%% 

function [frac,x,y,rkm]=filter_output(frac,x,y,rkm,bol_out)

frac(bol_out,:)=[];
x(bol_out)=[];
y(bol_out)=[];
rkm(bol_out)=[];

[rkm,idx_u]=unique(rkm);
frac=frac(idx_u,:);
x=x(idx_u);
y=y(idx_u);

end