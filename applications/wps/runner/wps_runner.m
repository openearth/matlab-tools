function [ output_args ] = wps_runner( input_args )
%WPS_RUNNER Function that calls matlab wps processes for which it finds
%input
%   The input directory is watched and when input arrives the corresponding
%   function is called.

% TODO add while
for i=1:1
    dirname = fullfile(pwd, '..', 'input');
    % TODO, add while
    events = watch_directory(dirname, 1000);
    % just check the whole directory
    jsonfiles = ls(fullfile(dirname, '*.json'));
end

end

