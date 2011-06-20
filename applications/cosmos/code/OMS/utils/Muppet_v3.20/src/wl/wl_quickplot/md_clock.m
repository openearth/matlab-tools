function md_clock(Hclock,varargin)
%MD_CLOCK  Create a clock or calendar.
%    MD_CLOCK(AX,TYPE,TIME) creates a clock in the axes AX. Currently
%    supported clock types are
%         'analog clock'
%         'digital clock'
%         'calendar page'
%    The TIME can be specified as a MATLAB serial date number or as a time
%    vector. The default date/time is "now". Repeat the call to update the
%    clock. In subsequent calls the TYPE argument may be skipped
%    MD_CLOCK(AX,TIME).
%
%    Example
%       figure
%       AClock=subplot(3,2,[1 3]);
%       DClock=subplot(3,2,5);
%       Calendar=subplot(1,2,2);
%       md_clock(Calendar,'calendar page',now)
%       for i=1:60
%          md_clock(AClock,'analog clock',now)
%          md_clock(DClock,'digital clock',now)
%          pause(1)
%       end

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
