function C = strtokens2cell(STR)
%C = strtokens2cell(STR)
%
% rewrites space delimitered keyword list to cell array
% example:
%
% C = strtokens2cell('a b')
% gives C a sin
% C{1}='a';C{2}='b'
%
% © G.J. de Boer, TU Delft, Oct. 2006.
%
% See also: STRTOK, EXPRESSIONSFROMSTRING

rest_of_STR = STR;
no_of_tok   = 0;

while ~(length(deblank(rest_of_STR))==0)
   [tok, rest_of_STR]  = strtok(rest_of_STR);
   no_of_tok           = no_of_tok + 1;
   C{no_of_tok}        = tok;
end   