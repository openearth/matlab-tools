% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17274 $
%$Date: 2021-05-07 21:40:31 +0200 (Fri, 07 May 2021) $
%$Author: chavarri $
%$Id: EHY_getMapModelData_construct_Zint_bed.m 17274 2021-05-07 19:40:31Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/EHY_tools/support_functions/EHY_getMapModelData_construct_Zint_bed.m $
%
%Compute the elevation of the interface of the substrate layers. 

function [Zint_bed,no_bed_layers]=EHY_getMapModelData_construct_Zint_bed_d3d(inputFile,OPT)
        
grp=char(vs_find(vs_use(inputFile,'quiet'),'DP_BEDLYR'));
if ~isempty(grp) %exists 'DP_BEDLYR'
    OPT.varName='DP_BEDLYR'; %from bed level, distance down to interface
    Data_Zint_bed=EHY_getMapModelData(inputFile,OPT(:));
    
    OPT.varName='DPS';
    Data_bl=EHY_getMapModelData(inputFile,OPT(:));

    no_interface=size(Data_Zint_bed.val,4);
    no_bed_layers=no_interface-1;
    Zint_bed=repmat(Data_bl.val,1,1,1,no_interface)-Data_Zint_bed.val; 
else
    grp=char(vs_find(vs_use(inputFile,'quiet'),'THLYR'));
    if ~isempty(grp) %exists 'THLYR'
        error('finish')
        
        OPT.varName='THLYR';
        Data_thlyr = EHY_getMapModelData(inputFile,OPT(:));
        OPT.varName='DPS';
        Data_bl = EHY_getMapModelData(inputFile,OPT(:));
        
        %No need because data is in the right order
        Data_thlyr.val  =permute(  Data_thlyr.val,[dimsInd_thlyr.time,dimsInd_thlyr.faces,dimsInd_thlyr.bed_layers]);
        Data_bl.val     =permute(     Data_bl.val,[   dimsInd_bl.time,   dimsInd_bl.faces]);

        %dims has the dimensions of a single partition, but I want all of the faces
        [no_times,no_faces,no_bed_layers]=size(Data_thlyr.val);        
        eta_subs=cumsum(Data_thlyr.val,dimsInd_thlyr.bed_layers); %distance from the bed to the bottom part of each underlayer
        Zint_bed=repmat(Data_bl.val,1,1,no_bed_layers+1)-cat(3,zeros(no_times,no_faces),eta_subs); %[time,face,bed_layer]
    else
        error('I cannot compute the elevation of the substrate layers out of thin air.')
    end
end
    
