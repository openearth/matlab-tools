function sfincs_write_boundary_points(filename,points)

%%% checks:
if any(isnan([points.x])) || any(isnan([points.y]))
    error('Your input contains NaN values, please check')
end
%
if isfield(points,'length') == false    
    points.length = length(points.x);
end
%%%

fid=fopen(filename,'wt');
for ip=1:points.length
    fprintf(fid,'%10.1f %10.1f\n',points.x(ip),points.y(ip));
end
fclose(fid);
