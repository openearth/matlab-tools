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
    s.ac2     = bmi_var_get(bmidll, 'AC2');
    toc
    s.spcsig  = bmi_var_get(bmidll, 'SPCSIG');
    s.ddir    = bmi_var_get(bmidll, 'DDIR');
    s.pwtail  = bmi_var_get(bmidll, 'PWTAIL');
    
    s.XCGRID  = bmi_var_get(bmidll, 'XCGRID');
    s.YCGRID  = bmi_var_get(bmidll, 'YCGRID');
    
    %% (*) (still to) get variables
    % frintf  = bmi_var_get(bmidll, 'FRINTF');
    % fx      = bmi_var_get(bmidll, 'fx');          & dS/dx ??
    % fy      = bmi_var_get(bmidll, 'fy');          & dS/dy ??
    % ubot    = bmi_var_get(bmidll, 'UBOT');
    
end
%% Process data

out = getHm0_2D(s);

out.Etot = out.Etot(1:end-1);
out.Etot_2D = reshape(out.Etot,fliplr(size(s.XCGRID)));

Etot = squeeze(sum(sum(s.ac2,1),2));
Etot = 4*sqrt(Etot(1:end-1));
Etot2D = reshape(Etot,fliplr(size(s.XCGRID)));


%% Print

% surf(double(XCGRID), double(YCGRID), double(tot2D)')
surf(double(s.XCGRID), double(s.YCGRID), double(out.Etot_2D)')
surf(double(s.XCGRID), double(s.YCGRID), out.Hm0_2D')

%% cleanup
bmi_finalize(bmidll);
