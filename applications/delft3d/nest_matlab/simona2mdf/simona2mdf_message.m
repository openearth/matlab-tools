function simona2mdf_message(varargin)

% message: writes general information to screen

close = false;
if nargin == 0
    string = '';
    n_sec  =  1;
    h_warn = msgbox(string,'SIMINP2MDF Message','replace');
    close  = true;
else
    OPT.Name = 'SIMINP2MDF Message';
    if nargin > 4
        OPT      = setproperty(OPT,varargin{4:end});
    end
    string   = varargin{1};
    logo     = varargin{2};
    n_sec    = varargin{3};
    h_warn   = msgbox(string,OPT.Name,'Custom',logo,[],'replace');
end

delete(findobj(h_warn,'string','OK'));
uiwait(h_warn,n_sec);

if close
    delete(h_warn);
end


