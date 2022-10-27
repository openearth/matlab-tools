function sfincs_write_binary_roughness(rgh,msk,rghfile)

% Writes binary roughness files for SFINCS

iincl=0;  % include only msk>0
%iincl=-1; % include all points

if ~isempty(rghfile)
    rghv=rgh(msk>iincl);
    fid=fopen(rghfile,'w');
    fwrite(fid,rghv,'real*4');
    fclose(fid);
end
