function [figid] = plot_profile_disp(data,prj1_pt,prj2_pt,prj1_data,prj2_data,prj1_fun,prj2_fun,color,linestyle,figid)
% Plot profile and displacement projections

%default values
if nargin < 8; color      = "#D95319"; end
if nargin < 9; linestyle = "-"; end

%plot raw profile
if nargin < 10
    %plot profile
    figid = plot_figaxes(data);
    figid = plot_profile(data,figid);
end
%plot selected points for projections
figid = plot_points_select(prj1_data,figid);
figid = plot_points_select(prj2_data,figid);
%plot projection points
figid = plot_prj_line(prj1_fun,figid);
figid = plot_prj_line(prj2_fun,figid);
%plot displacment
plot([prj1_pt(1),prj2_pt(1)],[prj1_pt(2),prj2_pt(2)],linestyle,'Color',color,'LineWidth',2);

end