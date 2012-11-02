function [Tokens, allMOR] =readwavecon(wcfile)
%READMDF Reads the content of MOR files for Delft3D runs. 
%    [allMOR Tokens] = READMOR(morFilePath) 'MORFILEPATH' is a string with 
%    the full path of the mor file that is going to be read.
%
%    READMOR returns a cells array allMOR with the data without formatting
%    and a second cells array Tokens with the data formatted into three 
%    columns.
    
    %Read the File
    
    disp(['Attempting to open: ',wcfile]);
    [t,Hs,Tp,Wdir,ms,level,windv,winddir] = textread('p:\x0385-gs-mor\ivan\paper_4_egmond\Setup_noRun\wavecon.egm','%f%f%f%f%f%f%f%f','headerlines',3);
    
end