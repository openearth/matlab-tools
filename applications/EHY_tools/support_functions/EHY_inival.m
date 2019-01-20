function out = EHY_inival(dimensions,inival)

%% Initialises n-dimensional array with inival
total           = prod(dimensions);
out   (1:total) = inival;
out             = reshape(out,dimensions);
