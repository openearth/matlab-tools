function [mdwsetup] = getmdwinfo(mdwPath)
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


    if (mdwPath(end-3)~='.'), mdwPath = [mdwPath,'.mdw']; end    
    mdw=textread(mdwPath,'%s','delimiter',char(10),'whitespace','');

    % Only take Bathymetry from FLOW, the rest is crappy
    id = getmemberid(mdw,'* Y/N Use bathmetry, use waterlevel, use current, use wind');   
    [mdwsetup.flowBath,mdwsetup.flowWL,mdwsetup.flowCurr,mdwsetup.flowWind] = strread(mdw{id+1},'%n%n%n%n','delimiter',' ');
        
    %Modify wave parameters
    id = getmemberid(mdw,'* Significant wave height');
    [mdwsetup.Wh,mdwsetup.Tp,mdwsetup.Wd,mdwsetup.Wds] = strread(mdw{id+1},'%n%n%n%n','delimiter',' ');
            
    %Modify wave parameters
    
    id = getmemberid(mdw,'* Output time interval');
    [mdwsetup.level_test_output, ...
     mdwsetup.debug_level, ...
     mdwsetup_compute_waves, ...
     mdwsetup.activate_hotstart, ...
     mdwsetup.wavesavestep, ...
     mdwsetup.computational_mode] = strread(mdw{id+1},'%n%n%n%n%n%n','delimiter',' ');
    
    id = getmemberid(mdw,'* Frequency space: lowest frequency, highest frequency, number of frequency bins');
    for igrid = 1:1:length(id), 
        [mdwsetup.lowest_freq(igrid), ...
         mdwsetup.highest_freq(igrid), ...
         mdwsetup.numfreq_bins(igrid), ...
         mdwsetup.grid2nest_in(igrid), ...
         mdwsetup.savewave(igrid)] = strread(mdw{id(igrid)+2},'%n%n%n%n%n','delimiter',' ');
    end