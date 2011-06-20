function updateuicontrols
%UPDATEUICONTROLS Force an update of the uicontrol properties.
%   Force an update of the uicontrol properties. The uicontrol properties
%   are normally not updated before a menu callback is executed. This
%   function forces an update by removing the focus from the uicontrol by
%   opening and closing a new figure.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
