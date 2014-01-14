function [ output_args ] = wps_runner( input_args )
%WPS_RUNNER Function that calls matlab wps processes for which it finds
%input
%   The input directory is watched and when input arrives the corresponding
%   function is called.
json.startup
% TODO add while

queue_url = 'http://192.168.178.148:5984';
queue_database = 'wps';

% Check for the latest processes
wps_processes = json.load(get_wps_processes);


for i=1:10
    % watch for a while
    jsonfiles = watch_couchdb(queue_url, queue_database);
    % select one file
    jsonfile = jsonfiles(1).url;
    % load metadata
    text = urlread(jsonfile);
    data = json.load(text);
    if isfield(data, 'identifier')
        identifier  = data.('identifier');
        disp(['Searching for ', identifier]);
        idx = find(ismember({wps_processes.identifier}, identifier));
        disp(['Found ', identifier, ' at index ', idx])
        process = str2func(identifier);
        % download attachments
        fixname = @(x) (strrep(x, '0x', '%'));
        attachments = cellfun(fixname, fieldnames(data.x_attachments), 'UniformOutput', 0);
        filenames = {};
        for j=1:length(attachments)
            attachment = attachments{j};
            filename = urldecode(attachment);
            urlwrite([jsonfile, '/', attachments{1}], filename)
            filenames{j} = filename;
        end
        % pass arguments one by one
        args = orderfields(data.dataInputs, wps_processes(idx).inputs);
        values = struct2cell(args);
        process(values{:})
        

    else
        warning(['Found file ', jsonfile, ' but it has no process field.']);
        continue
    end
    disp(data);
    end
end




