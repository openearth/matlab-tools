%WATCH_DIRECTORY watch directory for file changes
%
% When the file system supports it, this function will listen to the
% dirname directory for new, modified and deleted files. This is done using the
% java nio api, which is only supported in java 1.7 and up, os it will not
% work for all matlab versions. Once an event is generated the function
% returns the event and possibly other events at the same time, the function then
% stops watching the directory. 
%
% syntax:
% [jsonfiles] = watch_couchdb(server, database)
%
% input:
% server = a couchdb server to watch
% wps = the database that contains the documents
%
% output:
% jsonfiles = a structure array of struct(url='server/db/uuid', rev='uuid')
%
% example:
% watch_directory(fullfile(pwd, '.'), 1000)
%
% See also: fullfile, ls

function [jsonfiles] = watch_couchdb(server, database)
 % get the documents
    text = urlread2(sprintf('%s/%s/%s', server, database, '_all_docs'));
    docs = json.load(text);
    jsonfiles = struct('url', [], 'rev', []);
    for i=1:length(docs.rows)   
        if iscell(docs.rows)
            % sometimes it's a cell
            row = docs.rows{1};
        else
            % and sometimes it's not
            row = docs.rows(1);
        end
        url = sprintf('%s/%s/%s', server, database, row.id);
        rev = row.value.rev;
        jsonfiles(i).url = url;
        jsonfiles(i).rev = rev;
    end
    
end