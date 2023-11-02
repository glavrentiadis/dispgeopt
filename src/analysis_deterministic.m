function [disp_net,disp_horiz,disp_vert,apert_width,df_summary] = analysis_deterministic(prof_name,fname_prof_main,data,dir_out,dir_fig)
% 

%number of iterations
prompt = {'Number of iterations:'};
dlgtitle = 'Deterministic Iterations';
dims = [1 35];
definput = {'1'}; % Default iterations
n_iter = inputdlg(prompt, dlgtitle, dims, definput);
n_iter = str2double(n_iter{1});

%initialize arrays
%displacement measurement
disp_net   = nan(n_iter,1);
disp_horiz = nan(n_iter,1);
disp_vert  = nan(n_iter,1);
%point subset
side1_idx = cell(n_iter,1);
side2_idx = cell(n_iter,1);
%rupture point and azimuth
rup_loc   = nan(n_iter,2);
rup_azmth = nan(n_iter,1);
%projection points
prj1_pt = nan(n_iter,3);
prj2_pt = nan(n_iter,3);
%aperture width
apert_width  = nan(n_iter,1);
apert1_width = nan(n_iter,1);
apert2_width = nan(n_iter,1);
%aperture points
apert_pt  = nan(n_iter,4);
apert1_pt  = nan(n_iter,4);
apert2_pt  = nan(n_iter,4);

%iterate analyses
for j = 1:n_iter
    fprintf('%s: iteration %i of %i\n',prof_name,j,n_iter)
    fname_prof_iter = sprintf('%s_iter_%i',fname_prof_main,j);

    %select projection points
    [prj1_data,side1_idx{j},figid] = select_points_side(data,'A');
    pause(1); close(figid);
    [prj2_data,side2_idx{j},figid] = select_points_side(data,'B');
    pause(1); close(figid);

    %figure selected points projections
    figid = plot_profile(data);
    [figid, hl1] = plot_points_select(prj1_data,figid,"#0072BD");
    [figid, hl2] = plot_points_select(prj2_data,figid,"#D95319");
    title(sprintf('%s: Selected projection points',prof_name))
    legend([hl1,hl2],{'Side A','Side B'},'Location','northeast')
    saveas(figid,[dir_fig,fname_prof_iter,'_select_points','.png'])
    pause(1); close(figid);

    %select rupture point
    %method
    [flag_rup_pt] = listdlg('ListString',{'Manual','Auto'}, ...
                            'PromptString','Determine rupture location:','Name','Rupture Location', ...
                            'SelectionMode','single','ListSize',[250,100]);
    switch flag_rup_pt
        case 1 %manual
            [rup_loc(j,:),rup_zone_lim,rup_ax,figid] = determine_rup_manual(data,prj1_data,prj2_data);
        case 2 %automatic
            [rup_loc(j,:),rup_zone_lim,rup_ax,figid] = determine_rup_auto(data,prj1_data,prj2_data);
    end
    %plot rupture location
    title('Rupture location')
    saveas(figid,[dir_fig,fname_prof_iter,'_rup_loc','.png'])
    pause(1); close(figid);

    %azimuth angle
    prompt = {'Enter rupture azimuth angle:'};
    dlgtitle = 'Azimuth Input';
    dims = [1 35];
    definput = {'45'}; % Default value for azimuth angle
    azimuth_input = inputdlg(prompt, dlgtitle, dims, definput);
    rup_azmth(j) = str2double(azimuth_input{1});

    %compute projection;
    [prj1_c,prj1_v,prj1_tlim,prj1_fun] = projection_fit(prj1_data(:,1:3)); 
    [prj2_c,prj2_v,prj2_tlim,prj2_fun] = projection_fit(prj2_data(:,1:3)); 
    %average projecton
    prj_c = mean([prj1_c,prj2_c],2);
    prj_v = mean([prj1_v,prj2_v],2); 

    %determine intersection points
    prj1_pt(j,:) = intersect_projection(prj1_c,prj1_v,rup_loc(j,:)',rup_azmth(j));
    prj2_pt(j,:) = intersect_projection(prj2_c,prj2_v,rup_loc(j,:)',rup_azmth(j));

    %compute slip
    disp_net(j)   = norm(prj1_pt(j,:)   - prj2_pt(j,:));
    disp_horiz(j) = norm(prj1_pt(j,1:2) - prj2_pt(j,1:2));
    disp_vert(j)  = norm(prj1_pt(j,3)   - prj2_pt(j,3));

    %compute apature width
    [apert_width(j),apert_pt(j,1:2),apert_pt(j,3:4)]    = calc_aperture(prj1_data,prj2_data,prj_v,prj_c,rup_azmth(j));
    [apert1_width(j),apert1_pt(j,1:2),apert1_pt(j,3:4)] = calc_aperture(prj1_data,prj2_data,prj1_v,prj1_c,rup_azmth(j));
    [apert2_width(j),apert2_pt(j,1:2),apert2_pt(j,3:4)] = calc_aperture(prj1_data,prj2_data,prj2_v,prj2_c,rup_azmth(j));
    apert_win = [apert1_pt(j,:);apert_pt(j,:);apert2_pt(j,:)];

    %plot displacement measurement
    figid = plot_profile(data);
    [figid,hl1] = plot_points_select(prj1_data,figid);
    [figid,hl2] = plot_points_select(prj2_data,figid);
    %plot projection points
    [figid,hl3] = plot_prj_line(prj1_fun,figid);
    [figid,hl4] = plot_prj_line(prj2_fun,figid);
    hl5 = plot([prj1_pt(j,1),prj2_pt(j,1)],[prj1_pt(j,2),prj2_pt(j,2)],'-','Color',"#D95319",'LineWidth',2);
    title(sprintf('%s: Slip Measurement',prof_name))
    legend([hl5,hl1,hl3],{'Slip Measurement','Selected Points','Projection Lines'},'Location','northeast')
    anot_txt = sprintf('Net:    %.2fm\nHoriz: %.2fm\nVert:   %.2fm',disp_net(j),disp_horiz(j),disp_vert(j));
    % text(prj2_pt(j,1)+2,prj2_pt(j,2)+2,anot_txt,'FontSize',12)
    annotation('textbox',[0.15,0.05,0.15,0.2],'String',anot_txt,'FitBoxToText','on','FontSize',12,'BackgroundColor','w','FaceAlpha',1);
    saveas(figid,[dir_fig,fname_prof_iter,'_slip_measurement','.png'])
    pause(2); close(figid);

    %plot displacement aperture
    figid = plot_profile(data);
    [figid,hl1] = plot_points_select(prj1_data,figid);
    [figid,hl2] = plot_points_select(prj2_data,figid);
    %plot projection points
    [figid,hl3] = plot_prj_line(prj1_fun,figid);
    [figid,hl4] = plot_prj_line(prj2_fun,figid);
    hl5 = plot([prj1_pt(j,1),prj2_pt(j,1)],[prj1_pt(j,2),prj2_pt(j,2)],'-','Color',"#D95319",'LineWidth',2);
    apert_win2plot = [apert_win(:,1:2);flipud(apert_win(:,3:4));apert_win(:,1:2)];
    hl6 = plot(apert_win2plot(:,1), apert_win2plot(:,2),  ':','Color',[0 0.5 0],'LineWidth',3);
    title(sprintf('%s: Slip & Aperture',prof_name))
    legend([hl5,hl6,hl1,hl3],{'Slip Measurement','Aperture','Selected Points','Projection Lines'},'Location','northeast')
    anot_txt = sprintf('Net:    %.2fm\nHoriz: %.2fm\nVert:   %.2fm\nApert: %.2fm',disp_net(j),disp_horiz(j),disp_vert(j),apert_width(j));
    % text(prj2_pt(j,1)+2,prj2_pt(j,2)+2,anot_txt,'FontSize',12)
    annotation('textbox',[0.15,0.08,0.15,0.2],'String',anot_txt,'FitBoxToText','on','FontSize',12,'BackgroundColor','w','FaceAlpha',1);
    saveas(figid,[dir_fig,fname_prof_iter,'_slip_aperture','.png'])
    pause(2); close(figid);

    %summary displacement
    fprintf('\tDisplacement\n\t\tNet: %.2fm, Hozir: %.2fm, Vert: %.2fm\n',disp_net(j),disp_horiz(j),disp_vert(j))
    fprintf('\tAperture\n\t\tWidth: %.2fm\n',apert_width(j))
    fprintf([repmat('-',1,70),'\n'])
end

%displacement measurement summary
df_summary = array2table([disp_net,disp_horiz,disp_vert,...
                          apert_width,apert1_width,apert2_width, ...
                          rup_loc,rup_azmth,prj1_pt,prj2_pt,], ...
                         'VariableNames', ...
                         {'disp_net','disp_horiz','disp_vert', ...
                          'apert_width_cent','apert_width_sideA','apert_width_sideB', ...
                          'rup_loc_X','rup_loc_Y','rup_azmth', ...
                          'prj_pt_sideA_X','prj_pt_sideA_Y','prj_pt_sideA_Z',...
                          'prj_pt_sideB_X','prj_pt_sideB_Y','prj_pt_sideB_Z'});
writetable(df_summary,[dir_out,fname_prof_main,'_summary_iterations','.csv'])

end