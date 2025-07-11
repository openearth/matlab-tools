%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20235 $
%$Date: 2025-07-07 14:32:25 +0200 (Mon, 07 Jul 2025) $
%$Author: chavarri $
%$Id: D3D_gdm.m 20235 2025-07-07 12:32:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Encrypts or decrypts a string with XOR and hex encoding
%
%E.G.:
% a=encrypt_string('this is a test','V','encrypt');
% b=encrypt_string(a,'V','decrypt');

function result = encrypt_string(text, key, mode)

%% PARSE

if nargin < 3
    error('Usage: encrypt_string(text, key, mode)');
end

%% CALC

keyBytes = uint8(key);
keyLen = length(keyBytes);

switch lower(mode)
    case 'encrypt'
        cipherBytes=apply_bitxor(text,keyBytes,keyLen);
        
        %convert to hex string
        result = dec2hex(cipherBytes)';
        result = result(:)'; % row vector
    case 'decrypt'
        %check
        if mod(length(text),2) ~= 0
            error('Invalid cipher text length');
        end
        %convert hex string back to bytes
        text_dec=hex2dec(reshape(text,2,[])');

        plainBytes=apply_bitxor(text_dec,keyBytes,keyLen);

        result=char(plainBytes)';
    otherwise
        error('Mode must be ''encrypt'' or ''decrypt''');
end

end %function

%%
%% FUNCTIONS
%%

function cipherBytes=apply_bitxor(text,keyBytes,keyLen)

textBytes=uint8(text);
cipherBytes = zeros(size(textBytes), 'uint8');
for i = 1:length(textBytes)
    cipherBytes(i) = bitxor(textBytes(i), keyBytes(mod(i-1, keyLen)+1));
end

end %function