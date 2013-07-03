function prob_print_test(result)

ST = dbstack;

fprintf('\n');
if ~isscalar(ST)
    fprintf('%s\n', ST(2).name);
end
fprintf('%10s', 'Method', 'Beta', 'Error', 'P_f', 'Error %','Calc');
fprintf('\n');

f = fieldnames(result);
for i = 1:length(f)
    if strcmpi(f{i},'Exact')
        err = 0;
        err_P_f = 0;
        fprintf('%10s%10.2f%10.2f%10.2d%10.2f%10.0f\n', f{i}, result.(f{i}).Beta, ...
            err, result.(f{i}).P_f, err_P_f,0);
    else
        err = result.(f{i}).Output.Beta-result.Exact.Beta;
        err_P_f = (result.(f{i}).Output.P_f-result.Exact.P_f)/result.Exact.P_f*100;
        fprintf('%10s%10.2f%10.2f%10.2d%10.2f%10.0f\n', f{i}, result.(f{i}).Output.Beta, ...
            err, result.(f{i}).Output.P_f , err_P_f, result.(f{i}).Output.Calc);
    end
end