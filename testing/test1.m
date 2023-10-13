%test1
% evaluate fundamental scripts
clear; clc; 
close all

addpath('./../src/')
addpath('./../ui/')

%load file
data = open_profile();

%plot data
figid = plot_profile(data);
%select edge points
[prj1_data,figid] = select_points_side(data,'A',figid);
[prj2_data,figid] = select_points_side(data,'B',figid);

%select rupture point
disp('Select rupture center point (left-click to select).');
rup_xy = zeros(2,1);
[rup_xy(1), rup_xy(2)] = ginput(1); % User selects the center point for Line 3
%azimuth angle
prompt = {'Enter rupture azimuth angle:'};
dlgtitle = 'Azimuth Input';
dims = [1 35];
definput = {'45'}; % Default value for azimuth angle
azimuth_input = inputdlg(prompt, dlgtitle, dims, definput);
rup_azimuth = str2double(azimuth_input{1});
close(figid)

%sampling
prj1_samp = prj1_data(:,[1:3]);
prj2_samp = prj2_data(:,[1:3]);

%compute projection;
[prj1_c,prj1_v,prj1_tlim,prj1_fun] = projection_fit(prj1_samp); 
[prj2_c,prj2_v,prj2_tlim,prj2_fun] = projection_fit(prj2_samp); 

%determine intersection points
prj1_pt = intersect_projection(prj1_c,prj1_v,rup_xy,rup_azimuth);
prj2_pt = intersect_projection(prj2_c,prj2_v,rup_xy,rup_azimuth);


%plot data
figid = plot_profile(data);
figid = plot_points_select(prj1_data,figid);
figid = plot_points_select(prj2_data,figid);
%plot projection points
figid = plot_prj_line(prj1_fun,figid);
figid = plot_prj_line(prj2_fun,figid);

plot([prj1_pt(1),prj2_pt(1)],[prj1_pt(2),prj2_pt(2)],'-','Color',"#D95319",'LineWidth',2);

disp_net   = norm(prj1_pt-prj2_pt);
disp_horiz = norm(prj1_pt(1:2)-prj2_pt(1:2));
disp_vert  = abs(prj1_pt(3)-prj2_pt(3));

fprintf('Measured Displacement:\n\tNet: %.2f (m)\n\tHorizontal: %.2f (m)\n\tVertical: %.2f (m)\n',disp_net,disp_horiz,disp_vert)
