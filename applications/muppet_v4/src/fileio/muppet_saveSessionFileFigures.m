function muppet_saveSessionFileFigures(handles,fid,ifig,ilayout)

fig=handles.figures(ifig).figure;

txt=['Figure "' fig.name '"'];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);

k=muppet_findIndex(handles.figureoption,'figureoption','name','papersize');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);
k=muppet_findIndex(handles.figureoption,'figureoption','name','frame');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);
k=muppet_findIndex(handles.figureoption,'figureoption','name','orientation');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);
k=muppet_findIndex(handles.figureoption,'figureoption','name','backgroundcolor');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);

if ~ilayout
    for ii=1:50
        k=muppet_findIndex(handles.figureoption,'figureoption','name',['frametext' num2str(ii)]);
        muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);
    end
end

txt='';
fprintf(fid,'%s \n',txt);

%%

% if fig.nrannotations>0
%     nrsub=fig.nrsubplots-1;
% else
     nrsub=fig.nrsubplots;
% end

for isub=1:nrsub
    muppet_saveSessionFileSubplots(handles,fid,ifig,isub,ilayout);
end

% if ilayout==0
%     if fig.nrannotations>0
%         muppet_saveSessionAnnotations(handles,fid,ifig);
%     end
% end

if ilayout==0
    str=fig.outputfile;
else
    str=['figure1.' fig.format];
end
txt=['   OutputFile "' str '"'];
fprintf(fid,'%s \n',txt);

k=muppet_findIndex(handles.figureoption,'figureoption','name','format');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);
k=muppet_findIndex(handles.figureoption,'figureoption','name','resolution');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);
k=muppet_findIndex(handles.figureoption,'figureoption','name','renderer');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);

txt='';
fprintf(fid,'%s \n',txt);
txt='EndFigure';
fprintf(fid,'%s \n',txt);
