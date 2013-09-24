function iok=ddb_check_write_extfile(handles)

iok=0;


if handles.Model(md).Input.nrboundaries>0
    iok=1;
    return
end

if ~isempty(handles.Model(md).Input.spiderwebfile)
    iok=1;
    return
end

if ~isempty(handles.Model(md).Input.windufile)
    iok=1;
    return
end

if ~isempty(handles.Model(md).Input.windvfile)
    iok=1;
    return
end

if ~isempty(handles.Model(md).Input.airpressurefile)
    iok=1;
    return
end
