function varargout = vs_trih_crosssection(trih,crosssection_id)
%VS_TRIH_CROSSSECTION   Reads NEFIS cross-section data for one transect.
%
% ST = vs_trih_crosssection(trih,crosssection_id)
%
% returns a struct with fields (if present):
%  - m
%  - n
%  - x
%  - y
%  - index
%  - name
%  - FLTR Total discharge
%  - CTR  Monumentary discharge
%  - 'substance_advective' Cumulative advective transport
%  - 'substance_dispersive' Cumulative dispersive transport
% 
% where crosssection_id can be :
% - the index(es) in the trih file 
% - crosssection name(s) as a multidimensional characters array.
%   where crosssections are counted in the first dimension.
% - a cell array of crosssection name(s)
% 
% Examples: 
%
% st = vs_trih_crosssection(trihfile(i),{'coast05','coast06'});
% st = vs_trih_crosssection(trihfile(i),['coast05';'coast06']);
% st = vs_trih_crosssection(trihfile(i),[10 11]);
%
% [ST,iostat] = vs_trih_crosssection(trih,crosssection_id)
% returns iostat=1 when succesfull, and iostat=-1 when failed.
% When iostat is not asked for, and it fails, error is called.
% This happens when the crosssection name is not present.
%
% See also: VS_USE, VS_LET, VS_TRIH_CROSSSECTION_INDEX,
%           VS_TRIH_STATION, VS_TRIH_STATION_INDEX

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

   iostat =  1;

   %% Get names from indices of vv.
   %% ------------------------------

   if iscell(crosssection_id)
      crosssection_id = char(crosssection_id);
   end
   
   if ischar(crosssection_id)
      ST.name  = crosssection_id;
      ST.index = vs_trih_crosssection_index(trih,crosssection_id);
   elseif isnumeric(crosssection_id)
      ST.index = crosssection_id;
      ST.name  = permute(vs_let(trih,'his-const','NAMTRA',{ST.index}),[2 3 1]);
   end
   
   if ~(length(ST.index)==size(ST.name,1))
      disp (addrowcol(crosssection_id,0,[-1 1],''''))
      disp(['Not all of above crosssections have match in : ',trih.FileName]);
      iostat = -1;
   end

   %% Get data
   %% ------------------------------

   if iostat==1
   
      if ~(size(ST.index,1)==0)
      
         ST.m         = permute(vs_let(trih,'his-const','MNTRA',{[1 3],ST.index}),[1 2]);
         ST.n         = permute(vs_let(trih,'his-const','MNTRA',{[2 4],ST.index}),[1 2]);
      
         ST.x         = permute(vs_let(trih,'his-const','XYTRA',{[1 3],ST.index}),[1 2]);
         ST.y         = permute(vs_let(trih,'his-const','XYTRA',{[2 4],ST.index}),[1 2]);
         
         ST.kmax      = permute(vs_let(trih,'his-const','KMAX'                  ),[1 2]);
         
         ST.datenum   = vs_time(trih,0,1);
         
         if ~isempty(vs_get_elm_def(trih,'FLTR'))
         ST.FLTR      = permute(vs_let(trih,'his-series','FLTR',{ST.index      }),[1 2]);
         ST.CTR       = permute(vs_let(trih,'his-series','CTR' ,{ST.index      }),[1 2]);
         ATR       = permute(vs_let(trih,'his-series','ATR' ,{ST.index,0    }),[1 3 2]);
         DTR       = permute(vs_let(trih,'his-series','DTR' ,{ST.index,0    }),[1 3 2]);
         
         flds     = vs_get_constituent_index(trih);
         fldnames = fieldnames(flds);
         for ifld=1:length(fldnames)
            fldname = fldnames{ifld};
            if strcmpi(flds.(fldname).elementname,'GRO')
               ST.([fldname,'_advective'             ]) = ATR(:,flds.(fldname).index);
               ST.([fldname,'_dispersive'            ]) = DTR(:,flds.(fldname).index);
               ST.([fldname,'_advective_description' ]) = 'Cumulative Advective transport of ',fldname,' through cross section (velocity points)';
               ST.([fldname,'_dispersive_description']) = 'Cumulative Dispersive transport of ',fldname,' through cross section (velocity points)';
               ST.([fldname,'_advective_units'       ]) = '-';
               ST.([fldname,'_dispersive_units'      ]) = '-';
            end
         end
         
         ST.FLTR_description = 'Total discharge through cross section (velocity points)';
         ST.CTR_description  = 'Monumentary discharge through cross section (velocity points)';

         ST.FLTR_units       = 'm3';
         ST.CTR_units        = 'm3/s';
         end

      else
      
         ST.m      = [];
         ST.n      = [];
      
         ST.x      = [];
         ST.y      = [];
      
         ST.angle  = [];

      end   
      
      ST.FileName        = trih.FileName;
      ST.Description     = 'Delft3d-FLOW monitoring point (*.obs) time serie.';
      ST.extracted_at    = datestr(now,31);
      ST.extracted_with  = 'vs_trih_crosssection.m  of G.J. de Boer (gerben.deboer@wldelft.nl)';
      
   end
   
   %% Output
   %% ------------------------------

   if     nargout==1
     if iostat==1
        varargout = {ST};
     else
        error(' ');
        varargout = {iostat};
     end
   elseif nargout==2
     varargout = {ST,iostat};
   end
   
%% EOF   