function sct = readAutocadDxf(varargin)

%% Read entities information of dxf file
% This function reads a dxf-file from AUTOCAD and stored the several
% entities differently in a structure (e.g. line, polyline, circle, arc and
% point). The function is based on function f_LectDxf, which
% is downloaded from the web and has been mofified by IMDC.
%
% SYNTAX: sct = readAutocadDxf(filename,'property')
%
% INPUT:
%     filname
%     properties:
%           * 'polyline2line': conversion from polyline format to line
%           format
%
% OUTPUT: structure with entities
%      e.g. sct.polyline.x = x-coordinates of a polyline, ...
%     
%
% Base fx: f_LectDxf.m
% Modified by: JCA (03/2017)
 
% 
filename = varargin{1};
bPoly2line = 0;
if length(varargin) > 1
    for k = 2:length(varargin)
       switch lower(varargin{k})
           case 'polyline2line'
               bPoly2line = varargin{k+1};
       end
    end
    
end

%% Read file
    fId = fopen(filename);    
    c_ValAsoc = textscan(fId,'%d%s','Delimiter','\n');
    fclose(fId);
    % Code Group Matrix
    m_GrCode = c_ValAsoc{1};
    % Associated value String Cell
    c_ValAsoc = c_ValAsoc{2};
    %[m_GrCode,c_ValAsoc] = c_ValAsoc{:};
    
%% Entities
    m_PosCero = find(m_GrCode==0);
    %Is searched by (0,SECTION),(2,ENTITIES)
    indInSecEnt = strmatch('ENTITIES',c_ValAsoc(m_PosCero(1:end-1)+1),'exact');
    %(0,ENDSEC)
    m_indFinSecEnt = strmatch('ENDSEC',c_ValAsoc(m_PosCero(indInSecEnt:end)),'exact');
    % Entities Position
    m_PosCero = m_PosCero(indInSecEnt:indInSecEnt-1+m_indFinSecEnt(1));
    % Variable initiation
    iline = 1;
    ipoly = 1;
    iarc = 1;
    icircle = 1;
    ipoint = 1;
    
    % Loop on the Entities
    for iEnt = 1:length(m_PosCero)-2
        m_GrCodeEnt = m_GrCode(m_PosCero(iEnt+1):m_PosCero(iEnt+2)-1);
        c_ValAsocEnt = c_ValAsoc(m_PosCero(iEnt+1):m_PosCero(iEnt+2)-1);
        nomEnt = c_ValAsocEnt{1};  %c_ValAsocEnt{m_PosCero(iEnt+1)}
        %In the entitie's name is assumed uppercase
        switch nomEnt            
            case 'LINE'
                % (Xi,Yi,Zi,Xj,Yj,Zj) start and end points
                sct.line.x(iline,:) = [str2double(f_ValGrCode(10,m_GrCodeEnt,c_ValAsocEnt)),...
                                       str2double(f_ValGrCode(11,m_GrCodeEnt,c_ValAsocEnt))];
                    
                sct.line.y(iline,:) = [str2double(f_ValGrCode(20,m_GrCodeEnt,c_ValAsocEnt)),...
                    str2double(f_ValGrCode(21,m_GrCodeEnt,c_ValAsocEnt))];
               
                sct.line.z(iline,:) = [str2double(f_ValGrCode(30,m_GrCodeEnt,c_ValAsocEnt)),...
                    str2double(f_ValGrCode(31,m_GrCodeEnt,c_ValAsocEnt))];
               
                % Layer
                sct.line.layer(iline,:) = f_ValGrCode(8,m_GrCodeEnt,c_ValAsocEnt);
                % handle
                sct.line.id(iline,:) = f_ValGrCode(5,m_GrCodeEnt,c_ValAsocEnt);
                
                % handle Group
                sct.line.group(iline,:) = f_ValGrCode(330,m_GrCodeEnt,c_ValAsocEnt);
                %
                iline = iline+1;
            case {'LWPOLYLINE','VERTEX'}
                % (X,Y) vertexs
                %Is not take into account the budge (group code 42, arc in the polyline).
                sct.polyline.x(ipoly,:) = str2double(f_ValGrCode(10,m_GrCodeEnt,c_ValAsocEnt));
                sct.polyline.y(ipoly,:) = str2double(f_ValGrCode(20,m_GrCodeEnt,c_ValAsocEnt));
                sct.polyline.z(ipoly,:) = str2double(f_ValGrCode(30,m_GrCodeEnt,c_ValAsocEnt));
                
                % Layer
                sct.polyline.layer(ipoly,:) = f_ValGrCode(8,m_GrCodeEnt,c_ValAsocEnt);
                % Add properties
                % handle
                sct.polyline.id(ipoly,:) = f_ValGrCode(5,m_GrCodeEnt,c_ValAsocEnt);
                
                 % handle Group
                 sct.polyline.group(ipoly,:) = f_ValGrCode(330,m_GrCodeEnt,c_ValAsocEnt);
                 
                 ipoly = ipoly+1;
            case 'CIRCLE'
                % (X Center,Y Center,Radius)
                sct.circle.x(icircle,:) = str2double(f_ValGrCode(10,m_GrCodeEnt,c_ValAsocEnt));
                sct.circle.y(icircle,:) = str2double(f_ValGrCode(20,m_GrCodeEnt,c_ValAsocEnt));
                sct.circle.radius(icircle,:) = str2double(f_ValGrCode(40,m_GrCodeEnt,c_ValAsocEnt));
                
                % Layer
                sct.circle.layer(icircle,:) = f_ValGrCode(8,m_GrCodeEnt,c_ValAsocEnt);
                % Add properties
                %
                icircle = icircle+1;
            case 'ARC'
                % (X Center,Y Center,Radius,Start angle,End angle)
                sct.arc.x(iarc,:) = str2double(f_ValGrCode(10,m_GrCodeEnt,c_ValAsocEnt));
                sct.arc.y(iarc,:) = str2double(f_ValGrCode(20,m_GrCodeEnt,c_ValAsocEnt));
                sct.arc.radius(iarc,:) = str2double(f_ValGrCode(40,m_GrCodeEnt,c_ValAsocEnt));
                sct.arc.angle(iarc,:) = [str2double(f_ValGrCode(50,m_GrCodeEnt,c_ValAsocEnt)),...
                    str2double(f_ValGrCode(51,m_GrCodeEnt,c_ValAsocEnt))];
                               
               % Layer
                sct.arc.layer(iarc,:) = f_ValGrCode(8,m_GrCodeEnt,c_ValAsocEnt);
                % Add properties
                %
                iarc = iarc+1;
            case 'POINT'
                % (X,Y,Z) Position
                sct.point.x(ipoint,:) = str2double(f_ValGrCode(10,m_GrCodeEnt,c_ValAsocEnt));
                sct.point.y(ipoint,:) = str2double(f_ValGrCode(20,m_GrCodeEnt,c_ValAsocEnt));
                sct.point.z(ipoint,:) = str2double(f_ValGrCode(30,m_GrCodeEnt,c_ValAsocEnt));
                   
                % Layer
                sct.point.layer(ipoint,:) = f_ValGrCode(8,m_GrCodeEnt,c_ValAsocEnt);
                % Add properties
                %
               ipoint = ipoint+1;
            %case Add Entities
        end        
    end    
%%   
if bPoly2line && isfield(sct,'polyline'); 
    for i = 1:length(sct.polyline.x)-1
        % (Xi,Yi,Zi,Xj,Yj,Zj) start and end points
        if strcmpi(sct.polyline.group(i), sct.polyline.group(i+1)) == 1
            sct.line.x(iline,:) = [sct.polyline.x(i), sct.polyline.x(i+1)];
            sct.line.y(iline,:) = [sct.polyline.y(i), sct.polyline.y(i+1)];
            sct.line.z(iline,:) = [sct.polyline.z(i), sct.polyline.z(i+1)];
            
            sct.line.group(iline,:) = sct.polyline.group(i);
            sct.line.id(iline,:) = {[sct.polyline.id{i},sct.polyline.id{i+1}]}; 
            sct.line.layer(iline,:) = sct.polyline.layer(i,:);
            
            iline = iline + 1;
            
        end    
    end
   sct = rmfield(sct,'polyline'); 
end

end

%%
function c_Val = f_ValGrCode(grCode,m_GrCode,c_ValAsoc)
    c_Val = c_ValAsoc(m_GrCode==grCode);
end

%%
function c_XData = f_XData(grCode,XDatNom,m_GrCode,c_ValAsoc)
    m_PosXData = find(m_GrCode==1001);
    if ~isempty(m_PosXData)
        indInXData = m_PosXData(strmatch(upper(XDatNom),c_ValAsoc(m_PosXData),'exact'));
        m_indFinXData = find(m_GrCode(indInXData+2:end)==1002)+indInXData+1;
        m_IndXData = indInXData+2:m_indFinXData(1)-1;
        c_XData = f_ValGrCode(grCode,m_GrCode(m_IndXData),c_ValAsoc(m_IndXData));
    else
        c_XData = {[]};
    end
end
        