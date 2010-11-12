function ddb_plotUnibestCL(handles,opt0)

imd=strmatch('UnibestCL',{handles.Model(:).Name},'exact');

if strcmpi(opt0,'deactivate') && strcmpi(handles.ActiveModel.Name,'UnibestCL') && id==handles.ActiveDomain
    % Simply Changing Tab
    opt='deactivatebutkeepvisible';
else
    opt=opt0;
end

