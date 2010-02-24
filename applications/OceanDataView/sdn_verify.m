function [description_object,description_units] = sdn_verify(sdn)
%SDN_VERIFY   verifies a SeaDataNet ODV parameter
%
%    description = sdn_verify(sdn)
%
% verifies SeaDataNet vocabulary term from SeaDataNet ODV file header on 
% http://vocab.ndg.nerc.ac.uk webservice by extracting description from xml. 
% SDN_VERIFY gets the descriptions for these tags:
%
%  <object></object>    quantity
%  <units></units>      units
%  <subject></subject>  disregafred.
%
% Example:
%
% [long_name_quantity,...
%  long_name_units] = sdn_verify('<subject>SDN:LOCAL:PRESSURE</subject><object>SDN:P011::PRESPS01</object><units>SDN:P061::UPDB</units>')
%
% [long_name_quantity,...
%  long_name_units] = sdn_verify('<object>SDN:P011::PRESPS01</object><units>SDN:P061::UPDB</units>')
%
%See also: OCEANDATAVIEW, NERC_VERIFY, SDN2CF

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

%% EOF