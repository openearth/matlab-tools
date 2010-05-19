%XML_SAVE  saves Matlab variables and data structures as XML
%
% SYNTAX
%               xml_save( filename, var )
%               xml_save( filename, var, attswitch )
% INPUT
%   filename     filename
%   var          Matlab variable or structure to store in file.
%   attswitch    optional, 'on' stores XML type attributes (default),
%               'off' doesn't store XML type attributes
%
% NOTE: Matlab data stored with the 'on' attribute (default) can be reloaded
%       in its original form into Matlab with the XML_LOAD command.
%
% OUTPUT
%   none
%
% RELATED
%   xml_load, xml_format, xml_formatany, xml_parse, xml_parseany, xml_help, (xmlread, xmlwrite)
 
% Copyright (C) 2002-2005, University of Southampton
% Author: Dr Marc Molinari <m.molinari@soton.ac.uk>
% $Revision: 2568 $ $Date: 2009-11-12 15:27:10 +0100 (Thu, 12 Nov 2009) $ $Tag$
 
