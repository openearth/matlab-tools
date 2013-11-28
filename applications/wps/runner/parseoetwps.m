function [wpsstruct] = parseoetwps(filename)
    [argout, argin, fcn] = parse_function_call(filename)
    
    txt = fileread(filename);
    inputs = struct();
    for i=1:length(argin)
        % scan for type of input arguments
        arg = argin{i};
        match = regexp(txt, [arg, '\s*\:\s*(?<type>\w+(/\w+)?)'], 'names');
        inputs.(arg) = match;
    end
    outputs = struct();
    for i=1:length(argout)
        % scan for type of output arguments
        arg = argout{i};
        match = regexp(txt, [arg, '\s*\:\s*(?<type>\w+(/\w+)?)'], 'names');
        outputs.(arg) = match;
    end
    
    wpsstruct = struct(...
        'identifier', fcn, ...
        'inputs', inputs,...
        'outputs', outputs ...
    );
end 