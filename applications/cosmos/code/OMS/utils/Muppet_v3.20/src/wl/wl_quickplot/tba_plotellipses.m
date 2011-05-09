function h = tba_plotellipses(tba,comp,varargin)
%TBA_PLOTELLIPSES Plot tidal ellipses from Delft3D-TRIANA TBA file.
%   TBA_PLOTELLIPSES(TBA,COMPONENT,SOURCE) plots tidal ellipses based on
%   data from the specified TBA file for the specified COMPONENT and source
%   specified as 'computed' or 'observed'. The source parameter may be
%   dropped in which case the default 'computed' is used. The COMPONENT
%   should match one of the components such as 'K1' or 'M2' specified in
%   the TBA file. The TBA structure can be obtained from TEKAL2TBA.
%
%   H = TBA_PLOTELLIPSES(...) returns a handle to the created line object.
%
%   TBA_PLOTELLIPSES(...,Prop1,Value1,Prop2,Value2,...) sets an additional
%   set of optional property values. For supported properties see
%   PLOT_TIDALELLIPSES.
%
%   Example
%      TKL = tekal('open',FILENAME);
%      TBA = tekal2tba(TKL);
%      tba_plotellipses(TBA,'M2');
%      xlabel('x coordinate \rightarrow')
%      ylabel('y coordinate \rightarrow')
%      title('M2')
%
%   See also PLOT_TIDALELLIPSES, TBA_COMPARE, TEKAL2TBA.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
