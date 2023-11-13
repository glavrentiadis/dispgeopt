function [figid,hl,hl_all] = plot_profile_samp_pt_loc(data,prj1_samp,prj2_samp,prj1_pt,prj2_pt,prj1_data,prj2_data,prj1_fun,prj2_fun, ...
                                                      color,marker,figid)
% Plot rupture location

%default values
if nargin < 10; color  = "#D95319"; end
if nargin < 11; marker = "x"; end

%plot median profile
if nargin < 12
    figid = plot_profile_disp(data,prj1_pt,prj2_pt,[],[],prj1_fun,prj2_fun);
end

%plot geolocated points (side A)
for j = 1:length(prj1_samp); hl = plot(prj1_samp{j}(:,1),prj1_samp{j}(:,2),marker,'Color',color); end
%plot geolocated points (side B)
for j = 1:length(prj2_samp); hl = plot(prj2_samp{j}(:,1),prj2_samp{j}(:,2),marker,'Color',color); end

%reveres layer order
hl_all=get(gca, 'Children');
set(gca, 'Children',flipud(hl_all));

end