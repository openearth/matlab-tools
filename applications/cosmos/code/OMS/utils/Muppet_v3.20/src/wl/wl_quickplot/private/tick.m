function tick(varargin)
%TICK Create ticks and ticklabels.
%   TICK(AXES,AXIS,TICKS,FORMAT,SCALING)
%   changes the tickmarks of the specified axis (a string
%   containing the characters x, y and z) of the specified
%   axes object (default the current axes). The new tickmarks
%   will be at the specified TICKS locations (default the
%   current tickmark locations) and the tickmarklocations are
%   formatted according the FORMAT string (required argument)
%   after multiplication by the SCALING factor.
%
%   The FORMAT string can be any valid FPRINTF expression
%   containing a "%-field" for the tickmark value. Other
%   options for the FORMAT string are:
%
%     * 'none' : no tickmarks (ignoring TICKS), no labels
%
%     * ''     : TICKS as specified, no labels
%
%     * 'auto' : automatic tickmarks (ignoring TICKS),
%                automatic tickmarklabels
%
%     * 'autolabel' :
%                TICKS as specified, automatic tickmark
%                formatting: '%g'
%
%     * 'degree' :
%                tickmarklabels formatted as degrees, minutes and
%                seconds
%
%     * 'longitude','latitude' :
%                same as degree with a direction character N,S,W,E
%                instead of a sign.
%
%     * 'autodate' :
%                date format automatically selected
%
%     * 'date' : date formatted ticks; requires another format
%                string:
%
%                TICK(AXES,AXIS,TICKS,'date',DATEFORMAT,SCALING)
%
%                where DATEFORMAT may contain any of the following
%                conversion characters:
%                      %N MATLAB date number,
%                      %A absolute year,
%                      %AD or %BC for automatic AD/BC indicator,
%                      %Y year,
%                      %y last two digits of the year,
%                      %Q number of quarter,
%                      %M number of month,
%                      %P number of (4 week) period within year,
%                      %W number of week,
%                      %n number of day within year,
%                      %D number of day within month,
%                      %w weekday name,
%                      %H hour based on 24 hours clock,
%                      %h hour based on 12 hours clock,
%                      %am or %pm for automatic am/pm indicator,
%                      %AM or %PM for automatic AM/PM indicator,
%                      %m minute,
%                      %s second
%                force number of characters used using standard
%                conversion specification modifiers, e.g. %2m for
%                minutes always indicated using 2 characters and
%                %2.2m to include a leading zero to fill up to two
%                characters. All numbers behave as integers (i.e.
%                identical to %i) except seconds which behaves like
%                a floating point (%f). Use %05.2s for seconds and
%                hundreth of a second with leading zero if the´
%                number of seconds is smaller than 10. Use %.0s for
%                only seconds (no fractional part). The weekday
%                specification supports %w, %1w, %2w and %3w. The
%                month specification supports %O, %1O, %3O.
%
%   TICK(...,'optionname',optionval,...)
%   The following options are supported:
%     * DecSep   Decimal separator. The value should be a single
%                character (default: .)
%     * Language Select the language used for names of months and
%                days: English, Dutch, German, French, Italian, or
%                Spanish (default: English)
%
%   Examples:
%     ax=subplot(2,2,1);
%     set(ax,'xlim',[1 32],'xscale','log')
%     tick('x',[1:3 5 7 10 15 22 32],'%2.2X')
%     tick(ax,'y','%.1f')
%
%     ax=subplot(2,2,2);
%     set(ax,'xlim',[0 10000],'ylim',[0 10000]);
%     tick('xy','%.2f km',0.001,'decsep',',')
%
%     ax=subplot(2,2,3); view(3)
%     tick(0:.25:1,'%5.2f')
%
%     ax=subplot(2,2,4);
%     set(ax,'xlim',now+[0 7]);
%     tick(gca,'x','date','%2w %D')

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
