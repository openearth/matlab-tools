pow             = 3;

OPT             = function_keyword_value_pairs
OPT.keyword1    = pow;

 y              = function_keyword_value_pairs(3,OPT)
[y,status]      = function_keyword_value_pairs(3,OPT)
[y,status,OPT2] = function_keyword_value_pairs(3,OPT)


 y              = function_keyword_value_pairs(3,'keyword1',pow)
[y,status]      = function_keyword_value_pairs(3,'keyword1',pow)
[y,status,OPT2] = function_keyword_value_pairs(3,'keyword1',pow)