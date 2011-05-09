function font=qp_fontsettings(fontstr)
%QP_FONTSETTINGS Convert between INI file font settings and font structures.

%   Copyright 2000-2008 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

flds={'Angle','Name','Units','Size','Weight'};
font='';
if ischar(fontstr)
    %
    % Define a font structure using fontstr as prefix and using the settings
    % in the INI file managed by qp_settings for the various properties.
    % Example: fontstr can be 'DefaultUicontrolFont'
    %
    font=[];
    for i=1:length(flds)
        str=flds{i};
        font = setfield(font,[fontstr str],qp_settings(['UIFont' str]));
    end
    %if isequal('DefaultUicontrolFont',fontstr)
    %   font.DefaultUicontrolForegroundColor='w';
    %   font.DefaultUicontrolBackgroundColor='b';
    %end
else
    %
    % Store the various properties/fields of the font structure in the INI
    % file managed by qp_settings.
    %
    for i=1:length(flds)
        str=flds{i};
        qp_settings(['UIFont' str],getfield(fontstr,['Font' str]))
    end
end
