format long; close all

ini = 0;
if ini ~= 1
    ini = 1;
    
    %% The shared library and the generic header file
    % Make sure you have setup mex -setup before you run this.
    addpath(pwd)
    
    dll = 'd:\Checkouts\swan\branches\feature\esmf\esmf40.91\vs2010\Debug\swan_dll.dll';
    config_file = 'd:\Checkouts\swan\branches\feature\esmf\esmf40.91\tests\DMrecSWAN02\swan.inp';
    
    %% Load the library
    [bmidll] = bmi_new(dll);
    bmi_initialize(bmidll, config_file);
    tic
    bmi_update(bmidll,3600);
    toc
    
    %% Get variables
    tic
    voq = bmi_var_get(bmidll, 'VOQ');
    toc
    
    voqids    = bmi_var_get(bmidll, 'VOQR');    
    s.XCGRID  = bmi_var_get(bmidll, 'XCGRID');
    s.YCGRID  = bmi_var_get(bmidll, 'YCGRID');
    s.dp2     = bmi_var_get(bmidll, 'DP2');
    
%     s.ac2     = bmi_var_get(bmidll, 'AC2');
%     s.spcsig  = bmi_var_get(bmidll, 'SPCSIG');
%     s.ddir    = bmi_var_get(bmidll, 'DDIR');
%     s.pwtail  = bmi_var_get(bmidll, 'PWTAIL');
    %% (*) (still to) get variables
    % frintf  = bmi_var_get(bmidll, 'FRINTF');
    % fx      = bmi_var_get(bmidll, 'fx');          & dS/dx ??
    % fy      = bmi_var_get(bmidll, 'fy');          & dS/dy ??
    % ubot    = bmi_var_get(bmidll, 'UBOT');
    
end
%% Process data

mip = 676;
% Check swmod1.for MODULE SWCOMM1 for administration of index. 
% Set in swanout1.for SUBROUTINE SWOEXA 
ids.XP = 1;
ids.YP = 2;
ids.Hs = 10; % should be 10 (*) 
ids.depth = 4;

s.XP = voq((mip*(voqids(ids.XP)-1)+1):(mip*(voqids(ids.XP))));
s.YP = voq((mip*(voqids(ids.YP)-1)+1):(mip*(voqids(ids.YP))));
s.twoD.XP = reshape(s.XP,fliplr(size(s.XCGRID)));
s.twoD.YP = reshape(s.YP,fliplr(size(s.XCGRID)));

s.Hs = voq((mip*(voqids(ids.Hs)-1)+1):(mip*(voqids(ids.Hs))));
s.twoD.Hs = reshape(s.Hs,fliplr(size(s.XCGRID)));
s.twoD.Hs(s.twoD.Hs==-999)=NaN;

s.depth = voq((mip*(voqids(ids.depth)-1)+1):(mip*(voqids(ids.depth))));
s.twoD.depth = reshape(s.depth,fliplr(size(s.XCGRID)));
s.twoD.depth(s.twoD.depth==-999)=NaN;

s.dp2 = s.dp2(1:end-1);
s.twoD.dp2 = reshape(s.dp2,fliplr(size(s.XCGRID)));

% out = getHm0_2D(s);
% out.hs = out.hs(1:end-1);
% out.hs_2D = reshape(out.hs,fliplr(size(s.XCGRID)));


%% Print

% figure
% surfc(double(s.XCGRID), double(s.YCGRID), flipud(double(out.hs_2D)))
% figure
% surfc(double(s.XCGRID), double(s.YCGRID), double(s.twoD.dp2)); colorbar

figure
surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.Hs))
colorbar


figure
% plot3(double(s.XP), double(s.YP), double(s.depth))
surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.depth))
xlabel('x')
ylabel('y')
colorbar


%% cleanup
bmi_finalize(bmidll);
