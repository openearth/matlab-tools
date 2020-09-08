%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

%% PREAMBLE

clear
clc

%% INPUT

paths_etaw='c:\Users\chavarri\temporal\SOBEK\test\001\output\etaw.csv';


%% READ

fid=fopen(paths_etaw,'r');
% fstr='%02d/%02d/%02d %02d:%02d:%02d,%f,%f,%s,%f,%f';
fstr='%s %f %f %s %f %f';
% 00/01/01 00:00:00,9.99950300363246,0,Channel1,9.959,1.80190004919931
%time [-],x,y,branch,chainage,Water level [m AD]
data=textscan(fid,fstr,'headerlines',1,'delimiter',',');
fclose(fid);



