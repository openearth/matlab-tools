function [ output_args ] = run( input_args )
%WPS_RUNNER Function that calls matlab wps processes for which it finds
%input. The input directory is watched and when input arrives the 
% corresponding function is called.
%
%See also: https://publicwiki.deltares.nl/display/OET/Matlab+WPS+convention

json.startup
% TODO add while
queue_url = 'http://ol-ws003.xtr.deltares.nl:5984'; % test server
queue_url = 'http://localhost:5984';
queue_database = 'wps';

%% Check for the latest processes
text = wps.runner.get_processes();
processes = json.load(text);
disp('wps processes loaded')
for i=1:length(processes)
    disp([num2str(i), ' identifier: ',processes(i).identifier])
    disp(var2evalstr(processes(i)))
end

%% publish processes
% get list of processes for matlab,
% overwrite with current list
view = 'matlab';
url = sprintf('%s/%s/_design/views/_view/%s', queue_url, queue_database, view);
table = json.load(urlread(url));
if isempty(table.rows)
    uuids = json.load(wps.runner.urlread2(sprintf('%s/_uuids', queue_url)));
    uuid = uuids.uuids{1};
    doc = struct(... 
        'processes', processes, ...
        'language', 'matlab', ...
        'type', 'processes' ...
        );
    url = sprintf('%s/%s/%s', queue_url, queue_database, uuid);
    text = json.dump(doc);
    wps.runner.urlread2(url, 'PUT', text)
    %add a new doc
else
    % lookup existing doc
    if iscell(table.rows)
        doc = table.rows{1}.value;
    else
        doc = table.rows(1).value;
    end
    % Update the processes
    doc.processes = processes;
    text = json.dump(doc);
    url = sprintf('%s/%s/%s', queue_url, queue_database, doc.x_id)
    wps.runner.urlread2(url, 'PUT', text);
end
% urlwrite()

%% Start processing
while 1
    % watch for a while
    jsonfiles = wps.runner.watch_couchdb(queue_url, queue_database);
    % select one file
    % the queue is empty
    if isempty({jsonfiles.url}) || all(cellfun(@isempty, {jsonfiles.url})) %any(isempty({jsonfiles.url}))
        % wait 2 seconds before we try again
        fprintf('.');
        pause(2)
        continue
    end
    % pop  a job    
    jsonfile = jsonfiles(1).url;
    % load metadata
    text = urlread(jsonfile);
    data = json.load(text);
    if isfield(data, 'identifier')
        identifier  = data.('identifier');
        disp(['Searching for ', identifier]);
        idx = find(ismember({processes.identifier}, identifier));
        disp(['Found ', identifier, ' at index ', idx])
        process = str2func(['wps.processes.',identifier]);
        % download attachments
        fixname = @(x) (strrep(x, '0x', '%'));
        if isfield(data, 'x_attachments')
            attachments = cellfun(fixname, fieldnames(data.x_attachments), 'UniformOutput', 0);
        else
            attachments = {}
        end
        filenames = {};
        for j=1:length(attachments)
            attachment = attachments{j};
            filename = urldecode(attachment);
            urlwrite([jsonfile, '/', attachments{1}], filename)
            filenames{j} = filename;
        end
        % pass arguments one by one
        for j=1:length(data.inputs.datainputs)
            item = data.inputs.datainputs(j);
            data.dataInputs.(item.identifier) = item.value;
        end
        args = orderfields(data.dataInputs, processes(idx).inputs);
        values = struct2cell(args);
        % now we can call the process
        result = process(values{:})
        
        % store the result
        data.result = result;
        data.type = 'output';
        url = sprintf('%s/%s/%s', queue_url, queue_database, data.x_id);
        text = json.dump(data);
        wps.runner.urlread2(url, 'PUT', text)

    else
        warning(['Found file ', jsonfile, ' but it has no process field.']);
        continue
    end
    disp(data);
end




