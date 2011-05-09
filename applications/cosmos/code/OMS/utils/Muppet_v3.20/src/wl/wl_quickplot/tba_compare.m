function h = tba_compare(tba,comp,qnt,varargin)
%TBA_COMPARE Plot computed versus observed tidal analysis data.
%   TBA_COMPARE(TBA,COMPONENT,QUANTITY) plots the tidal component for the
%   specified quantity from the analysed computed data against the observed
%   component.
%
%   H = TBA_COMPARE(...) returns a handle to the created line object.
%
%   TBA_COMPARE(...,Prop1,Value1,Prop2,Value2,...) sets an additional
%   set of optional line property values.
%
%   Example
%      TKL = tekal('open',FILENAME);
%      TBA = tekal2tba(TKL);
%      tba_compare(TBA,'M2','water levels','marker','+');
%
%   See also TBA_PLOTELLIPSES, TEKAL2TBA.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
