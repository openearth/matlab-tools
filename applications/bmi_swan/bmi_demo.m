%% The shared library and the generic header file
% Make sure you have setup mex -setup before you run this.
cd 'd:\temp\test\' 
addpath(pwd)

dll = 'd:\checkouts\unstruc02\bin\debug\unstruc.dll';
% config_file = 'd:\checkouts\cases_unstruc\e00_unstruc\f04_bottomfriction\c016_2DConveyance_bend\input\bendprof.mdu';
config_file = 'd:\Checkouts\cases_unstruc\e00_unstruc\f06_external_forcing\c999_Waves_duckrec_2DH\input\UC04.mdu';

%% Load the library
[bmidll] = bmi_new(dll);
bmi_initialize(bmidll, config_file);

%%
% Get the node locations
xk = bmi_var_get(bmidll, 'xk');
X = bmi_var_get(bmidll, 'flowelemcontour_x');
yk = bmi_var_get(bmidll, 'yk');
zk = bmi_var_get(bmidll, 'zk');
Y = bmi_var_get(bmidll, 'flowelemcontour_y');
nodes = bmi_var_get(bmidll, 'flowelemnode');
% nodes(1,:) should be 1,42,43,2


xs1 = mean(xk(nodes),2);
ys1 = mean(yk(nodes),2);


% Create online visualization
dt = 1.0;
for i=1:400
    bmi_update(bmidll, dt);
    s1 = bmi_var_get(bmidll, 's1');
    % Replace water level with 10m at cell 1 through 10
    for ii=1:150
        bmi_set_1d_double_at_index(bmidll, 's1', ii, 5);
    end
    % This is not quite what I hoped for....
    clf;
    material metal
    patchinfo.Faces = nodes;
    patchinfo.Vertices = [xk,yk,zk];
    p = patch(patchinfo,'FaceColor','black');
    title([num2str(i)])
    set(gca,'CLim',[0 5])
    set(p, 'FaceAlpha',0.3)

    zks1(nodes(:,1)) = s1;
    zks1(nodes(:,2)) = s1;
    zks1(nodes(:,3)) = s1;
    zks1(nodes(:,4)) = s1;

    patchinfo.Faces = nodes;
    patchinfo.Vertices = [xk,yk,zks1'];
    p = patch(patchinfo,'FaceColor','blue');
    set(gca,'CLim',[0 5])
    set(p, 'FaceAlpha',0.2,'FaceLighting','phong',...
    'AmbientStrength',.3,'DiffuseStrength',.8,...
    'SpecularStrength',.9,'SpecularExponent',25)
    view(3);
    light('Position',[0 0 10])
    lightangle(-45,30)

    
%     zlim([0,6]);
%     xlim([-250,250]);
%     ylim([-250,250]);
    pause(0.001);
    hold off
end
bmi_finalize(bmidll);
