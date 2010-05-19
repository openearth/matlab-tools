function handles=ddb_dnami_compFline(handles)
%
% ------------------------------------------------------------------------------------
%
%
% Function:     ddb_dnami_compFline.m
% Version:      Version 1.0, March 2007
% By:           Deepak Vatvani
% Summary:
%
% Copyright (c) WL|Delft Hydraulics 2007 FOR INTERNAL USE ONLY
%
% ------------------------------------------------------------------------------------
%
% Syntax:       output = function(input)
%
% With:
%               variable description
%
% Output:       Output description
%



degrad=pi/180;
raddeg=180/pi;
rearth= 6378137.0;
if handles.Toolbox(tb).Input.RelatedToEpicentre==0
    if handles.Toolbox(tb).Input.NrSegments>=1
        for i=1:handles.Toolbox(tb).Input.NrSegments
            lon1 = handles.Toolbox(tb).Input.FaultX(i)*degrad ;
            lon2 = handles.Toolbox(tb).Input.FaultX(i+1)*degrad;
            lat1 = handles.Toolbox(tb).Input.FaultY(i)*degrad  ;
            lat2 = handles.Toolbox(tb).Input.FaultY(i+1)*degrad;
            bring= atan2(sin(lon2-lon1)*cos(lat2), .....
                cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1));
            dist = sqrt((sin((lat2-lat1)/2.0)*sin((lat2-lat1)/2.0))+ ........
                (cos(lat1)*cos(lat2)*(sin((lon2-lon1)/2.0)*sin((lon2-lon1)/2.0))));
            handles.Toolbox(tb).Input.Strike(i)= mod(bring,2*pi)*raddeg;
            handles.Toolbox(tb).Input.FaultLength(i)=2.*asin(dist)*rearth/1000.0;
            %userfaultL(i)=2.*asin(dist)*rearth/1000.0;
        end
        for i=handles.Toolbox(tb).Input.NrSegments+1:5
              handles.Toolbox(tb).Input.Strike(i)=0;
              handles.Toolbox(tb).Input.FaultLength(i)=0;
        end
        %    ddb_dnami_comp_Farea();
        %    faultTotL  = sum(userfaultL);
    end
end


    
