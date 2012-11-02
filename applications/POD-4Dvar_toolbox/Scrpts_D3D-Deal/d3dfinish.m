function [] = d3dfinish(varargin)

    %thestring = varargin{1};
    thestring = 'IG_D3D';
    pausetime = varargin{2};
        
    [~,b] = system('qstat -u garcia_in');
    while length(strfind(b, thestring)) > 1
        disp('Waiting for first batch of jobs to finish.')
        [~,b] = system('qstat -u garcia_in');
        pause(pausetime);
    end

end