function Fg0=progressbar(varargin)
%PROGRESSBAR Display progress bar.
%   This function is an alternative for the wait
%   bar function of MATLAB. This implementation
%   is somewhat faster and displays progress in
%   titlebar as well.
%
%   H=PROGRESSBAR(X)
%   Creates a progress bar of fractional length X
%   (if no progress bar exists), or updates the
%   last created progress bar.
%
%   PROGRESSBAR(X,H)
%   Updates progress bar H to fractional length X.
%
%   ...,'title',String)
%   Set title of progressbar to specified string.
%
%   ...,'color',Color)
%   Set color of progressbar to specified color.
%
%   ...,'cancel',CancelFcn)
%   Activate cancel button (and close window button)
%   and execute CancelFcn when clicked. If CancelFcn
%   is empty, deactivate cancel function.
%
%   H=PROGRESSBAR(...)
%   Returns the handle of the progress bar.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
