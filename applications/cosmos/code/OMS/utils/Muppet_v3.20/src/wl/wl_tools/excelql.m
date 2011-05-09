function Out=excelql(cmd,varargin),
%EXCELQL Excel QuickLink, get data from Microsoft Excel
%
%   EXCELQL
%   Transfer interactively data from Excel to
%   Matlab via an ActiveX link. Data obtained
%   from Excel is stored in the workspace
%   variable 'excel'.
%
%   EXCELQL OPEN 'FileName'
%   Open and select the specified Excel file.
%
%   EXCELQL WORKBOOK 'WorkbookName'
%   Select the specified workbook as the current workbook.
%
%   EXCELQL SHEET 'SheetName'
%   Select the specified sheet in the current workbook.
%
%   EXCELQL NEWSHEET 'SheetName'
%   Create a new sheet with specified name in the current workbook.
%
%   EXCELQL RANGE RangeIdentification
%   Select range from command line, e.g.
%      excelql range B4:D8
%
%   EXCELQL LOAD
%   Get data from Excel. Updates the workspace
%   variable 'excel'.
%   A=EXCELQL('LOAD');
%   Stores the data in the indicated variable
%   'A' instead of the general variable 'excel'.
%
%   EXCELQL('SAVE',A)
%   Put data of A into the selected Excel cell range. 
%

% (c) 1999-2001 H.R.A.Jagers
%     WL | Delft Hydraulics, Delft, The Netherlands


if nargin==0,
   cmd='initialize';
end;
if nargout>0
   Out=[];
end

if isempty(gcbf),
   EXCELUI=findall(0,'type','figure','tag','Excel QuickLink');
   if isempty(EXCELUI),
      EXCELUI=hgload('excelui');
      excel=actxserver('excel.application');
      excel.visible=1;
      cexcel={excel};
      set(EXCELUI,'userdata',cexcel);
   end;
else,
   EXCELUI=gcbf;
end;
cexcel=get(EXCELUI,'userdata');
if isempty(cexcel) | ~iscell(cexcel),
   delete(EXCELUI);
   if nargout>0
      Out=-1;
   end
   return;
end;
excel=cexcel{1};

cmd=lower(cmd);
switch cmd,
   case 'closereq',
      excel.DisplayAlerts=0;
      invoke(excel,'quit');
      %g=evalc('A=excel.Version','');
      %if isempty(g), delete(excel); end
      delete(excel);
      delete(EXCELUI);
      
   case {'wbsaveas'},
      wbs=excel.workbooks;
      nwb=wbs.count;
      wblist=findobj(EXCELUI,'tag','wblist');
      wbnr=get(wblist,'value');
      if (wbnr>nwb),
         excelql UpdateWorkbookList
         release(wbs)
         return
      end
      wb=get(wbs,'item',wbnr);
      wb.SaveAs(varargin{:});

   case {'wbclose','close'},
      wbs=excel.workbooks;
      nwb=wbs.count;
      wblist=findobj(EXCELUI,'tag','wblist');
      wbnr=get(wblist,'value');
      if (wbnr>nwb),
         excelql UpdateWorkbookList
         release(wbs)
         return
      end
      wb=get(wbs,'item',wbnr);
      invoke(wb,'Close');
      excelql UpdateWorkbookList
      
   case {'initialize','updateworkbooklist','refresh'},
      wbs=excel.workbooks;
      nwb=double(wbs.count);
      wblist=findobj(EXCELUI,'tag','wblist');
      wbname={};
      if nwb==0,
         set(wblist,'string','<no active workbooks>', ...
            'value',1, ...
            'backgroundcolor',[.8 .8 .8], ...
            'enable','off');
      else,
         for i=1:nwb,
            wb = get(wbs,'item',i);
            wbname{i}=wb.name;
         end;
         if strcmp(get(wblist,'enable'),'off')
            cwb='';
         else
            cwbnames=get(wblist,'string');
            cwb=get(wblist,'value');
            cwb=cwbnames{cwb};
         end
         cwb=ustrcmpi(cwb,wbname);
         if cwb<0
            cwb=1;
         end
         set(wblist,'string',wbname, ...
            'value',cwb, ...
            'backgroundcolor',[1 1 1], ...
            'enable','on');
      end;
      excelql UpdateSheetList
      release(wbs)
      if nargout>0
         Out=wbname;
      end
      
   case {'wbselect','updatesheetlist','workbook'},
      if nargout>0
         Out=0;
      end
      wbs=excel.workbooks;
      nwb=wbs.count;
      wblist=findobj(EXCELUI,'tag','wblist');
      shtlist=findobj(EXCELUI,'tag','shtlist');
      rangedit=findobj(EXCELUI,'tag','range');
      loadbut=findobj(EXCELUI,'tag','load');
      
      if nargin>1
         wbstr=get(wblist,'string');
         wbnr=ustrcmpi(varargin{1},wbstr);
      else
         wbnr=get(wblist,'value');
      end
      if ((wbnr>nwb) | (nwb<0)) & strcmp(get(wblist,'enable'),'on'),
         excelql UpdateWorkbookList
         release(wbs)
         if nargout>0
            Out=-1;
         end
         return;
      elseif nwb==0,
         set(shtlist,'string',' ', ...
            'value',1, ...
            'backgroundcolor',[.8 .8 .8], ...
            'enable','off');
         set(rangedit,'string','', ...
            'backgroundcolor',[.8 .8 .8], ...
            'enable','off');
         set(loadbut,'enable','off');
         if nargout>0
            Out=-1;
         end
         return;
      end;
      set(wblist,'value',wbnr);
      wb=get(wbs,'item',wbnr);
      invoke(wb,'activate');
      shts=wb.sheets;
      
      nshts=double(shts.count);
      shtname={};
      if nshts==0,
         set(shtlist,'string','<no sheets available>', ...
            'value',1, ...
            'backgroundcolor',[.8 .8 .8], ...
            'enable','off');
         set(rangedit,'string','', ...
            'backgroundcolor',[.8 .8 .8], ...
            'enable','off');
         set(loadbut,'enable','off');
      else,
         for i=1:nshts,
            sht = get(shts,'item',i);
            shtname{i}=sht.name;
         end;
         set(shtlist,'string',shtname, ...
            'value',1, ...
            'backgroundcolor',[1 1 1], ...
            'enable','on');
         set(rangedit,'string','', ...
            'backgroundcolor',[1 1 1], ...
            'enable','on');
         set(loadbut,'enable','off');
      end;
      release(wbs)
      release(wb)
      release(shts)
      if nargout>0
         Out=shtname;
      end
      
   case {'shtselect','sheet','sheet*','sheetname','newsheet'},
      if strcmp(cmd,'newsheet')
         cmd='sheet*';
      end
      if nargout>0
         Out=0;
      end
      wbs=excel.workbooks;
      nwb=wbs.count;
      wblist=findobj(EXCELUI,'tag','wblist');
      shtlist=findobj(EXCELUI,'tag','shtlist');
      rangedit=findobj(EXCELUI,'tag','range');
      loadbut=findobj(EXCELUI,'tag','load');
      wbnr=get(wblist,'value');
      if (wbnr>nwb) | (wbnr<0),
         excelql UpdateWorkbookList
         release(wbs)
         if nargout>0
            Out=-1;
         end
         return;
      end;
      wb=get(wbs,'item',wbnr);
      shts=wb.sheets;
      nshts=shts.count;
      if nargin>1 & ~strcmp(cmd,'sheetname')
         shtstr=get(shtlist,'string');
         shtnr=ustrcmpi(varargin{1},shtstr);
         if strcmp(cmd,'sheet*')
            if shtnr<0
               nwsht=invoke(shts,'Add');
               nwsht.Name=varargin{1};
               release(nwsht)
               Out=1;
               excelql UpdateSheetList
               shtstr=get(shtlist,'string');
               shtnr=ustrcmpi(varargin{1},shtstr);
            else
               warning(sprintf('Sheet %s already exists!',varargin{1}))
            end
         end
      else
         shtnr=get(shtlist,'value');
      end
      if (shtnr>nshts) | (shtnr<0),
         excelql UpdateSheetList
         if nargout>0
            Out=Out-1;
         end
      else
         sht=get(shts,'item',shtnr);
         if strcmp(cmd,'sheetname')
            Out=sht.Name;
            if nargin==2
               changed=0;
               try
                  sht.Name=varargin{1};
                  changed=1;
               catch
                  warning(sprintf('Sheet %s already exists!',varargin{1}))
               end
               excelql UpdateSheetList
               Out=sht.Name;
               excelql('sheet',Out)
            end
         else
            invoke(sht,'activate');
            set(shtlist,'value',shtnr);
         end
         release(sht)
      end;
      release(wbs)
      release(wb)
      release(shts)
      
   case {'wbopen','open'}
      if nargout>0
         Out=0;
      end
      wbs=excel.workbooks;
      if nargin>1
         pn='';
         fn=varargin{1};
      else
         [fn,pn]=uigetfile('*.xls');
      end
      OK=0;
      if ischar(fn),
         try,
            invoke(wbs,'open',[pn fn]);
            OK=1;
         catch,
         end
      end;
      release(wbs);
      if OK
         wblist=findobj(EXCELUI,'tag','wblist');
         set(wblist,'value',1,'string',{fn});
         excelql updateworkbooklist
      else
         if nargout>0
            Out=-1;
         end
      end
      
   case 'wbnew',
      wbs=excel.workbooks;
      invoke(wbs,'add');
      release(wbs);
      excelql updateworkbooklist
      
   case 'range',
      if nargout>0
         Out=0;
      end
      loadbut=findobj(EXCELUI,'tag','load');
      rngedit=findobj(EXCELUI,'tag','range');
      try,
         if nargin==1
            Str=get(rngedit,'string');
         else
            Str=varargin{1};
            if ~ischar(Str), Str=num2range(Str); end
         end
         [MinR,MaxR]=range2num(Str,'split');
         RANGE=range2num(Str);
         set(rngedit,'string',sprintf('%s:%s',MinR,MaxR));
         set(loadbut,'enable','on','userdata',RANGE);
      catch,
         set(loadbut,'enable','off');
         if nargout>0
            Out=-1;
         end
      end;
      
   case {'load','save','numberformat'}
      wbs=excel.workbooks;
      nwb=wbs.count;
      wblist=findobj(EXCELUI,'tag','wblist');
      shtlist=findobj(EXCELUI,'tag','shtlist');
      rangedit=findobj(EXCELUI,'tag','range');
      loadbut=findobj(EXCELUI,'tag','load');
      wbnr=get(wblist,'value');
      if (wbnr>nwb),
         excelql UpdateWorkbookList
         release(wbs)
         return;
      end;
      wb=get(wbs,'item',wbnr);
      shts=wb.sheets;
      nshts=shts.count;
      shtnr=get(shtlist,'value');
      if shtnr>nshts,
         excelql UpdateSheetList
         release(wbs)
         release(wb)
         release(shts)
         return;
      end;
      sht=get(shts,'item',shtnr);
      RANGE=get(loadbut,'userdata');
      if ~isequal(size(RANGE),[1 4]),
         release(wbs)
         release(wb)
         release(shts)
         release(sht)
         return;
      end;
      %BUG? in ActiveX: if I request data from one cell and the cell is empty, I get -1
      %                 if I request data from multiple cells, I get a warning for every
      %                 empty cell and NaN is returned for that cell.
      %FIX! The code below makes this behaviour by extending a single cell data request
      %     to a multi cell data request.
      onecellfix=0;
      if isequal(RANGE(1:2),RANGE(3:4)) & strcmp(cmd,'load'),
         if RANGE(2)==1,
            onecellfix=1;
         else,
            onecellfix=-1;
         end;
         RANGE(2)=RANGE(2)+onecellfix;
      end;
      cl1=get(sht.Cells,'item',RANGE(2),RANGE(1));
      cl2=get(sht.Cells,'item',RANGE(4),RANGE(3));
      rng=get(sht,'range',cl1,cl2);
      switch cmd,
         case 'load'
            try,
               TrashCan=evalc('B=get(rng,''value'')');
            catch,
               uiwait(msgbox('Error while getting data ...','modal'));
            end;
            if iscell(B) & all(cellfun('prodofsize',B(:))==1),
               B=reshape([B{:}],size(B));
            end;
            if onecellfix,
               B=B(1+(onecellfix<0));
               if iscell(B), B=B{1}; end;
            end;
            if nargout>0
               Out=B;
            else
               assignin('base','excel',B);
            end
         case 'save'
            B=varargin{1};
            try
               rng=set(rng,'value',B);
            catch
               fprintf('Cannot save data to Excel.\n');
            end
         case 'numberformat'
            rng.NumberFormat=varargin{1};
      end
      release(wbs)
      release(wb)
      release(shts)
      release(sht)
      release(cl1)
      release(cl2)
   otherwise,
      warning(sprintf('Unknown Excel QuickLink command: %s',cmd));
end;