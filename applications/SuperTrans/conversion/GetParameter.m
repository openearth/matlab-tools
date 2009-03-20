function val=GetParameter(parameters,name,varargin)
%GETPARAMETER  get parameter
%
%val=GetParameter(parameters,name,varargin)
%
%See also: 

ii   = findstrinstruct(parameters,'name',name);
val  = parameters(ii).value;
%uom_code=parameters(ii).uom_code;
facb = parameters(ii).factor_b;
facc = parameters(ii).factor_c;

if nargin==3
    unit=varargin{1};
    switch unit,
        case{'rad'}
            val=val*facb/facc;
%           val=Convert2Radians(val,uom_code,facb,facc);
    end
end
