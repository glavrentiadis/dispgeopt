function [figid] = plot_disp_distribution(disp_array,fig_title)
%Plot PDF and CDF of displacement distribution

%distribution fit
%normal distribution;
d_norm_fit = [mean(disp_array), std(disp_array)];
%gamma distribution
d_gamma_fit = gamfit(disp_array);

%empirical distribution
[e_cdf, e_x] = ecdf(disp_array);

%range
x = linspace(min(e_x)-2.0,max(e_x)+2.0, 5000);

%plot uncertainty 
figid = figure;
%pdf comparison
subplot(1,2,1)
histogram(disp_array,'Normalization','pdf','FaceColor','k','FaceAlpha',0.1); hold on; xlims1 = xlim();
plot(x, normpdf(x,d_norm_fit(1),d_norm_fit(2)),  'LineWidth',2,'Color',"#0072BD")
plot(x, gampdf(x,d_gamma_fit(1),d_gamma_fit(2)), 'LineWidth',2,'Color',"#D95319")
grid on
xlabel('Displacment (m)')
ylabel('PDF')
%cdf comparison
subplot(1,2,2)
plot(e_x,e_cdf,  'LineWidth',3,'Color',"k"); hold on; xlims2 = xlim();
plot(x, normcdf(x,d_norm_fit(1),d_norm_fit(2)),  'LineWidth',2,'Color',"#0072BD")
plot(x, gamcdf(x,d_gamma_fit(1),d_gamma_fit(2)), 'LineWidth',2,'Color',"#D95319")
grid on
xlabel('Displacment (m)')
ylabel('CDF')
%legend
legend({'Empirical','Normal','Gamma'},'Location','southeast')
%figure limits
xlims3 = round(max(d_norm_fit(1) + [-.5, 0.5], 0), 1);
xlims = [min([xlims1(1),xlims2(1),xlims3(1)]),max([xlims1(2),xlims2(2),xlims3(2)])];
subplot(1,2,1); xlim(xlims)
subplot(1,2,2); xlim(xlims)
%main figure title
sgtitle(fig_title) 


end