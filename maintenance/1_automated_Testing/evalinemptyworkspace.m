function evalinemptyworkspace(str)
setappdata(0,'emptyworkspaceevaluation',str);
eval_fun();
if isappdata(0,'emptyworkspaceevaluation')
    % the string in the evaluation probably also involves a call to evalinemptyworkspace. Therefore
    % the appdata is already removed.
    return;
end
rmappdata(0,'emptyworkspaceevaluation');
end

function eval_fun()
eval(getappdata(0,'emptyworkspaceevaluation'));
end