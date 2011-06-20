function [varargout]=qp_getdata(varargin)
%QP_GETDATA General interface for various data files
%   [Success,Dimensions]            = QP_GETDATA(FI,'dimensions')
%   [Success,Locations ]            = QP_GETDATA(FI,'locations')
%   [Success,Quantities]            = QP_GETDATA(FI,'quantities')
%   [Success,Data      ,NewFI]      = QP_GETDATA(FI,'data',Quantity,DimSelection)
%
%   [Success,Domains   ]            = QP_GETDATA(FI,'domains')
%   [Success,DataProps ]            = QP_GETDATA(FI,Domain)
%   [Success,DataProps ]            = QP_GETDATA(FI,Domain,DimMask)
%   [Success,DataFields,Dims ,NVal] = QP_GETDATA(FI,Domain)
%   [Success,DataFields,Dims ,NVal] = QP_GETDATA(FI,Domain,DimMask)
%   [Success,Size      ]            = QP_GETDATA(FI,Domain,DataFld,'size')
%   [Success,Times     ]            = QP_GETDATA(FI,Domain,DataFld,'times')
%   [Success,Times     ]            = QP_GETDATA(FI,Domain,DataFld,'times',T)
%   [Success,StNames   ]            = QP_GETDATA(FI,Domain,DataFld,'stations',S)
%   [Success,SubFields ]            = QP_GETDATA(FI,Domain,DataFld,'subfields',F)
%   [Success,Data      ,NewFI]      = QP_GETDATA(FI,Domain,DataFld,'data',subf,t,station,m,n,k)
%   [Success,Data      ,NewFI]      = QP_GETDATA(FI,Domain,DataFld,'celldata',subf,t,station,m,n,k)
%   [Success,Data      ,NewFI]      = QP_GETDATA(FI,Domain,DataFld,'griddata',subf,t,station,m,n,k)
%   [Success,Data      ,NewFI]      = QP_GETDATA(FI,Domain,DataFld,'gridcelldata',subf,t,station,m,n,k)
%
%   The DataFld can be either a unique datafield name or an element of
%   the DataProps structure. The Domain parameter is optional and will
%   only be used if the function call to QP_GETDATA(FI,'domains')
%   returns a non-empty cell array. The subf(ield) parameter should only
%   be specified if and only if the call 'subfields' returns a non-empty
%   result.

%
%   Extra function calls for QuickPlot.
%
%      [Success]                       = QP_GETDATA(FI,'options',OptionsFigure,'initialize')
%      [Success,NewFI     ,cmdargs]    = QP_GETDATA(FI,'options',OptionsFigure,OptionsCommand, ...)
%      [Success,hNew      ,NewFI]      = QP_GETDATA(FI,Domain,DataFld,'plot',Parent,Ops,subf,t,station,m,n,k)

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%
% Initialize output array. Set the Success flag to 0.
%

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
