function handles=muppet_readXmlFiles(handles)

dr=handles.xmldir;

% Data types
flist=dir([dr 'datatypes' filesep '*.xml']);
for ii=1:length(flist)
    xml=xml2struct3([dr 'datatypes' filesep flist(ii).name]);
    handles.datatype(ii).datatype=xml;
    handles.datatypenames{ii}=flist(ii).name(1:end-4);
end

% Data properties
flist=dir([dr 'dataproperties' filesep '*.xml']);
for ii=1:length(flist)
  xml=xml2struct3([dr 'dataproperties' filesep flist(ii).name]);
  % Compute width and height
  width=0;
  height=0;
  if isfield(xml.dataproperty(1).dataproperty,'element')
    for jj=1:length(xml.dataproperty(1).dataproperty.element)
      pos=str2num(xml.dataproperty(1).dataproperty.element(jj).element.position);
      width=max(width,pos(1)+pos(3));
      height=max(height,pos(2)+pos(4));
    end
  end
  handles.dataproperty(ii).dataproperty=xml.dataproperty(1).dataproperty;
  handles.dataproperty(ii).dataproperty.width=width;
  handles.dataproperty(ii).dataproperty.height=height;
end

% Plot Options
flist=dir([dr 'plotoptions' filesep '*.xml']);
n=0;
for ii=1:length(flist)
    xml=xml2struct3([dr 'plotoptions' filesep flist(ii).name]);
    for jj=1:length(xml.plotoption)
        n=n+1;
        handles.plotoption(n).plotoption=xml.plotoption(jj).plotoption;
    end
end

% Subplot Options
xml=xml2struct3([dr 'subplotoptions' filesep 'subplotoptions.xml']);
handles.subplotoption=xml.subplotoption;

% Figure Options
xml=xml2struct3([dr 'figureoptions' filesep 'figureoptions.xml']);
handles.figureoption=xml.figureoption;

% Data File Types
flist=dir([dr 'filetypes' filesep '*.xml']);
for ii=1:length(flist)
    xml=xml2struct3([dr 'filetypes' filesep flist(ii).name]);
    handles.filetype(ii).filetype=xml;
end

% Plot Types
flist=dir([dr 'plottypes' filesep '*.xml']);
for ii=1:length(flist)
    xml=xml2struct3([dr 'plottypes' filesep flist(ii).name]);
    handles.plottype(ii).plottype=xml.plottype(1).plottype;
end


%% Frames (also do str2num here, which is not consistent with other xml files, but that's okay)
dr=[handles.muppetpath 'settings\frames\'];
flist=dir([dr '*.xml']);
n=0;
for ii=1:length(flist)
    xml=xml2struct3([dr flist(ii).name]);
    for j=1:length(xml.frame)
        n=n+1;
        handles.frames.frame(n).frame=xml.frame(j).frame;
        handles.frames.names{n}=xml.frame(j).frame.name;
        handles.frames.longnames{n}=xml.frame(j).frame.longname;
        % Set some defaults
        if isfield(handles.frames.frame(n).frame,'box')
            for k=1:length(handles.frames.frame(n).frame.box)
                handles.frames.frame(n).frame.box(k).box.position=str2num(handles.frames.frame(n).frame.box(k).box.position);                
                if ~isfield(handles.frames.frame(n).frame.box(k).box,'linewidth')
                    handles.frames.frame(n).frame.box(k).box.linewidth=1;
                else
                    handles.frames.frame(n).frame.box(k).box.linewidth=str2double(handles.frames.frame(n).frame.box(k).box.linewidth);
                end
            end
        end
        if isfield(handles.frames.frame(n).frame,'text')
            for k=1:length(handles.frames.frame(n).frame.text)
                handles.frames.frame(n).frame.text(k).text.position=str2num(handles.frames.frame(n).frame.text(k).text.position);                
                if ~isfield(handles.frames.frame(n).frame.text(k).text,'fontname')
                    handles.frames.frame(n).frame.text(k).text.fontname='Helvetica';
                end
                if ~isfield(handles.frames.frame(n).frame.text(k).text,'fontsize')
                    handles.frames.frame(n).frame.text(k).text.fontsize=8;
                else
                    handles.frames.frame(n).frame.text(k).text.fontsize=str2double(handles.frames.frame(n).frame.text(k).text.fontsize);
                end
                if ~isfield(handles.frames.frame(n).frame.text(k).text,'fontangle')
                    handles.frames.frame(n).frame.text(k).text.fontangle='normal';
                end
                if ~isfield(handles.frames.frame(n).frame.text(k).text,'fontweight')
                    handles.frames.frame(n).frame.text(k).text.fontweight='normal';
                end
                if ~isfield(handles.frames.frame(n).frame.text(k).text,'fontcolor')
                    handles.frames.frame(n).frame.text(k).text.fontcolor='Black';
                end
            end
        end
        if isfield(handles.frames.frame(n).frame,'logo')
            for k=1:length(handles.frames.frame(n).frame.logo)
                handles.frames.frame(n).frame.logo(k).logo.position=str2num(handles.frames.frame(n).frame.logo(k).logo.position);
            end
        end
    end
end

