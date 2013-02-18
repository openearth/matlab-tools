function out=getParameterInfo(hm,par,varargin)

out=[];

npar=length(hm.parameters);

% Make cell array of all available parameters
for i=1:npar
    names{i}=hm.parameters(i).parameter(1).shortname;
end

% Find required parameter number
ipar=strmatch(lower(par),lower(names),'exact');

s=hm.parameters(ipar).parameter(1);

if length(varargin)==1   
    out=s.(varargin{1});
else
    k=0;
    for i=1:2:length(varargin)-1
        k=k+1;
        ptype2{k}=varargin{i};
        pname{k}=varargin{i+1};
    end

    par=varargin{end};

    nrp=k;

    for i=1:nrp
        switch lower(ptype2{i})
            case{'source'}
                ptype1{i}='sources';
            case{'model'}
                ptype1{i}='models';
            case{'datatype'}
                ptype1{i}='datatypes';
            case{'plot'}
                ptype1{i}='plots';
        end
    end

    switch nrp

        case 1

            for j=1:length(s.(ptype1{1}))
                nm{j}=s.(ptype1{1})(j).(ptype2{1}).type;
            end
            ii=strmatch(lower(pname{1}),lower(nm),'exact');
            
            if ~isempty(ii)           
                out=s.(ptype1{1})(ii).(ptype2{1}).(par);
            end
            
        case 2

            nm=[];
            for j=1:length(s.(ptype1{1}))
                nm{j}=s.(ptype1{1})(j).(ptype2{1}).type;
            end
            ii=strmatch(lower(pname{1}),lower(nm),'exact');

            if ~isempty(ii)
                
                nm=[];
                for j=1:length(s.(ptype1{1})(ii).(ptype2{1}).(ptype1{2}))
                    nm{j}=s.(ptype1{1})(ii).(ptype2{1}).(ptype1{2})(j).(ptype2{2}).type;
                end
                jj=strmatch(lower(pname{2}),lower(nm),'exact');
                
                try
                out=s.(ptype1{1})(ii).(ptype2{1}).(ptype1{2})(jj).(ptype2{2}).(par);
                catch
                    shite=1
                end
            end
            
    end
end
