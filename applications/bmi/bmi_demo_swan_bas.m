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

idsHs = 4;
s.Hs = voq((676*idsHs+1):(676*(idsHs+1)));
s.Hs_2D = reshape(s.Hs,fliplr(size(s.XCGRID)));

s.dp2 = s.dp2(1:end-1);
s.dp2_2D = reshape(s.dp2,fliplr(size(s.XCGRID)));

% out = getHm0_2D(s);
% out.hs = out.hs(1:end-1);
% out.hs_2D = reshape(out.hs,fliplr(size(s.XCGRID)));


%% Print

% surf(double(XCGRID), double(YCGRID), double(tot2D)')
% surf(double(s.XCGRID), double(s.YCGRID), double(out.Etot_2D)')
% surfc(double(s.XCGRID), double(s.YCGRID), flipud(double(out.hs_2D)))

figure
surfc(double(s.XCGRID), double(s.YCGRID), double(s.dp2_2D))
colorbar

figure
surfc(double(s.XCGRID), double(s.YCGRID), double(s.Hs_2D))
colorbar
% view(2)

%% cleanup
bmi_finalize(bmidll);
