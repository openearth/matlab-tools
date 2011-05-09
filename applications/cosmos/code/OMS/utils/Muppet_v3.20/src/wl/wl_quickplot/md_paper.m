function hBorder=md_paper(cmd,varargin)
%MD_PAPER Add border to plot.
%   MD_PAPER(PAPERTYPE,BORDERTYPE) sets the appropriate page size for the
%   current figure and adds an empty border to it. Right click on the
%   border to fill in the texts via a dialog. PAPERTYPE should equal a
%   papertype supported by MATLAB followed by 'p' (portrait) or 'l'
%   (landscape), e.g. 'a4p'. BORDERTYPE should equal one of the following
%   strings
%      'none'       no border (default) just set paper size
%      '1box'       Framed figure with just one 2cm high text box and 1 cm
%                   margins at all sides.
%      '2box'       Non-framed figure with two textboxes with 3 cm margin
%                   at left side and 1 cm margins at the other sides.
%      '7box'       Framed figure with seven textboxes (classic Delft
%                   Hydraulics layout) with 1 cm margins at all sides.
%   or an explicit border structure BSTRUCT may be specified.
%                                                         |             |
%                   |             |                       |    .7box.   |
%                   |    .1box.   |         .2box.        |_________ _ _|
%                   |_____________|     ___ _________     |         |_|_|
%                   |             |    |   |         |    |_________|___|
%                   |_____________|    |___|_________|    |_________|_|_|
%
%   MD_PAPER(PAPERTYPE,BORDERTYPE,CTEXTS) does the same thing, but also
%   fills in the texts by using entries from the CTEXTS cell array of
%   strings. Right click on the border or texts to add or edit texts.
%
%   MD_PAPER(...,'OptionName1',OptionValue1,'OptionName2',OptionValue2,...)
%   uses non-default values for the specified options.
%
%   Supported options (also valid fields for border structure BSTRUCT):
%      'Margin'     [left bottom right top] margin
%      'Border'     draw border 1=yes/0=no
%      'LineWidth'  line width of borders and boxes
%      'Color'      line and text color
%
%   Additional fields for border structure BSTRUCT:
%      'Box'        matrix containing indices of textboxes
%      'HTabs'      relative widths of boxes
%                   length of the vector should match size(Box,2)
%      'HRange'     (maximum) width of all boxes together
%      'VTabs'      relative heights of boxes
%                   length of the vector should match size(Box,1)
%      'VRange'     (maximum) height of all boxes together
%      'Bold'       flags for printing text in bold font
%                   length of the vector should match the number
%                   of textboxes
%      'PlotText'   cell array containing default texts
%                   length of the vector should match the number
%                   of textboxes
%
%   hBorder = MD_PAPER('no edit',...) right click editing disabled. Use 
%   MD_PAPER('edit',hBorder) to edit the texts via a dialog.
%
%   NOTE: There are some compatibility problems with the LEGEND function.
%   When the border is added, all subplots are made slightly smaller. The
%   LEGEND function detects this and resets the subplots to their original
%   size. As a workaround use the following approach:
%
%         AX1=subplot(2,1,1);
%         x=0:.1:10; plot(x,sin(x));
%         md_paper('a4p','wl');
%         legend(AX1,'sine');
%
%
%   Backward compatibility:
%
%   MD_PAPER(PAPERTYPE) where PAPERTYPE can be either 'portrait' or
%   'landscape' adds "Deltares (date and time)" to a figure and sets the
%   page size to A4 portrait/landscape.
%
%   MD_PAPER(PAPERTYPE,'String') where PAPERTYPE can be either 'portrait'
%   or 'landscape' adds "String (date and time)" to a figure and sets the
%   page size to A4 portrait/landscape.
%
%   MD_PAPER(PAPERTYPE,'String1','String2',...) where PAPERTYPE can be
%   either 'portrait' or 'landscape' adds the 7 box border to the figure
%   and sets the page size to A4 portrait/landscape. Right click on the
%   text to edit the texts.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$



error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
