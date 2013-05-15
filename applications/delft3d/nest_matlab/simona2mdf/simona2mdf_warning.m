function simona2mdf_warning(warningtext)

% warning: displays a simona2mdf warning

nesthd_path = getenv('nesthd_path');
logo        = imread([nesthd_path filesep 'bin' filesep 'simona_logo.jpg']);

h_warn      = msgbox(warningtext,'SIMINP2MDF Warning','custom',logo);
delete(findobj(h_warn,'string','OK'));
waitfor(h_warn);
