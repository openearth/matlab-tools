function val=Convert2Radians(val,code,facb,facc)
%CONVERT2RADIANS  convert 2 radians
%
% val=Convert2Radians(val,code,facb,facc)
%
%See also:

val=val*facb/facc;

switch code,
    case 9107
    case 9108
    case 9110
    case 9111
    case 9115
    case 9116
end
