function mte_testpublish_test()

TeamCity.publishdescription('mte_descriptionhelper',...
    'EvaluateCode',true,...
    'IncludeCode',true);

y = sin(x);

TeamCity.publishresult(@mte_resulthelper);