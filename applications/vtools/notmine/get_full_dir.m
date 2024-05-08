function fdir_out = get_full_dir(fdir,level)
% get_full_dir - returns dir without intermediate level ups ..
if nargin == 1;
    level = 0; 
    %unit test
    assert(strcmp(get_full_dir('../../../../a/b/../c/d/e/../../f',0),fullfile('..\..\..\..\a\c\f')))
end

p = split(fullfile(fdir),filesep);
ups = strcmp(p,'..');
fdir_out = fdir;
minidx = 2; 
if length(ups)> 0; 
    minidx = find(ups(minidx:end)==0,1); 
end
idx= find(ups(minidx+1:end));
if length(idx)> 0;
    fdir_out = fullfile(p{[1:minidx+idx(1)-2,minidx+idx(1)+1:end]});
    level = level + 1; 
    fdir_out = get_full_dir(fdir_out,level);
end
end

