function [st] = modmor(morPath,mor)
%MODBCC Reads and modifies the content of MOR files for Delft3D runs. 
%    MODMOR(morPath, NameVar1,ValVar1,NameVar2,ValVar2, ... ) 'BCCPATH' 
%    is a string with the full path of the mor file that is going to be
%    modified. NAMEVAR* is a string with the name of the variable that is
%    going to be modified, as it is found in the MOR file. VALVAR* is the
%    corresponding value of the variable NAMEVAR* that wants to be
%    modified.
%
%    MODBCC returns a boolean flag: 1 for modification succesful and 0 for
%    modification unsuccesful.

changingVARS = fields(mor);
n = length(changingVARS);
if ~n, error('Insufficient parameters'); end

%Modify Morphological file (NO spin up!!)
[Tokens allMOR] = readmor([morPath,mor.runID]);

for i=1:1:n
    warning off, id = getmemberid(Tokens, changingVARS{i}); warning on;
    if id 
        Tokens{id,3} = num2str(getfield(mor,changingVARS{i}));
        disp(['Modifying ', changingVARS{i}])
    else
        disp(['Variable ',changingVARS{i},' not found in the mor File']);
    end
end

% Write to MOR file
fid = fopen([morPath,mor.runID],'w');
for kk = 1:length(Tokens), 
    fprintf(fid,'%-20s',[Tokens{kk,1}]);
    fprintf(fid,'%-2s',[Tokens{kk,2}]);
    fprintf(fid,'%-15s',[Tokens{kk,3}]);
    fprintf(fid,'%-100s\n',[Tokens{kk,4}]);
end
st = fclose(fid);
if st~=0, warning('New mor File was not closed'), end