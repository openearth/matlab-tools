function sfincs_write_ascii_inputs(z,msk,ascdepfile,ascmskfile)
%%% checks:
id = isnan(msk(:));
if any(isnan(z(id)))
    error('Your input contains NaN values for active grid cells, please check')
end
%%%

% Writes ascii input files for SFINCS
    
% Depth file
z(isnan(z))=-999;
dlmwrite(ascdepfile,z,'delimiter',' ','precision','%8.2f');

% Mask file
dlmwrite(ascmskfile,msk,'delimiter',' ','precision','%i');
