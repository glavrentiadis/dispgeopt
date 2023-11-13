function [figid,hl1,hl2,quantiles] = plot_profile_disp_quantile_range(disp_array,data,prj1_fun,prj2_fun,prj1_pt,prj2_pt, ...
                                                                      quantiles,color,marker,figid)
% Plot projection and piercing line range for provided quantiles

%default input
if nargin < 7; quantiles = {[0.02,0.98],[0.16,0.84],0.50};  end
if nargin < 8; 
    color = {"#77AC30","#D95319","#0072BD"}; 
    color = color(1:length(quantiles));
end
if nargin < 9; 
    marker = {'s','o','d'};
    marker = marker(1:length(quantiles));
end

%check input
assert(all(length(quantiles) == [length(color),length(marker)]),'Inconsistent quantiles, color, and marker size.')

%quantiles
q = (1:length(disp_array))'/length(disp_array);
%displacement quantile indices
[~, i_q] = sort(disp_array);

%plot data
if nargin < 10; figid = plot_profile(data); end
%plot projection and piercing lines
for j1 = 1:length(quantiles)
    %indices for selected quantiles
    i_q_slct = nan(1,length(quantiles{j1}));
    for j2 = 1:length(quantiles{j1})
        [~, i] = min( abs(q-quantiles{j1}(j2)) ); i_q_slct(j2) = i_q(i);
    end
    if length(i_q_slct) == 1
        %piercing line
        hl1(j1)  =  plot([prj1_pt(i_q_slct,1),prj2_pt(i_q_slct,1)],[prj1_pt(i_q_slct,2),prj2_pt(i_q_slct,2)],'-','Color',color{j1},'LineWidth',2);
        %projection lines
        [figid,hl2(j1)] = plot_prj_line(prj1_fun{i_q_slct},figid,color{j1}); %side A
        [figid,~]       = plot_prj_line(prj2_fun{i_q_slct},figid,color{j1}); %side B
    else
        %piercing range
        prj_pt = [prj1_pt(i_q_slct,:);flipud(prj2_pt(i_q_slct,:));prj1_pt(i_q_slct(1),:)];
        hl1(j1)  =  fill(prj_pt(:,1),prj_pt(:,2),1,'EdgeColor','none','FaceAlpha',0.5,'FaceColor',color{j1});
        hl1a(j1) = plot([prj1_pt(i_q_slct(1),1),prj2_pt(i_q_slct(1),1)],[prj1_pt(i_q_slct(1),2),prj2_pt(i_q_slct(1),2)],'-','Color',color{j1},'LineWidth',2);
        hl1b(j1) = plot([prj1_pt(i_q_slct(2),1),prj2_pt(i_q_slct(2),1)],[prj1_pt(i_q_slct(2),2),prj2_pt(i_q_slct(2),2)],'-','Color',color{j1},'LineWidth',2);
        %projection range
        [figid,hl2(j1)] = plot_prj_line_range(prj1_fun{i_q_slct(1)},prj1_fun{i_q_slct(2)},figid,color{j1}); %side A
        [figid,~]       = plot_prj_line_range(prj2_fun{i_q_slct(1)},prj2_fun{i_q_slct(2)},figid,color{j1}); %side B
    end
end

end