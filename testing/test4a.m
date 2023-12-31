%test4a
% determine rupture zone

clear; clc; 
close all

addpath('./../src/')
addpath('./../src/sampling/')
addpath('./../ui/')
addpath('./../ui/plotting')

%load file
data = open_profile();

%points to exclude
data = remove_points(data);

%plot data
figid = plot_profile(data);
%select edge points
[prj1_data,side1_idx,figid] = select_points_side(data,'A',figid);
[prj2_data,side2_idx,figid] = select_points_side(data,'B',figid);

%rupture threshold
prompt = {'Enter rupture zone treshold (~ofd):'};
dlgtitle = 'Rupture Zone';
dims = [1 45];
definput = {'0.05'}; % Default value for rupture zone treshold
rup_thres = inputdlg(prompt, dlgtitle, dims, definput);
rup_thres = str2double(rup_thres{1});

%sampling
prj1_samp = prj1_data(:,[1:3]);
prj2_samp = prj2_data(:,[1:3]);

%compute projection;
[prj1_c,prj1_v,prj1_tlim,prj1_fun] = projection_fit(prj1_samp); 
[prj2_c,prj2_v,prj2_tlim,prj2_fun] = projection_fit(prj2_samp); 

%fit analytic slip profile
[sprof_param,sprof_c,sprof_v,sprof] = fit_slip_profile(data,prj1_c,prj1_v,prj2_c,prj2_v,side1_idx,side2_idx,1);
%determine rupture zone
[rup_zone,rup_loc_mean,rup_ax] = determine_rup_zone(sprof_param,sprof_c,sprof_v,rup_thres);

%plot rupture zone
figid = plot_profile(data);
% figid = plot_points_select(prj1_data,figid);
% figid = plot_points_select(prj2_data,figid);
%plot projection points
figid = plot_prj_line(prj1_fun,figid);
figid = plot_prj_line(prj2_fun,figid);
hl1 = plot(rup_zone(:,1),rup_zone(:,2),':','LineWidth',3);
hl2 = plot(sprof(:,1),sprof(:,2),':','Color','#0072BD','LineWidth',2);
hl3 = plot(rup_loc_mean(1),rup_loc_mean(2),'o','Color','#0072BD','MarkerFaceColor','#0072BD','MarkerSize',8);
%principal axes
scl_rup_ax = 5;
hl4 = quiver(rup_loc_mean(1),rup_loc_mean(2),rup_ax(1,1),rup_ax(2,1), ...
             'Color','r','LineWidth',2,'AutoScale','on','AutoScaleFactor',scl_rup_ax,'MaxHeadSize',1);
hl5 = quiver(rup_loc_mean(1),rup_loc_mean(2),rup_ax(1,2),rup_ax(2,2), ...
             'Color','r','LineWidth',2,'AutoScale','on','AutoScaleFactor',scl_rup_ax,'MaxHeadSize',1);
legend([hl2,hl1,hl4],{'Fitted Slip Profile','Rupture Zone','Principal Directions'})
