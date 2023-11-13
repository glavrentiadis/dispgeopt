function [figid,hl,hl_all] = plot_profile_rupture_loc(data,rup_pt_samp,prj1_pt,prj2_pt,prj1_data,prj2_data,prj1_fun,prj2_fun, ...
                                                      color,marker,figid)
% Plot rupture location

%default values
if nargin < 9;  color  = "#77AC30"; end
if nargin < 10; marker = "x"; end

%plot median profile
if nargin < 11
    figid = plot_profile_disp(data,prj1_pt,prj2_pt,prj1_data,prj2_data,prj1_fun,prj2_fun);
end

%plot rupture location
hl = plot(rup_pt_samp(:,1),rup_pt_samp(:,2),marker,'Color',color);

%reveres layer order
hl_all = get(gca, 'Children');
set(gca, 'Children',flipud(hl_all));

end