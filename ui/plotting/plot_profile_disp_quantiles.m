function [figid] = plot_profile_disp_quantiles(disp_array,data,prj1_data,prj2_data,i_s1,i_s2,prj1_fun,prj2_fun,prj1_pt,prj2_pt,quantiles,figid,color,marker)
% Plot projection and piercing line range for provided quantiles

%default input
if nargin < 11; quantiles = [0.16,0.84,0.02,0.98,0.50];                          end
if nargin < 13; color     = {"#D95319","#D95319","#77AC30","#77AC30","#0072BD"}; end
if nargin < 14; marker    = {'o','o','s','s','d'};                               end

%check input
assert(all(length(quantiles) == [length(color),length(marker)]),'Inconsistent quantiles, color, and marker size.')

%quantiles
q = (1:length(disp_array))'/length(disp_array);
%displacement quantile indices
[~, i_q] = sort(disp_array);

%indices for selected quantiles
i_q_slct = nan(length(quantiles),1);
for k = 1:length(quantiles)
    [~, j] = min( abs(q-quantiles(k)) ); i_q_slct(k) = i_q(j);
end

%plot data
if nargin < 12; figid = plot_profile(data); end
%plot projection and piercing lines
for k = 1:length(quantiles)
    %plot discrete lines
    figid = plot_prj_line(prj1_fun{i_q_slct(k)},figid,color{k});
    figid = plot_prj_line(prj2_fun{i_q_slct(k)},figid,color{k});
    plot([prj1_pt(i_q_slct(k),1),prj2_pt(i_q_slct(k),1)],[prj1_pt(i_q_slct(k),2),prj2_pt(i_q_slct(k),2)],'-','Color',color{k},'LineWidth',2);
end
%selected ponts
for k = 1:length(quantiles)
    figid = plot_points_select(prj1_data(i_s1{i_q_slct(k)},:),figid,color{k},marker{k});
    figid = plot_points_select(prj2_data(i_s2{i_q_slct(k)},:),figid,color{k},marker{k});
end


end