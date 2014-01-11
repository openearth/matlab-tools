function [ output_args ] = wps_runner( input_args )
%WPS_RUNNER Function that calls matlab wps processes for which it finds
%input
%   The input directory is watched and when input arrives the corresponding
%   function is called.
json.startup
% TODO add while
for i=1:10
    dirname = fullfile(pwd, '..', 'input');
    % watch for a while
    events = watch_directory(dirname, 1000);
    % something happened, let's check all input
    jsonfiles = cellstr(ls(fullfile(dirname, '*.json')));
    for j=1:length(jsonfiles)
        jsonfile = jsonfiles{j};
        data = json.read(fullfile(dirname, jsonfile));
        disp(data);
    end
end

end

