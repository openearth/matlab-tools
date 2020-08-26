function freezeColorbarApply(sctColorBar)
    % This functions sets back colorbardata for an axes. See freezeColorbar
    % for an example of use
        %reset colors for the first colorbar
        hColorbarKid = get(sctColorBar.hColorbar,'chil');
        
        % look for the index of the image
        colorbarIndex = [];
        for i = 1:length(hColorbarKid)
            if ~isempty(strfind(get(hColorbarKid(i),'tag'),'TMW_COLORBAR'))
                colorbarIndex = i;
            end;
        end;
        if isempty(colorbarIndex)
            error('Input is not a valid freezeColorbarStructure');
        end;
        % set back the color information
        set(hColorbarKid(colorbarIndex),'CData',sctColorBar.colorbarData); 
    