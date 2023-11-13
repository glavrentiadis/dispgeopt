function [figid,rank_unc_idx] = plot_disp_unc_tornado(disp_data,names_data)
% Tornado plot based on box-chart port

%quantiles box plot
qbox = [0.25, 0.75];

%initialize disp 
dmed   = nan(length(disp_data),1);
dmean  = nan(length(disp_data),1);
%initialize disp range
dr4eval = nan(length(disp_data),1);

%number of diplacement sets
n_d = length(disp_data);

%iterate over datasets
for j = 1:n_d
    %displacement range
    dr4eval(j) = diff( quantile(disp_data{j},qbox) );
    %median and mean displacement
    dmed(j)     = median(disp_data{j});
    dmean(j)    = mean(disp_data{j});
end

%rank displacement range components
[~,i_rnk] = sort(dr4eval, 'ascend');

%tornado plot
figid = figure;
hl = boxplot(cell2mat(disp_data(i_rnk)'),'orientation','horizontal');
set(hl,{'linew','color'},{1.5,'k'})
grid on
yticklabels(names_data(i_rnk))
xlabel('Displacment (m)')

%rank components from biggest to smallest
rank_unc_idx = fliplr(reshape(i_rnk,1,[]));

end