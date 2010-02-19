function [description_object,description_units] = sdn_verify(sdn)
%SDN_VERIFY   verifies a SeaDataNet ODV parameter
%
%    description = sdn_verify(sdn)
%
% verifies SeaDataNet vocabulary term from SeaDataNet ODV file header on 
% http://vocab.ndg.nerc.ac.uk webservice by extracting description from xml. 
%
% Example:
% description = sdn_verify('<subject>SDN:LOCAL:PRESSURE</subject><object>SDN:P011::PRESPS01</object><units>SDN:P061::UPDB</units>')
%
% Sometimes a term issued by SDN is not in the vocabulary (?!?), e.g.:
% not OK: http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/getRelatedRecordByTerm?subjectTerm=http://vocab.ndg.nerc.ac.uk/term/P011/current/ESSAZZ01&predicate=1&inferences=true
% not OK: http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/getRelatedRecordByTerm?subjectTerm=http://vocab.ndg.nerc.ac.uk/term/P011/current/CAPASS01&predicate=1&inferences=true
% OK      http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/getRelatedRecordByTerm?subjectTerm=http://vocab.ndg.nerc.ac.uk/term/P011/current/EWDAZZ01&predicate=1&inferences=true
%
% Please report these cases to: webmaster@bodc.ac.uk <webmaster@bodc.ac.uk>
%
%See also: OCEANDATAVIEW, NERC_VERIFY

s1 = strfind(sdn,'<subject>');
s2 = strfind(sdn,'</subject>');

o1 = strfind(sdn,'<object');
o2 = strfind(sdn,'</object>');

u1 = strfind(sdn,'<units>');
u2 = strfind(sdn,'</units>');

subject = (sdn(s1+9:s2-1));
object  = (sdn(o1+8:o2-1));
units   = (sdn(u1+7:u2-1));

description_object = nerc_verify(object(5:end)); % remove SDN:
description_units  = nerc_verify(units (5:end)); % remove SDN:
