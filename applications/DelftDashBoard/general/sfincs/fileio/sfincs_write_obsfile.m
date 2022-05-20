function sfincs_write_obsfile(filename,obs)
char_len_max = 256; % only first characters of supplied names are used

%%% checks:
if any(isnan(obs.x)) || any(isnan(obs.y))
    error('Your input contains NaN values, please check')
end
%%%

fid=fopen(filename,'wt');
for ii=1:length(obs.x)
    if isfield(obs,'names')  
        name = obs.names{ii};
        if length(name) > char_len_max
            name = name(1:char_len_max); 
        end
        fprintf(fid,"%10.2f %10.2f '%s'\n",obs.x(ii),obs.y(ii),name);
    else
        fprintf(fid,"%10.2f %10.2f \n",obs.x(ii),obs.y(ii));        
    end
end
fclose(fid);
