function sfincs_write_obsfile(filename,obs)

fid=fopen(filename,'wt');
for ii=1:length(obs.x)
    fprintf(fid,'%10.2f %10.2f\n',obs.x(ii),obs.y(ii));
end
fclose(fid);
