function [disp_net,disp_horiz,disp_vert,apert_width,df_summary,fname_prof_main] = analysis_deterministic(prof_name,fname_prof_main,data,dir_out,dir_fig)
% Perform deterministic analysis determining slip diplacement

%profile and analysis name
fname_prof_main = sprintf('%s_deterministic_analysis',fname_prof_main);

%number of iterations
% prompt = {'Number of iterations:'};
% dlgtitle = 'Deterministic Iterations';
% dims = [1 35];
% definput = {'1'}; % Default iterations
% n_iter = inputdlg(prompt, dlgtitle, dims, definput);
% n_iter = str2double(n_iter{1});
n_iter = 100;

%selection method
flag_select = input_pointselect();
%select master set of projection points (if not manual each iteration)
if flag_select~=1
    [prj1_data_master,side1_idx_master,figid,side1_polygon_master] = select_points_side(data,'A');
    pause(1); close(figid);
    [prj2_data_master,side2_idx_master,figid,side2_polygon_master] = select_points_side(data,'B');
    pause(1); close(figid);

    %collect projection parameters
    switch flag_select
        case 2 %feature size
            prj_params = input_prjwinsize(true);
        case 3
            prj_params = input_prjwinlin();
        otherwise
            error("Invalid selection option")
    end

    %identify origin on each side
    [s1_orj_idx,s2_orj_idx] = find_side_origin(prj1_data_master, prj2_data_master);
    %compute along projection distance
    [~,~,t1_array,~,~] = projection_fit(prj1_data_master(:,1:2));
    [~,~,t2_array,~,~] = projection_fit(prj2_data_master(:,1:2));
    %compute side distance from origin (positive further from rupture)
    t1_array = t1_array - t1_array(s1_orj_idx);
    t2_array = t2_array - t2_array(s2_orj_idx);
    t1_array = sign(mean( t1_array )) * t1_array;
    t2_array = sign(mean( t2_array )) * t2_array;
    %offset side distance from minimum value
    prj1_data_master(:,6) = t1_array - min(t1_array);
    prj2_data_master(:,6) = t2_array - min(t2_array);
end

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
% for j = 1:n_iter
j = 1; flag2iter = true;
while flag2iter
    fprintf('%s: iteration %i\n',prof_name,j)
    fname_prof_iter = sprintf('%s_iter_%i',fname_prof_main,j);

    %select projection points
    if flag_select == 1 %manual 
        [prj1_data,side1_idx{j},figid] = select_points_side(data,'A');
        pause(1); close(figid);
        [prj2_data,side2_idx{j},figid] = select_points_side(data,'B');
        pause(1); close(figid);
    else %feature size or linearity
        [feat1_loc,figid] = select_feature_loc(data, prj1_data_master, side1_polygon_master, 'A', "#0072BD");
        pause(1); close(figid);
        [feat2_loc,figid] = select_feature_loc(data, prj2_data_master, side2_polygon_master, 'B', "#D95319");
        pause(1); close(figid);
        %select projection points
        switch flag_select
            case 2 %feature size
                i_prj1 = select_feature_window(prj1_data_master, prj_params, false, feat1_loc);
                i_prj2 = select_feature_window(prj2_data_master, prj_params, false, feat2_loc);
            case 3 %feature linearity
                i_prj1 = select_feature_linear(prj1_data_master, prj_params, false, feat1_loc);
                i_prj2 = select_feature_linear(prj2_data_master, prj_params, false, feat2_loc);
            otherwise
                error("Invalid selection option")
        end
        if isempty(i_prj1) || isempty(i_prj2)
            warning("No projection points where selected")
            continue
        end
        %subset indices and projection points
        side1_idx{j} = side1_idx_master(i_prj1);
        side2_idx{j} = side2_idx_master(i_prj2);
        prj1_data = prj1_data_master(i_prj1,:);
        prj2_data = prj2_data_master(i_prj2,:);
    end
    %figure selected points projections
    figid = plot_profile(data);
    [figid, hl1] = plot_points_select(prj1_data,figid,"#0072BD");
    [figid, hl2] = plot_points_select(prj2_data,figid,"#D95319");
    title(sprintf('%s: Selected projection points',prof_name))
    legend([hl1,hl2],{'Side A','Side B'},'Location','northeast')
    saveas(figid,[dir_fig,fname_prof_iter,'_select_points','.png'])
    savefig(figid,[dir_fig,fname_prof_iter,'_select_points','.fig'])
    pause(1); close(figid);

    %azimuth angle
    prompt = {'Enter rupture azimuth angle:'};
    dlgtitle = 'Azimuth Input';
    dims = [1 35];
    definput = {'45'}; % Default value for azimuth angle
    azimuth_input = inputdlg(prompt, dlgtitle, dims, definput);
    rup_azmth(j) = str2double(azimuth_input{1});

    %select rupture location
    [rup_loc(j,:),rup_zone_lim,rup_ax,figid] = select_rup(data,prj1_data,prj2_data,rup_azmth(j));
    %plot rupture location
    title(sprintf('%s: Rupture location (mean)',prof_name))
    saveas(figid,[dir_fig,fname_prof_iter,'_rup_loc','.png'])
    savefig(figid,[dir_fig,fname_prof_iter,'_rup_loc','.fig'])    
    pause(1); close(figid);

    %compute projection;
    [prj1_c,prj1_v,~,~,prj1_fun] = projection_fit(prj1_data(:,1:3)); 
    [prj2_c,prj2_v,~,~,prj2_fun] = projection_fit(prj2_data(:,1:3)); 
    %rotate second side projection if points in oposite direction
    if dot(prj1_v,prj2_v) < 0; prj2_v =-1*prj2_v; end
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
    savefig(figid,[dir_fig,fname_prof_iter,'_slip_measurement','.fig'])
    pause(2); close(figid);

    %plot displacement aperture
    figid = plot_profile(data);
    [figid,hl1] = plot_points_select(prj1_data,figid);
    [figid,hl2] = plot_points_select(prj2_data,figid);
    %plot projection points
    [figid,hl3] = plot_prj_line(prj1_fun,figid);
    [figid,hl4] = plot_prj_line(prj2_fun,figid);
    hl5 = plot([prj1_pt(j,1),prj2_pt(j,1)],[prj1_pt(j,2),prj2_pt(j,2)],'-','Color',"#D95319",'LineWidth',2);
    apert_win2plot = [apert_win(:,1:2);flipud(apert_win(:,3:4));apert_win(1,1:2)];
    hl6 = plot(apert_win2plot(:,1), apert_win2plot(:,2),  ':','Color',[0 0.5 0],'LineWidth',3);
    title(sprintf('%s: Slip & Aperture',prof_name))
    legend([hl5,hl6,hl1,hl3],{'Slip Measurement','Aperture','Selected Points','Projection Lines'},'Location','northeast')
    anot_txt = sprintf('Net:    %.2fm\nHoriz: %.2fm\nVert:   %.2fm\nApert: %.2fm',disp_net(j),disp_horiz(j),disp_vert(j),apert_width(j));
    % text(prj2_pt(j,1)+2,prj2_pt(j,2)+2,anot_txt,'FontSize',12)
    annotation('textbox',[0.15,0.08,0.15,0.2],'String',anot_txt,'FitBoxToText','on','FontSize',12,'BackgroundColor','w','FaceAlpha',1);
    saveas(figid,[dir_fig,fname_prof_iter,'_slip_aperture','.png'])
    savefig(figid,[dir_fig,fname_prof_iter,'_slip_aperture','.fig'])
    pause(2); close(figid);

    %summary displacement
    fprintf([repmat('-',1,70),'\n'])
    fprintf('\tDisplacement\n\t\tNet: %.2fm, Hozir: %.2fm, Vert: %.2fm\n',disp_net(j),disp_horiz(j),disp_vert(j))
    fprintf('\tAperture\n\t\tWidth: %.2fm\n',apert_width(j))

    %termination options
    answer = questdlg('Continue Processing?','Processing Options', ...
	                  'Continue - keep profile','Continue - discard profile','Terminate - keep profile','Terminate - keep profile');
    switch answer
        case 'Continue - keep profile'
            j = j + 1;
        case 'Continue - discard profile'
            continue
        case 'Terminate - keep profile'
            j = j + 1;
            flag2iter = false;
    end
end

%iterations to keep
i2keep =~isnan(disp_net);
n_iter = sum(i2keep);
%displacement measurement
disp_net   = disp_net(i2keep);
disp_horiz = disp_horiz(i2keep);
disp_vert  = disp_vert(i2keep);
%point subset
side1_idx = side1_idx(i2keep);
side2_idx = side2_idx(i2keep);
%rupture point and azimuth
rup_loc   = rup_loc(i2keep,:);
rup_azmth = rup_azmth(i2keep,:);
%projection points
prj1_pt = prj1_pt(i2keep,:);
prj2_pt = prj2_pt(i2keep,:);
%aperture width
apert_width  = apert_width(i2keep);
apert1_width = apert1_width(i2keep);
apert2_width = apert2_width(i2keep);
%aperture points
apert_pt   = apert_pt(i2keep,:);
apert1_pt  = apert1_pt(i2keep,:);
apert2_pt  = apert2_pt(i2keep,:);

%displacement measurement summary
df_summary = array2table([(1:n_iter)', ...
                          disp_net,disp_horiz,disp_vert,...
                          apert_width,apert1_width,apert2_width, ...
                          rup_loc,rup_azmth,prj1_pt,prj2_pt,], ...
                         'VariableNames', ...
                         {'iter', ...
                         'disp_net','disp_horiz','disp_vert', ...
                          'apert_width_cent','apert_width_sideA','apert_width_sideB', ...
                          'rup_loc_X','rup_loc_Y','rup_azmth', ...
                          'prj_pt_sideA_X','prj_pt_sideA_Y','prj_pt_sideA_Z',...
                          'prj_pt_sideB_X','prj_pt_sideB_Y','prj_pt_sideB_Z'});
writetable(df_summary,[dir_out,fname_prof_main,'_summary_iterations','.csv'])

end