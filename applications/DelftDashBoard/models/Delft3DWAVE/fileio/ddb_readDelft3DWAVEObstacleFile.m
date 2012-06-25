function obs=ddb_readDelft3DWAVEObstacleFile(obs,filename)

s = ddb_readDelft3D_keyWordFile(filename);

for ii=1:length(s.obstacle)
    for jj=1:length(obs)
        if strcmpi(s.obstacle(ii).name,obs(jj).name)
            % Obstacle found
            flds={'type','height','alpha','beta','reflections','refleccoef'};
            for kk=1:length(flds)
                if isfield(s.obstacle(ii),flds{kk})
                    if ~isempty(s.obstacle(ii).(flds{kk}))
                        obs(jj).(flds{kk})=s.obstacle(ii).(flds{kk});
                    end
                end
            end
        end
    end
end
