function evalinemptyworkspace(str)
setappdata(0,'emptyworkspaceevaluation',str);
eval_fun();
rmappdata(0,'emptyworkspaceevaluation');
end

function eval_fun()
eval(getappdata(0,'emptyworkspaceevaluation'));
end