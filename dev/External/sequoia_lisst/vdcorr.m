% MATLAB script to correct 
% 1) vd from invert.p for the correct VCC (can be found in the 
% InstrumentData.txt file or in the .LOG file for LISST-Portable and LISST-StreamSide)
% 2) vd to the laser reference at the time of the measurement.
% Usage:
%
%       vd = vdcorr(vd,VCC,flref,lref);
%
% where
%
% vd is the vd from invert.p
%
% VCC is the Volume Conversion Constant for your instrument
% (instrument-specific). It can be found in the InstrumentData.txt file for
% LISST-100X, LISST-STX and LISST-SL instruments and in the .LOG file for
% LISST-Portable and LISST-StreamSide instruments.
%
% flref is the factory laser reference value for you instrument. For
% LISST-100X and LISST-STX instruments this is element 36 in the
% factory_zsc file. For LISST-SL instruments, this is element 40 in the
% factory_zsc file. For LISST-Portable and LISST-StreamSide instruments,
% the flref can be found on the 'Get Background' display or in the .LOG file.
%
% lref is the laser reference value during measurement. For LISST-100X and
% LISST-STX it is element 36 in the .DAT file. For LISST-SL it is element
% 40 in the .DAT file. For LISST-Portable and LISST-StreamSide it is
% element 36 in the .DAT file.
%
% OAM 10/31/2011

function vd = vdcorr(vd,VCC,flref,lref)

if nargin ~=4
    error('You must input 4 variables: vd, the Volume Conversion Constant (VCC), the factory zscat laser reference value (element 36) and the laser reference for each individual measurement (element 36 in the .DAT file).')    
end

%do check to make sure that lref is as large as the number of rows in vd
[rows,cols]=size(vd);
if length(lref)~=rows
    error(['lref has a length of ',num2str(length(lref)),' elements. vd has ',num2str(rows),' rows. lref must have the same length as the number of rows in vd!'])
end

vd=vd./VCC;
for row=1:rows;
    vd(row,:)=vd(row,:).*flref/lref(row);
end

