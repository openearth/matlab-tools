function fdir_out = get_full_dir(fdir)
% get_full_dir - returns dir without intermediate level ups ..
p = split(fullfile(fdir),filesep);
idx= find(strcmp(p,'..'));
fdir_out = fdir;
if length(idx)> 0;
    if idx(1) > 2;
        fdir_out = fullfile(p{[1:idx(1)-2,idx(1)+1:end]});
        fdir_out = get_full_dir(fdir_out);
    end
end
end

