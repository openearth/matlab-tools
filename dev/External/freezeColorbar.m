function sctColorbar = freezeColorbar(hColorbar)        
    % saves colordata from a colormap for layer application; In this way,
    % you can have multiple colormaps on a plot (each one in a different
    % axes).
    %
    %
    % INPUT: hColorbar: the handle to a colorbar
    %
    %
    % OUTPUT: sctColorbar: the information of the colorbar, that is used as
    % input in  freezeColorbarApply
    %
    % EXAMPLE:
    % % make a graph on the first axis
    % figure;
    % [x,y] = meshgrid(1:10);
    % z = sin(x+y);
    % subplot(2,1,1)
    % pcolor(x,y,z); shading interp
    % hc1 = colorbar;
    % % use freezeColors to freeze the colormap (jet)
    % freezeColors;
    % sctColor1 = freezeColorbar(hc1);     
    %
    % % make a graph on the second axis in a different color
    % subplot(2,1,2)
    % pcolor(x,y,z); shading interp
    % hc2 = colorbar;
    % colormap('hsv');
    % % use freezeColors to freeze the colormap (hsv)
    % freezeColors;
    % sctColor2 = freezeColorbar(hc2);     
    %
    % %Now set back the colors of the original colorbar in the first plot
    % freezeColorbarApply(sctColor1)
    
    
    % written by: ABR
    % date: 12-2-2013
        %convert colordata to real color
        freezeColors(hColorbar); 
        
        % look for colordata
        hColorbarKid = get(hColorbar,'Children');
        nColorbarIndex = [];
        for i = 1:length(hColorbarKid)
            if ~isempty(strfind(get(hColorbarKid(i),'tag'),'TMW_COLORBAR'))
                nColorbarIndex = i;
            end;
        end;

        if isempty(nColorbarIndex);
            error('Not a valid colorbar as index');
        end;
        % save data in a structure
        sctColorbar.colorbarData = get(hColorbarKid(nColorbarIndex),'CData'); %save colordata for colorbar 1
        sctColorbar.hColorbar = hColorbar;
        sctColorbar.colorbarIndex = nColorbarIndex;
        
