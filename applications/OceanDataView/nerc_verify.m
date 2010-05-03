function description = nerc_verify(nerc)
%NERC_VERIFY   verifies a vocabulary term on http://vocab.ndg.nerc.ac.uk webservice (BETA)
%
%    description = nerc_verify(nerc)
%
% verifies a vocabulary term on http://vocab.ndg.nerc.ac.uk 
% webservice by extracting the description from the xml.
%
% nerc can either be the full http vocab address
%
%    description = nerc_verify('http://vocab.ndg.nerc.ac.uk/term/P061/current/UPBB')
%    description = nerc_verify('http://vocab.ndg.nerc.ac.uk/term/P011/current/PRESPS01')
%
% or a the relevant part of a SeaDataNet code
%
%    description = nerc_verify('P061::UPBB')
%    description = nerc_verify('P011::PRESPS01')
%
%
% Please report these cases to: webmaster@bodc.ac.uk <webmaster@bodc.ac.uk>
%
%See also: OCEANDATAVIEW, SDN_VERIFY, SDN2CF, P011

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   OPT.method       = 'loc'; % 'loc' is much faster than 'web'
   OPT.create_cache = 0;
   OPT.save         = 0;
   OPT.disp         = 0;

%% peel name

   if strcmpi(nerc(1:7),'http://')
   
      % copy URI

      url = nerc;
      
   else
   
      index            = strfind(nerc,':');
      listReference    =  nerc(         1:index(2)-2); % e.g.'P011';
      entryReference   =  nerc(index(2)+1:end       ); % e.g.'EWDAZZ01';
      listVersion      =  'current';

      % construct URI
      
      server           =  'http://vocab.ndg.nerc.ac.uk/';
      service          =  'term/';
      url              = [server,service,listReference,'/',listVersion,'/',entryReference];
      
      if OPT.disp;disp(url);end

   end

%% get description

if strcmpi(OPT.method,'web') | strcmpi(nerc(1:7),'http://')
   
   if OPT.save
   fname            = [mkvar(nerc) '.xml'];
                      urlwrite(url,fname);
   end
   
   pref.KeepNS      = 0;
   D                = xml_read(url,pref);
   if isfield(D,'Concept')
   description      = D.Concept.prefLabel;
   else
   description      = 'error';
   end
   
   if OPT.disp
   disp(description)
   disp(' ')
   end
   
elseif strcmpi(OPT.method,'loc')

   description  = P011('description',entryReference,'listReference',listReference);
   
end   
   


