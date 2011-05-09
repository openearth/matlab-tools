function varargout=waquaio(sds,exper,field,varargin)
%WAQUAIO Read SIMONA SDS file.
%   [...]=WAQUAIO(SDS,'Exp','Field',TStep,Station,M,N,K)
%   supported fields and associated output arguments
%
%   * grid     : x,y (depth points)
%                -->  dgrid, zgrid, ugrid, vgrid (DP,ZETA,U,V points)
%   * zgrid3d  : x,y,z (waterlevel points)
%                -->  zgrid3d, ugrid3d, vgrid3d (ZETA,U,V points)
%   * drywet   : udam,vdam ((temporary) thindams)
%
%   * depth    : bed level (positive down)
%   * height   : bed level (positive up)
%
%   * wlvl     : water level, time
%   * wdepth   : water depth, time
%   * head     : head (energie hoogte), time
%   * xyveloc  : u,v,time or u,v,w,time
%                (U,V components in X,Y direction)
%   * xyudisch : qu,qv,time (qu=u*hu, qv=v*hv)
%                (QU,QV components in X,Y direction)
%   * veloc    : u,v,time or u,v,w,time
%                (U,V components in KSI,ETA direction in waterlevel points)
%   * veloc0   : unprocessed velocities in velocity points
%   * udisch   : unit discharge (u*H): qu,qv,time or qu,qv,w,time
%                (qu,qv components in KSI,ETA direction in waterlevel points)
%   * udisch0  : unprocessed unit discharges in velocity points
%   * disch    : Qu,Qv,time or Qu,Qv,w,time
%                (QU,QV components in KSI,ETA direction in waterlevel points)
%   * disch0   : unprocessed discharges in velocity points
%   * dischpot : QP,time (discharge potential)
%   * chezy    : chezy-u,chezy-v
%
%   * energy   : turbulent kinetic energy
%   * dissip   : energy dissipation
%
%   * subst:<substance name>  : substance field, time
%
%   * weirs    : udam,vdam,uhgh,vhgh: locations and heights of weirs
%
%   * flowstat-wl : waterlevel station names
%   * wlstat      : waterlevel at station
%   * flowstat-cur: current station names
%   * flowcrs-u   : u-discharge crosssection names
%   * flowcrs-v   : v-discharge crosssection names
%
%   * substances  : substance names,substance units
%   * transtat    : concentration station names
%   * trancrs-u   : u-transport crosssection names
%   * trancrs-v   : v-transport crosssection names

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
