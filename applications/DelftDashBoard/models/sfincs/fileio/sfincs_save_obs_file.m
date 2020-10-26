function sfincs_save_obs_file(filename,obspoints)

fid=fopen(filename,'wt');
for ip=1:length(obspoints.x)
    str=['"' obspoints.names{ip} '"'];
    fprintf(fid,'%12.3f %12.3f %s\n',obspoints.x(ip),obspoints.y(ip),str);
end
fclose(fid);
