function mte_testpublish_test()

if datenum(version('-date')) == datenum(2009,08,12)
    TeamCity.ignore('publishing test results will not work in Matlab 2009b because of a known issue with getcallinfo');
    return;
end

TeamCity.publishdescription('mte_descriptionhelper',...
    'EvaluateCode',true,...
    'IncludeCode',true);

y = sin(x);

TeamCity.publishresult(@mte_resulthelper);