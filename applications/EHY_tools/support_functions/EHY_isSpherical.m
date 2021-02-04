function TF = EHY_isSpherical(X,Y)
% This function makes an educated guess if the provided X or LON and Y or
% LAT values are spherical (TRUE) or not (FALSE). A logical is returned.

TF = false;

if all(all(X>=-180)) && all(all(X<=180)) && all(all(Y>=-90)) && all(all(Y<=90))
    TF = true;
end