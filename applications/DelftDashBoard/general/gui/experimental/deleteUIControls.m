function deleteUIControls

h=findobj(gcf,'Tag','UIControl');
if ~isempty(h)
    delete(h);
end
