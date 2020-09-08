paths_dir_in='c:\Users\victorchavarri\Downloads\a1'; 

[dir_paths,dir_dire,dir_fnames]=dirwalk(paths_dir_in);
np=numel(dir_paths);

%number of files
nf=0;
for kp=1:nd1
nf=nf+sum(numel(dir3{kp}));
end

%preallocate
meta=struct(...
    'filename','',...
    'x',cell(nf,1),...
    'y',cell(nf,1),...
    'time',datetime([],[],[]),...
    'width',cell(nf,1),...
    'height',cell(nf,1),...
    'alpha',cell(nf,1)...
);

for kp=1:np
    nf=numel(dir_fnames{kp});
    for kf=1:nf
		if ~isempty(dir_fnames{kp,1})
			paths_file=fullfile(dir_paths{kp},dir_fnames{kp,1}{kf,1});
			fprintf('%s \n',paths_file)
		end
    end %kf
end %kf