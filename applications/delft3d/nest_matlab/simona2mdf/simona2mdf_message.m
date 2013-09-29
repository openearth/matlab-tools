function simona2mdf_message(string,varargin)

% message: writes general information to screen

OPT.Close  = false;
OPT.Window = 'SIMINP2MDF Message';
OPT.n_sec  = 1;
OPT.Logo   = '';
OPT        = setproperty(OPT,varargin);

if ~isempty(OPT.Logo)
    h_warn   = msgbox(string,OPT.Window,'Custom',OPT.Logo,[],'replace');
else
     h_warn   = msgbox(string,OPT.Window,'replace');
end

delete(findobj(h_warn,'string','OK'));
uiwait(h_warn,OPT.n_sec);

if OPT.Close
    delete(h_warn);
end
