
istype([gca gca],'axes')
istype([gcf gcf],'axes')

istype([gca gca],'figure')
istype([gcf gcf],'figure')

istype([gcf gca],'figure')
istype([gcf gca],'axes')

istype([gcf gca text(1,1,'a') text(1,1,'a')],'figure')
istype([gcf gca text(1,1,'a') text(1,1,'a')],'axes')
istype([gcf gca text(1,1,'a') text(1,1,'a')],'text')
