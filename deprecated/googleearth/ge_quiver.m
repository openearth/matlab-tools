function output = ge_quiver(X,Y,DX,DY,varargin)
 error('%s has been deprecated',mfilename)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_quiver.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%

AuthorizedOptions = authoptions( mfilename );


%          id = 'quiver';
      idTag = 'id';
       name = 'ge_quiver';
description = '';
    timeStamp = ' ';
timeSpanStart = ' ';
 timeSpanStop = ' ';
 visibility = 1;
 extrude = 0;
  lineColor = 'FFFFFFFF';
  lineWidth = 1.0;
    snippet = ' ';
   altitude = 1.0;
 altitudeMode = 'clampToGround';
msgToScreen = false;
      region = ' ';

if( isempty( X ) || isempty( Y ) || isempty( DX ) || isempty( DY ) )
    error('empty coordinates passed to ge_quiver(...).');
end

TMP = sqrt(DX.^2+DY.^2);
magnitudeMax = max(TMP(:));
clear TMP
if numel(X)==1
    magnitudeScale = 1;
else
    magnitudeScale = det_smallest_interval(X,Y)*0.95;
end

% 
% if (max(size(X)) >= 2) && (max(size(Y)) >= 2)
% 
%     step_size_x = abs( X(1,1) - X(1,2) );
%     step_size_y = abs( Y(1,1) - Y(2,1) );
%     magnitudeMax = max( [ max(max(X)) max(max(Y)) ] );
%     magnitudeScale = min( [step_size_x step_size_y] );
% 
% elseif max(size( X )) >= 2
% 
%     step_size_x = abs( X(1,1) - X(1,2) );
%     magnitudeMax = max( [ max(max(X)) max(Y) ] );
%     magnitudeScale = step_size_x;
% 
% elseif max(size( Y )) >= 2
% 
%     step_size_y = abs( Y(1,1) - Y(2,1) );
%     magnitudeMax = max( [ max(max(Y)) max(X) ] );
%     magnitudeScale = step_size_y;     
% 
% else
%     magnitudeMax = max(max(X));
%     magnitudeScale = 1.0;
% end
%     

parsepairs %script that parses Parameter/Value pairs.

if msgToScreen
    disp(['Running: ',mfilename,'...'])
end

if ~(isequal(altitudeMode,'clampToGround')||...
   isequal(altitudeMode,'relativeToGround')||...
   isequal(altitudeMode,'absolute'))

    error(['Variable ',39,'altitudeMode',39, ' should be one of ' ,39,'clampToGround',39,', ',10,39,'relativeToGround',39,', or ',39,'absolute',39,'.' ])
end

if region == ' '
	region_chars = '';
else
	region_chars = [ region, 10 ];
end


% id_chars = [ idTag '="' id '"' ];
name_chars = [ '<name>',10, name,10, '</name>',10 ];
description_chars = [ '<description>',10,'<![CDATA[' description ']]>',10,'</description>',10 ];
visibility_chars = [ '<visibility>',10, int2str(visibility),10, '</visibility>',10 ];
lineColor_chars = [ '<color>',10, lineColor([1,2,7,8,5,6,3,4]) ,10,'</color>',10 ];
lineWidth_chars= [ '<width>',10, num2str(lineWidth, '%.2f'),10, '</width>',10 ];
altitudeMode_chars = [ '<altitudeMode>',10, altitudeMode,10, '</altitudeMode>',10 ];
extrude_chars = [ '<extrude>' int2str(extrude) '</extrude>',10 ];
if snippet == ' '
    snippet_chars = '';
else
    snippet_chars = [ '<Snippet>' snippet '</Snippet>',10 ];    
end

if timeStamp == ' '
    timeStamp_chars = '';
else
    timeStamp_chars = [ '<TimeStamp><when>' timeStamp '</when></TimeStamp>',10 ];
end

if timeSpanStart == ' '
    timeSpan_chars = '';
else
    if timeSpanStop == ' ' 
        timeSpan_chars = [ '<TimeSpan><begin>' timeSpanStart '</begin></TimeSpan>',10 ];
    else
        timeSpan_chars = [ '<TimeSpan><begin>' timeSpanStart '</begin><end>' timeSpanStop '</end></TimeSpan>',10 ];    
    end
        
end


[row_count, col_count] = size(X);
%output = '';
output = cell((row_count * col_count), 1);
ctr = 1;

for row = 1:row_count
    for col = 1:col_count

        if (DX(row,col) == 0) && (DY(row,col) == 0)
            
            direction = 0;
            
        elseif DX(row,col) == 0
            
            if DY(row,col) > 0
                direction = 0;
            else
                direction = 180;
            end

        elseif DY(row,col) == 0
            
            if DX(row,col) > 0
                direction = 90;
            else
                direction = 270;
            end
            
        else
            direction = rad2deg( atan2(  DX(row,col) , DY(row,col)  ) );

        end
        
        magnitude = sqrt( DX(row,col) .^ 2 + DY(row,col) .^ 2 );
 
        part1 = [' <Document ',idTag,'="qc_',int2str(row),'_',int2str(col),'">',...
                    '<name>',int2str(row),' ',int2str(col),'</name>',...
                    '<Placemark ',idTag,'="q_',int2str(row),'_',int2str(col),'">',...
                        name_chars,...
                        timeStamp_chars,...
                        timeSpan_chars,...
                        snippet_chars,...
                        description_chars,...
                        region_chars,...
                        '<Style ',idTag,'="qs_',int2str(row),'_',int2str(col),'">',...
                            '<LineStyle ',idTag,'="qls_',int2str(row),'_',int2str(col),'">',...
                                lineColor_chars,...
                                lineWidth_chars,...
                           '</LineStyle>',...
                        '</Style>',...
                        visibility_chars,...
                        '<LineString ',idTag,'="ql_',int2str(row),'_',int2str(col),'">',...
                            extrude_chars,...
                            altitudeMode_chars,...
                            '<tessellate>1</tessellate>',...
                            '<coordinates>'];

        %continued ugliness
        alpharad = deg2rad( [direction, (direction + 12), (direction - 12)]  );           %[rad]  
        scaleFactor = ( magnitude / magnitudeMax ) * magnitudeScale; 
        divPer= [scaleFactor, (3*scaleFactor/4), (3*scaleFactor/4) ]';

        %how to do this step once in parrallel?
        %     x = sin( alpharad ) * divPer;
        %     y = cos( alpharad ) * divPer;
        x(1) = sin( alpharad(1) ) * divPer(1);
        y(1) = cos( alpharad(1) ) * divPer(1);
        x(2) = sin( alpharad(2) ) * divPer(2);
        y(2) = cos( alpharad(2) ) * divPer(2);
        x(3) = sin( alpharad(3) ) * divPer(3);
        y(3) = cos( alpharad(3) ) * divPer(3);


        % bug fixes & addtions from Brett Grant
% % %         %added for aspect ratio
        x = x/(cos(Y(row, col)*(pi/180)));
% % % modified output accuracy
        arrow_coords = [ num2str(X(row, col),'%11.7f'),',',num2str(Y(row, col),'%11.7f'),',',num2str(altitude),' ',...
                        num2str(X(row, col)+x(1),'%11.7f'),',',num2str(Y(row, col)+y(1),'%11.7f'),',',num2str(altitude),' ',...
                        num2str(X(row, col)+x(2),'%11.7f'),',',num2str(Y(row, col)+y(2),'%11.7f'),',',num2str(altitude),' ',...
                        num2str(X(row, col)+x(3),'%11.7f'),',',num2str(Y(row, col)+y(3),'%11.7f'),',',num2str(altitude),' ',...
                        num2str(X(row, col)+x(1),'%11.7f'),',',num2str(Y(row, col)+y(1),'%11.7f'),',',num2str(altitude),' '];

        lolo = strfind(arrow_coords,'NaN');
        if lolo
            arrow_coords = [ num2str(X(row, col),'%11.7f'),',',num2str(Y(row, col),'%11.7f'),',',num2str(altitude),' ',...
                        num2str(X(row, col),'%11.7f'),',',num2str(Y(row, col),'%11.7f'),',',num2str(altitude),' ',...
                        num2str(X(row, col),'%11.7f'),',',num2str(Y(row, col),'%11.7f'),',',num2str(altitude),' ',...
                        num2str(X(row, col),'%11.7f'),',',num2str(Y(row, col),'%11.7f'),',',num2str(altitude),' ',...
                        num2str(X(row, col),'%11.7f'),',',num2str(Y(row, col),'%11.7f'),',',num2str(altitude),' '];
        end
        clear lolo
% %         % end added section

        part2 = [ '</coordinates>',...
                '</LineString>',...
              '</Placemark>',...
            '</Document>'];

        chunk = strcat(part1, arrow_coords, part2);
        output{ctr} = chunk;
        
        ctr = ctr + 1;
        
    end

end

output = char(output);
[sx, sy] = size(output);
%foutput = char(zeros(1,sx*sy));
foutput = repmat(' ',[1,sx*sy]);

offset = 1;
for i = 1:sx

    trimmed = strtrim(output(i,:));
    end_offset = length(trimmed) + (offset) - 1;

    foutput(offset:end_offset) = trimmed;
    offset = end_offset + 1;

end


output = foutput;

if msgToScreen
    disp(['Running: ',mfilename,'...Done'])
end



function dOut = det_smallest_interval(X,Y)

dLowest=Inf;
for k=1:numel(X)
    for m=k+1:numel(X)
        dSquared = (X(k)-X(m))^2+(Y(k)-Y(m))^2;
        if dSquared<dLowest
            dLowest=dSquared;
        end
    end
end

dOut = sqrt(dLowest);