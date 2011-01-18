function [angle_deg] = rad2deg( angle_rad )
 error('%s has been deprecated',mfilename)

angle_deg = (angle_rad*360) / (2*pi);