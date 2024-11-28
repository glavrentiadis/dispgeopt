function [disp_net,disp_horiz,disp_vert,apert_width,df_summary,fname_prof_main] = ...
            analysis_probabilistic(prof_name,fname_prof_main,data,dir_out,dir_fig)
% Perform probabilistic analysis determining slip diplacement

%profile and analysis name
fname_prof_main = sprintf('%s_probabilistic_analysis',fname_prof_main);

%sampling option
[flag_samp, ~, names_samp_all] = input_uncertainty_opt();

%number of samples
n_samp = input_nsamples();

%select projection points
[prj1_data,side1_idx,figid] = select_points_side(data,'A');
pause(1); close(figid);
[prj2_data,side2_idx,figid] = select_points_side(data,'B');
pause(1); close(figid);

%identify origin on each side
[s1_orj_idx,s2_orj_idx] = find_side_origin(prj1_data, prj2_data);

%figure selected points projections
figid = plot_profile(data);
[figid, hl1] = plot_points_select(prj1_data,figid,"#0072BD");
[figid, hl2] = plot_points_select(prj2_data,figid,"#D95319");
%plot origin of each side 
plot(prj1_data(s1_orj_idx,1),prj1_data(s1_orj_idx,2),'o', ...
     'MarkerEdgeColor','#0072BD','MarkerFaceColor','#0072BD','MarkerSize',15,'LineWidth',2);
plot(prj2_data(s2_orj_idx,1),prj2_data(s2_orj_idx,2),'o', ...
     'MarkerEdgeColor','#D95319','MarkerFaceColor','#D95319','MarkerSize',15,'LineWidth',2);
%add title and legend
title(sprintf('%s: Selected projection points',prof_name))
legend([hl1,hl2],{'Side A','Side B'},'Location','northeast')
saveas(figid,[dir_fig,fname_prof_main,'_select_points','.png'])
savefig(figid,[dir_fig,fname_prof_main,'_select_points','.fig'])
pause(1); close(figid);

%main projection vector 
[~,prc_v_main,~,~,~] = projection_fit(prj1_data(:,1:2));

%projection window size
if flag_samp(1)
    [prjwin_opt,prjwin_info] = input_prjwin();
    %compute along projection distance
    [~,~,t1_array,~,~] = projection_fit(prj1_data(:,1:2));
    [~,~,t2_array,~,~] = projection_fit(prj2_data(:,1:2));
    %compute side distance from origin (positive further from rupture)
    t1_array = t1_array - t1_array(s1_orj_idx);
    t2_array = t2_array - t2_array(s2_orj_idx);
    t1_array = sign(mean( t1_array )) * t1_array;
    t2_array = sign(mean( t2_array )) * t2_array;
    %offset side distance from minimum value
    prj1_data(:,6) = t1_array - min(t1_array);
    prj2_data(:,6) = t2_array - min(t2_array);
else
    prjwin_opt = 2; %dummy selection for window size
    prjwin_info = [inf, 0];
    prj1_data(:,6) = nan;
    prj2_data(:,6) = nan;
end

%projection points sampling info
if flag_samp(2); samp_p = input_probsamp();
else             samp_p = [1,1]';
end

%azimuth angle uncertainty
[rup_azmth_mean,rup_azmth_std] = input_rupture_azmth(flag_samp(6));

 %select rupture location
[rup_loc_mean,rup_zone_lim,rup_ax,figid] = select_rup(data,prj1_data,prj2_data,rup_azmth_mean);
%plot rupture location
title(sprintf('%s: Rupture location (mean)',prof_name))
saveas(figid,[dir_fig,fname_prof_main,'_rup_loc','.png'])
savefig(figid,[dir_fig,fname_prof_main,'_rup_loc','.fig'])
pause(1); close(figid);

%ruptue location uncertainty
if flag_samp(5); [rup_loc_std,rup_ax_ratio] = input_rupture_loc_unc(false);
else;             rup_loc_std=nan; rup_ax_ratio=1;
end

%principal rupture axis
rup_ax      = axis_rot(-deg2rad(rup_azmth_mean));
rup_ax(:,1) = rup_ax_ratio * rup_ax(:,1);
rup_ax      =  sqrt(2)/norm(rup_ax) * rup_ax;

%inialize data frames
%displacement values
disp_net   = nan(n_samp,1);
disp_horiz = nan(n_samp,1);
disp_vert  = nan(n_samp,1);
%point subset
i_s1 = cell(n_samp,1);
i_s2 = cell(n_samp,1);
%rupture point and azimuth
rup_pt_samp    = nan(n_samp,2);
rup_azmth_samp = nan(n_samp,1);
%sampled geolocated points
prj1_samp = cell(n_samp,1);
prj2_samp = cell(n_samp,1);
%projection points
prj1_pt = nan(n_samp,3);
prj2_pt = nan(n_samp,3);
%projection functions
prj1_fun = cell(n_samp,1);
prj2_fun = cell(n_samp,1);
%aperture width
apert_width  = nan(n_samp,1);
apert1_width = nan(n_samp,1);
apert2_width = nan(n_samp,1);
%aperture points
apert_pt  = nan(n_samp,4);
apert1_pt = nan(n_samp,4);
apert2_pt = nan(n_samp,4);

%uncertainty sampler
jj = 0;
for j = 1:n_samp
    if ~mod(j,1000); fprintf('Processing iteration %i of %i ...\n',j,n_samp); end
    %sampling
    [prj1_samp{j}, prj2_samp{j}, rup_pt_samp(j,:), rup_azmth_samp(j), i_s1{j}, i_s2{j}]  = sample_unc_mc(flag_samp,prj1_data,prj2_data, ...
                                                                                                         rup_loc_mean,rup_loc_std, ...
                                                                                                         rup_azmth_mean,rup_azmth_std, ...
                                                                                                         samp_p, ...
                                                                                                         prjwin_opt,prjwin_info, ...
                                                                                                         rup_ax,rup_zone_lim);
    
    %compute projection;
    [prj1_c,prj1_v,~,~,prj1_fun{j}] = projection_fit(prj1_samp{j}); 
    [prj2_c,prj2_v,~,~,prj2_fun{j}] = projection_fit(prj2_samp{j});
    %rotate second side projection if points in oposite direction
    %first component
    if dot(prc_v_main,prj1_v) < 0
        prj1_v =-1*prj1_v;
        %update projection function
        prj1_fun{j} = @(t) (prj1_c + prj1_v*t)';
    end
    %second component
    if dot(prc_v_main,prj2_v) < 0
        prj2_v =-1*prj2_v;
        %update projection function
        prj2_fun{j} = @(t) (prj2_c + prj2_v*t)';
    end
    %average projecton
    prj_c = mean([prj1_c,prj2_c],2);
    prj_v = mean([prj1_v,prj2_v],2); 

    %determine intersection points
    prj1_pt(j,:) = intersect_projection(prj1_c,prj1_v,rup_pt_samp(j,:)',rup_azmth_samp(j));
    prj2_pt(j,:) = intersect_projection(prj2_c,prj2_v,rup_pt_samp(j,:)',rup_azmth_samp(j));

    %compute displacements
    disp_net(j)   = norm(prj1_pt(j,:)-prj2_pt(j,:));
    disp_horiz(j) = norm(prj1_pt(j,1:2)-prj2_pt(j,1:2));
    disp_vert(j)  = abs(prj1_pt(j,3)-prj2_pt(j,3));

    %compute apature width
    [apert_width(j),apert_pt(j,1:2),apert_pt(j,3:4)]    = calc_aperture(prj1_samp{j},prj2_samp{j},prj_v,prj_c,rup_azmth_samp(j));
    [apert1_width(j),apert1_pt(j,1:2),apert1_pt(j,3:4)] = calc_aperture(prj1_samp{j},prj2_samp{j},prj1_v,prj1_c,rup_azmth_samp(j));
    [apert2_width(j),apert2_pt(j,1:2),apert2_pt(j,3:4)] = calc_aperture(prj1_samp{j},prj2_samp{j},prj2_v,prj2_c,rup_azmth_samp(j));
    apert_win = [apert1_pt(j,:);apert_pt(j,:);apert2_pt(j,:)];

    %representative figures
    if mod(j,10^round(log10(n_samp/10))) == 0
        jj = jj + 1;
        fname_prof_iter = sprintf('%s_iter_%i',fname_prof_main,jj);

        %plot displacement measurement
        figid = plot_profile(data);
        [figid,hl1] = plot_points_select(prj1_samp{j},figid);
        [figid,hl2] = plot_points_select(prj2_samp{j},figid);
        %plot projection points
        [figid,hl3] = plot_prj_line(prj1_fun{j},figid);
        [figid,hl4] = plot_prj_line(prj2_fun{j},figid);
        hl5 = plot([prj1_pt(j,1),prj2_pt(j,1)],[prj1_pt(j,2),prj2_pt(j,2)],'-','Color',"#D95319",'LineWidth',2);
        title(sprintf('%s: Slip Measurement (iter: %i)',prof_name,j))
        legend([hl5,hl1,hl3],{'Slip Measurement','Selected Points','Projection Lines'},'Location','northeast')
        anot_txt = sprintf('Net:    %.2fm\nHoriz: %.2fm\nVert:   %.2fm',disp_net(j),disp_horiz(j),disp_vert(j));
        % text(prj2_pt(j,1)+2,prj2_pt(j,2)+2,anot_txt,'FontSize',12)
        annotation('textbox',[0.15,0.05,0.15,0.2],'String',anot_txt,'FitBoxToText','on','FontSize',12,'BackgroundColor','w','FaceAlpha',1);
        saveas(figid,[dir_fig,fname_prof_iter,'_slip_measurement','.png'])
        savefig(figid,[dir_fig,fname_prof_iter,'_slip_measurement','.fig'])
        close(figid);
    
        %plot displacement aperture
        figid = plot_profile(data);
        [figid,hl1] = plot_points_select(prj1_samp{j},figid);
        [figid,hl2] = plot_points_select(prj2_samp{j},figid);
        %plot projection points
        [figid,hl3] = plot_prj_line(prj1_fun{j},figid);
        [figid,hl4] = plot_prj_line(prj2_fun{j},figid);
        hl5 = plot([prj1_pt(j,1),prj2_pt(j,1)],[prj1_pt(j,2),prj2_pt(j,2)],'-','Color',"#D95319",'LineWidth',2);
        apert_win2plot = [apert_win(:,1:2);flipud(apert_win(:,3:4));apert_win(1,1:2)];
        hl6 = plot(apert_win2plot(:,1), apert_win2plot(:,2),  ':','Color',[0 0.5 0],'LineWidth',3);
        title(sprintf('%s: Slip & Aperture (iter: %i)',prof_name,j))
        legend([hl5,hl6,hl1,hl3],{'Slip Measurement','Aperture','Selected Points','Projection Lines'},'Location','northeast')
        anot_txt = sprintf('Net:    %.2fm\nHoriz: %.2fm\nVert:   %.2fm\nApert: %.2fm',disp_net(j),disp_horiz(j),disp_vert(j),apert_width(j));
        % text(prj2_pt(j,1)+2,prj2_pt(j,2)+2,anot_txt,'FontSize',12)
        annotation('textbox',[0.15,0.08,0.15,0.2],'String',anot_txt,'FitBoxToText','on','FontSize',12,'BackgroundColor','w','FaceAlpha',1);
        saveas(figid,[dir_fig,fname_prof_iter,'_slip_aperture','.png'])
        savefig(figid,[dir_fig,fname_prof_iter,'_slip_aperture','.fig'])
        close(figid);
    end
end
fprintf('Sampling complete.\n')

%quantiles (net displacement)
q = (1:length(disp_net))'/length(disp_net);
[~, i_q] = sort(disp_net);
%selected quantiles
[~, i_q50] = min( abs(q-0.50) ); i_q50 = i_q(i_q50);

%plot percentile range 
quantiles = {[0.02,0.98],0.50};
color     = {"#77AC30","#0072BD"}; 
[figid,hl1,hl2] = plot_profile_disp_quantile_range(disp_net,data,prj1_fun,prj2_fun,prj1_pt,prj2_pt,quantiles,color);
legend(fliplr(hl1),{'Median Net Displacement','2-98% Percentile Net Displacement'})
title(sprintf('%s: Uncertainty Range',prof_name))
saveas(figid,[dir_fig,fname_prof_main,'_quantile_samp','.png'])
savefig(figid,[dir_fig,fname_prof_main,'_quantile_samp','.fig'])
pause(1); close(figid);

%plot rupture location sampling
[figid,hl1] = plot_profile_rupture_loc(data,rup_pt_samp,prj1_pt(i_q50,:),prj2_pt(i_q50,:), ...
                                       prj1_data,prj2_data,prj1_fun{i_q50},prj2_fun{i_q50});
if isempty(rup_zone_lim)
    legend([hl1],{'Rupture Location Samples'})
else
    hl2 = plot(rup_zone_lim(:,1),rup_zone_lim(:,2),':','LineWidth',3);
    legend([hl1,hl2],{'Rupture Location Samples','Rupture Zone'})
end
title(sprintf('%s: Rupture Location Uncertainty',prof_name))
saveas(figid,[dir_fig,fname_prof_main,'_rup_loc_samp','.png'])
savefig(figid,[dir_fig,fname_prof_main,'_rup_loc_samp','.fig'])
pause(1); close(figid);

%plot projection point sampling
[figid,hl1,~] = plot_profile_samp_pt_loc(data,prj1_samp,prj2_samp,prj1_pt(i_q50,:),prj2_pt(i_q50,:), ...
                                       prj1_data,prj2_data,prj1_fun{i_q50},prj2_fun{i_q50});
legend(hl1,{'Projection Points Location Samples'})
title(sprintf('%s: Projection Points Location Uncertainty',prof_name))
saveas(figid,[dir_fig,fname_prof_main,'_prj_pt_samp','.png'])
savefig(figid,[dir_fig,fname_prof_main,'_prj_pt_samp','.fig'])
pause(1); close(figid);

%displacement measurement summary
df_summary = array2table([(1:n_samp)', ...
                          disp_net,disp_horiz,disp_vert,...
                          apert_width,apert1_width,apert2_width, ...
                          rup_pt_samp,rup_azmth_samp,prj1_pt,prj2_pt], ...
                         'VariableNames', ...
                         {'samp', ...
                         'disp_net','disp_horiz','disp_vert', ...
                          'apert_width_cent','apert_width_sideA','apert_width_sideB', ...
                          'rup_loc_X','rup_loc_Y','rup_azmth', ...
                          'prj_pt_sideA_X','prj_pt_sideA_Y','prj_pt_sideA_Z',...
                          'prj_pt_sideB_X','prj_pt_sideB_Y','prj_pt_sideB_Z'});
writetable(df_summary,[dir_out,fname_prof_main,'_summary_iterations','.csv'])

%summary input
df_inpt = array2table([samp_p',winsize_info',rup_azmth_mean,rup_azmth_std,rup_loc_std,rup_ax_ratio], ...
                      'VariableNames', ...
                      {'p_samp_sideA','p_samp_sideB','win_size_mean','win_size_std',...
                      'rup_azmth_mean','rup_azmth_std','rup_loc_std','rup_ax_ratio'});
%add component uncertainty information
names_samp_all = strrep(lower(names_samp_all),' ','_');
df_inpt{1,names_samp_all} = flag_samp;
writetable(df_inpt,[dir_out,fname_prof_main,'_summary_input_param','.csv'])

end
