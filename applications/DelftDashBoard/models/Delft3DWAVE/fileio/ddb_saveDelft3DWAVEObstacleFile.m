function ddb_saveDelft3DWAVEObstacleFile(handles)

ii=strmatch('Delft3DWAVE',{handles.Model.name},'exact');

inp=handles.Model(ii).Input;

%% Obstacle file

obs.ObstacleFileInformation.FileVersion.value        = '02.00';
obs.ObstacleFileInformation.PolylineFile.value       = inp.obstaclepolylinesfile;

for iob=1:inp.nrobstacles
    obs.Obstacle(iob).Name.value               = inp.obstacles(iob).name;
    obs.Obstacle(iob).Type.value               = inp.obstacles(iob).type;
    switch lower(inp.obstacles(iob).type)
        case{'dam'}
            obs.Obstacle(iob).Height.value             = inp.obstacles(iob).height;
            obs.Obstacle(iob).Height.type              = 'real';
            obs.Obstacle(iob).Alpha.value              = inp.obstacles(iob).alpha;
            obs.Obstacle(iob).Alpha.type               = 'real';
            obs.Obstacle(iob).Beta.value               = inp.obstacles(iob).beta;
            obs.Obstacle(iob).Beta.type                = 'real';
        case{'sheet'}
            obs.Obstacle(iob).TransmCoef.value               = inp.obstacles(iob).transmcoef;
            obs.Obstacle(iob).TransmCoef.type                = 'real';
    end
    obs.Obstacle(iob).Reflections.value        = inp.obstacles(iob).reflections;
    switch lower(inp.obstacles(iob).reflections)
        case{'no'}
        otherwise
            obs.Obstacle(iob).ReflecCoef.value               = inp.obstacles(iob).refleccoef;
            obs.Obstacle(iob).ReflecCoef.type                = 'real';
    end
end

ddb_saveDelft3D_keyWordFile(inp.obstaclefile,obs);

