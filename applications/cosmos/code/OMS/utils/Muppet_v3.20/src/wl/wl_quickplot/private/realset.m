function varargout=realset(varargin)
%REALSET Manipulate sets of real values.
%
%   [SetStruct,SimplifiedSetString]=REALSET(SetString)
%
%   SetString=REALSET(SetStruct)
%
%   Set2=REALSET('not',Set1)
%
%   Y=REALSET('keep',SetStruct,X)
%   Y=REALSET('clip',SetStruct,X)

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
