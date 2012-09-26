function opt=muppet_setDefaultFigureProperties(handles)

opt.name='Figure 1';
opt.nrsubplots=1;
opt.width=21;
opt.height=29.7;
opt.orientation='portrait';
opt.backgroundcolor='White';
opt.frame=handles.frames.names{1};
opt.outputfile='figure1.png';
opt.format='png';
opt.resolution=300;
opt.renderer='zbuffer';
opt.units='centimeters';
opt.nrannotations=0;

opt.frametext=[];
% for ii=1:50
%     opt.frametext(ii).frametext.text=' ';
% end
