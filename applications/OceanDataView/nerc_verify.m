function description = nerc_verify(nerc)
%NERC_VERIFY   verifies a vocabulary term on http://vocab.ndg.nerc.ac.uk webservice (BETA)
%
%    description = nerc_verify(nerc)
%
% verifies a vocabulary term on http://vocab.ndg.nerc.ac.uk 
% webservice by extracting description from xml. 
%
% Example:
% description = nerc_verify('P061::UPBB')
% description = nerc_verify('P011::PRESPS01')
%
% Sometimes a term issued by SeaDataNet is not in the vocabulary (?!?), e.g.:
% not OK: http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/getRelatedRecordByTerm?subjectTerm=http://vocab.ndg.nerc.ac.uk/term/P011/current/ESSAZZ01&predicate=1&inferences=true
% not OK: http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/getRelatedRecordByTerm?subjectTerm=http://vocab.ndg.nerc.ac.uk/term/P011/current/CAPASS01&predicate=1&inferences=true
% OK      http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/getRelatedRecordByTerm?subjectTerm=http://vocab.ndg.nerc.ac.uk/term/P011/current/EWDAZZ01&predicate=1&inferences=true
%
% Please report these cases to: webmaster@bodc.ac.uk <webmaster@bodc.ac.uk>
%
%See also: OCEANDATAVIEW, SDN_VERIFY, SDN2CF

% Example: 
% http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/getRelatedRecordByTerm?subjectTerm=http://vocab.ndg.nerc.ac.uk/term/P011/current/EWDAZZ01&predicate=1&inferences=true

   OPT.method       = 'web';
   OPT.create_cache = 0;
   OPT.save         = 0;
   OPT.disp         = 0;

   index            = strfind(nerc,':');
   listReference    =  nerc(         1:index(2)-2); % e.g.'P011';
   entryReference   =  nerc(index(2)+1:end       ); % e.g.'EWDAZZ01';
   listVersion      =  'current';
   pref.KeepNS      = 0;

if strcmpi(OPT.method,'web')
   
   % construct URI
   
   server           =  'http://vocab.ndg.nerc.ac.uk/';
   service          =  'term/';
   url              = [server,service,listReference,'/',listVersion,'/',entryReference];
      
   if OPT.disp;disp(url);end
   
   if OPT.save
   fname            = [mkvar(nerc) '.xml'];
                      urlwrite(url,fname);
   end
   
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

  %  if OPT.create_cache
  %     url           = ['http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/getList?recordKey=http://vocab.ndg.nerc.ac.uk/list/',...
  %                      listReference,,'/current&earliestRecord=1900-01-01T00:00:00Z'];
  %     xml           = urlread(url);
  %     pref.KeepNS   = 0;
  %     tic;
  %     D             = xml_read('P011.xml',pref);
  %     toc
  %     save([fileparts(mfilename('fullpath')) filesep listReference '.mat'],'-struct','xml'.'-v7')
  %  end

   xml              = load([fileparts(mfilename('fullpath')) filesep listReference '.mat']);
   
   for i=1:length(xml.codeTableRecord);
      if strcmpi(xml.codeTableRecord(i).entryTermAbbr,entryReference);
      break;
      end;
   end
   
   description     = xml.codeTableRecord(i).entryTerm;

end   
   


