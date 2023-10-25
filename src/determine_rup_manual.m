function [rup_loc_mean,rup_zone_lim,rup_ax,figid] = determine_rup_manual(data,prj1_data,prj2_data)
% user selection of rupture location

%compute projection;
[prj1_c,prj1_v,prj1_tlim,prj1_fun] = projection_fit(prj1_data(:,1:3)); 
[prj2_c,prj2_v,prj2_tlim,prj2_fun] = projection_fit(prj2_data(:,1:3)); 

%plot rupture data
figid = plot_profile(data);
% figid = plot_points_select(prj1_data,figid);
% figid = plot_points_select(prj2_data,figid);
figid = plot_prj_line(prj1_fun,figid);
figid = plot_prj_line(prj2_fun,figid);

%rupture location prompt
title('Select rupture location')
disp('Select rupture location (left-click to select).');
rup_loc_mean = zeros(2,1);
[rup_loc_mean(1), rup_loc_mean(2)] = ginput(1); % User selects the center point for Line 3
%undefined rupture zone and axes
rup_zone_lim = [];
rup_ax       = [];

%plot rupture location
hl3 = plot(rup_loc_mean(1),rup_loc_mean(2),'o','Color','#0072BD','MarkerFaceColor','#0072BD','MarkerSize',8);
legend([hl3],{'Rupture Location'})

end