function simona2mdf_message(string,varargin)

% message: writes general information to screen
OPT.nesthd_path = getenv('nesthd_path');
OPT.Close       = false;
OPT.Window      = 'SIMINP2MDF Message';
OPT.n_sec       = 1;
OPT = setproperty(OPT,varargin{end-1:end});

if ~isempty(OPT.nesthd_path);
    OPT.Logo        = imread([OPT.nesthd_path filesep 'bin' filesep 'simona_logo.jpg']);
    OPT.Logo2       =        [OPT.nesthd_path filesep 'bin' filesep 'deltares.gif'];
else
    OPT.Logo   = '';
    OPT.Logo2  = '';
end

OPT        = setproperty(OPT,varargin);

if ~isempty(OPT.Logo)
    h_warn   = msgbox(string,OPT.Window,'Custom',OPT.Logo,[],'replace');
else
     h_warn   = msgbox(string,OPT.Window,'replace');
end

if ~isempty(OPT.Logo2)
   simona2mdf_legalornot(h_warn,OPT.Logo2)
end

delete(findobj(h_warn,'string','OK'));
uiwait(h_warn,OPT.n_sec);

if OPT.Close
    close (h_warn);
    pause (1);
end
