function [DomainNr,Props,subf,selected,stats,Ops]=qp_interface_update_options(mfig,UD);
%QP_INTERFACE_UPDATE_OPTIONS Update QuickPlot user interface options.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
