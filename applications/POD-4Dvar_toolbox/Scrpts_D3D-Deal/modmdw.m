function [st] = modmdw(mdwPath,mdw)
%MODMDW Reads  and modifies the content of MDW files for Delft3D runs. 
%    MODMDW(mdwPath,tidaltimes,Wh,Tp,Wd,Wds) 'MDWFILEPATH' is a string with 
%    the full path of the mdw file that is going to be read. 'TIDALTIMES'
%    is a number with the time, in minutes with respect to the reference
%    date, in which the first wave calculation should be taken into
%    account. 'WH', 'TP', 'WD', 'WDS' are the values of the parameters for  
%    wave characterization: Wave significant height (m), wave peak period
%    (s), wave direction (deg) and wave directional spreading (-).
%
%    MODMDW returns a boolean flag: 1 for modification succesful and 0 for
%    modification unsuccesful. 

changingVARS = fields(mdw);
n = length(changingVARS);
if ~n, error('Insufficient parameters'); end

[Tokens allMDW] = readmdw([mdwPath,mdw.runID]);

% Only take Bathymetry from FLOW, the rest is crappy
for i=1:1:n
    warning off, id = getmemberid(Tokens, changingVARS{i}); warning on;
        if id
            for j=1:1:length(id), Tokens{id(j),3} = num2str(getfield(mdw,changingVARS{i})); end
            disp(['Modifying ',num2str(length(id)),' values of ', changingVARS{i}])
        else
            disp(['Variable ',changingVARS{i},' not found in the mdw File']);
        end
end

fid = fopen([mdwPath,mdw.runID],'w');
for kk = 1:length(Tokens), fprintf(fid,'%s\n',[Tokens{kk,:}]); end
st = fclose(fid);
if st~=0, warning('New mdw File was not closed'), end