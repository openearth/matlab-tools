function [varargout] = modmdf(mdfPath,mdf) %(MDFpathIN,MDFpathOUT, changingVARS)
%MODMDF Modifies the content of MDF files for Delft3D runs. 
%    [allMDF Tokens] = MODMDF(mdfFilePath,FinalMDFpath,'VAR1','VAR1_VALUE','VAR2','VAR2_VALUE',...)
%    'MDFFILEPATH' is a string with the full path to the mdf file that is
%    going to be modified. 'FINALMDFPATH' is the path to which the
%    modified mdf file will be saved. 'VAR' and 'VAR_VALUE' should be 
%    strings and should always be supplied as couples. 
%
%    MODMDF returns a cells array with the same characteristics as mdfFile
%    provided.

changingVARS = fields(mdf);
n = length(changingVARS);
if ~n, error('Insufficient parameters'); end

[Tokens allMDF] = readmdf([mdfPath,mdf.runID]);

id_rest = getmemberid(changingVARS,'Restid');
if id_rest
   
    id = getmemberid(Tokens,'Restid');
    if id
        Tokens{id,3} = num2str(['#',getfield(mdf,changingVARS{id}),'#']); %It is preconfigured, you must only change the name of the file
    else                                                                    %Hay que hacer modificaciones... las lineas hay moverlas
        %We don't need this line anymore
        id = getmemberid(Tokens,'Zeta0');
        if ~isempty(id), Tokens(id,:) = []; end

        %We don't need this line anymore
        id = getmemberid(Tokens,'C01');
        if ~isempty(id), Tokens(id,:) = []; end
        
        %We now specify the restart source file.
        Tokens(end+1,:) = {'Restid',' = ',['#',getfield(mdf,changingVARS{id_rest}),'#']};
    end
    changingVARS(id_rest) = [];
    n=n-1;
end
clear id_rest
warning on

for i=1:1:n
    warning off
    id = getmemberid(Tokens, changingVARS{i});
    warning on

    if id,
        Tokens{id,3} = num2str(getfield(mdf,changingVARS{i}));
        disp(['Modifying ', changingVARS{i}])
    else
        disp(['Variable ',changingVARS{i},' not found in the mdf File']);
    end
end

% Write to file
fid = fopen([mdfPath,mdf.runID],'w');
for kk = 1:1:length(Tokens), fprintf(fid,'%s\n',[Tokens{kk,:}]); end
st = fclose(fid);
if st~=0, warning('New mdf File was not closed'), end

if nargout == 2, varargout{1} = Tokens; varargout{2} = allMDF; 
elseif nargout > 0, warning('MODMDF returns two objects: (1) The MDF tokens and (2) All the MDF'); end