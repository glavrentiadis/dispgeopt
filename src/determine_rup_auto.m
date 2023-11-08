function [rup_loc_mean,rup_zone_lim,rup_ax,figid] = determine_rup_auto(data,prj1_data,prj2_data)
% determine rupture location (automatic) given rupture slip threshold

%rupture threshold
prompt = {'Enter rupture slip treshold (~ofd):'};
dlgtitle = 'Rupture Zone';
dims = [1 45];
definput = {'0.05'}; % Default value for rupture zone treshold
rup_thres = inputdlg(prompt, dlgtitle, dims, definput);
rup_thres = str2double(rup_thres{1});

%compute projection;
[prj1_c,prj1_v,~,~,prj1_fun] = projection_fit(prj1_data(:,1:3)); 
[prj2_c,prj2_v,~,~,prj2_fun] = projection_fit(prj2_data(:,1:3)); 

%fit analytic slip profile
[sprof_param,sprof_c,sprof_v,sprof] = fit_slip_profile(data,prj1_c,prj1_v,prj2_c,prj2_v);
%determine rupture zone
[rup_zone_lim, rup_loc_mean, rup_ax] = calc_rup_zone(sprof_param,sprof_c,sprof_v,rup_thres);

%plot rupture zone
figid = plot_profile(data);
%plot projection points
figid = plot_prj_line(prj1_fun,figid);
figid = plot_prj_line(prj2_fun,figid);
hl1 = plot(rup_zone_lim(:,1),rup_zone_lim(:,2),':','LineWidth',3);
hl2 = plot(sprof(:,1),sprof(:,2),':','Color','#0072BD','LineWidth',2);
hl3 = plot(rup_loc_mean(1),rup_loc_mean(2),'o','Color','#0072BD','MarkerFaceColor','#0072BD','MarkerSize',8);
%principal axes
scl_rup_ax = 5;
hl4 = quiver(rup_loc_mean(1),rup_loc_mean(2),rup_ax(1,1),rup_ax(2,1), ...
             'Color','r','LineWidth',2,'AutoScale','on','AutoScaleFactor',scl_rup_ax,'MaxHeadSize',1);
hl5 = quiver(rup_loc_mean(1),rup_loc_mean(2),rup_ax(1,2),rup_ax(2,2), ...
             'Color','r','LineWidth',2,'AutoScale','on','AutoScaleFactor',scl_rup_ax,'MaxHeadSize',1);
legend([hl3,hl2,hl1,hl4],{'Rupture Location','Fitted Slip Profile','Rupture Zone','Principal Directions'})

end