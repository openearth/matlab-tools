function out=D3DTimeString(in,varargin)

if nargin==1
    if ischar(in)
        a=strread(in);
        year=a(1);
        month=a(2);
        day=a(3);
        if length(a)==6
            hour=a(4);
            minute=a(5);
            second=a(6);
        else
            hour=0;
            minute=0;
            second=0;
        end
        out=datenum(year,month,day,hour,minute,second);
    else
%        out=datestr(in,'yyyy mm dd HH MM SS');
        out=datestr(in,'yyyymmdd HHMMSS');
    end
else
    switch(lower(varargin{1}))
        case{'itdatemdf'}
            out=datestr(in,'yyyy-mm-dd');
        case{'itdate'}
            out=datestr(in,'yyyy mm dd');
        case{'yyyymmdd hhmmss'}
            out=datenum(in,'yyyymmdd HHMMSS');
    end        
end
