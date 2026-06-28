%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Hash a string

function string_output=hash_string(string_input)
md=java.security.MessageDigest.getInstance('MD5');
md.update(uint8(string_input));
hash_hex=reshape(dec2hex(typecast(md.digest,'uint8'))',1,[]);
string_output=lower(hash_hex(1:6));
end %function