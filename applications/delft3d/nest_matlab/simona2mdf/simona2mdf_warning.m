function simona2mdf_warning(warningtext)

% warning: displays a simona2mdf warning

nesthd_path = getenv('nesthd_path');
logo        = imread([nesthd_path filesep 'bin' filesep 'simona_logo.jpg']);

timnow = now;

h_warn      = msgbox(warningtext,'SIMINP2MDF Warning','custom',logo);
delete(findobj(h_warn,'string','OK'));

if ~ishandle(h_warn)
    uiresume;
end

uiwait(h_warn,20);

if ishandle(h_warn);
    set(h_warn,'Visible','off');
    delete(h_warn);
end