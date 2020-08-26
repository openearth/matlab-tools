function fixPythonPath(anacondaFolder)
    % Fix path problems when calling Anaconda Python from Matlab
    %
    % Inputs: 
    % - anacondaFolder: Typically 'C:\Anaconda3' or similar

    % First fix pyversion if need be
    [~,pyExec,]=pyversion;
    if isempty(pyExec)
        pyversion([anacondaFolder '\python.exe']);
    end
    try 
        py.list({2});
    catch
        error('Basic Python could not be called. Problem lies not with Python path.');
    end
    
    try
        py.numpy.sqrt(2);
        warning('Numpy could already be called. So the Python path was not a problem.');
        return;
    end
    
    pathAdd = [';' anacondaFolder ';' anacondaFolder '\Library\mingw-w64\bin;' anacondaFolder '\Library\usr\bin;' anacondaFolder '\Library\bin;' anacondaFolder '\Scripts'];
    setenv('PATH', [getenv('PATH') pathAdd]);
    
    try
        py.numpy.sqrt(2);
        fprintf('Python path fixed.\n');
    catch
        warning('Python path still not fixed.\n');
    end
    
end