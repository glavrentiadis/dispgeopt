%test2
% evaluate sampling scripts
clear; clc; 
close all

addpath('./../src/')
addpath('./../src/sampling/')
addpath('./../ui/')
addpath('./../ui/plotting')


%load file
[data,prof_name] = open_profile();

%plot data
figid = plot_profile(data);
%select edge points
[prj1_data,figid] = select_points_side(data,'A',figid);
[prj2_data,figid] = select_points_side(data,'B',figid);

%select rupture point
disp('Select rupture center point (left-click to select).');
rup_loc_mean = zeros(2,1);
[rup_loc_mean(1), rup_loc_mean(2)] = ginput(1); % User selects the center point for Line 3
%azimuth angle and uncertainty
[rup_azmth_mean,rup_azmth_std,rup_loc_std] = input_rupture(true);
close(figid)

%number of samples
dlgtitle = 'Sampling info';
prompt = {'Number of samples:';'Sampling probability (side A):';'Sampling probability (side B):'};
dims = [1 35; 1 35; 1 35];
definput = {'10000';'0.8';'0.8'};
samp_info = inputdlg(prompt, dlgtitle, dims, definput);
samp_n = str2double(samp_info{1});
samp_p = cellfun(@(x) str2double(x), samp_info(2:3));

%sampling option
flag_samp = input_uncertainty_opt();

%inialize data frames
%displacement values
disp_net   = nan(samp_n,1);
disp_horiz = nan(samp_n,1);
disp_vert  = nan(samp_n,1);
%point subset
i_s1 = cell(samp_n,1);
i_s2 = cell(samp_n,1);
%rupture point and azimuth
rup_pt_samp    = nan(samp_n,2);
rup_azmth_samp = nan(samp_n,1);
%projection points
prj1_pt = nan(samp_n,3);
prj2_pt = nan(samp_n,3);
%projection functions
prj1_fun = cell(samp_n,1);
prj2_fun = cell(samp_n,1);


%sampler
for k = 1:samp_n
    if ~mod(k,1000); fprintf('Processing iteration %i of %i ...\n',k,samp_n); end
    %sampling
    [prj1_samp, prj2_samp, rup_pt_samp(k,:), rup_azmth_samp(k), i_s1{k}, i_s2{k}]  = sample_unc_mc(flag_samp,prj1_data,prj2_data, ...
                                                                                                   rup_loc_mean,rup_azmth_mean,rup_loc_std, ...
                                                                                                   rup_azmth_std,nan,samp_p);
    
    %compute projection;
    [prj1_c,prj1_v,prj1_tlim,prj1_fun{k}] = projection_fit(prj1_samp); 
    [prj2_c,prj2_v,prj2_tlim,prj2_fun{k}] = projection_fit(prj2_samp); 
    
    %determine intersection points
    prj1_pt(k,:) = intersect_projection(prj1_c,prj1_v,rup_pt_samp(k,:)',rup_azmth_samp(k));
    prj2_pt(k,:) = intersect_projection(prj2_c,prj2_v,rup_pt_samp(k,:)',rup_azmth_samp(k));

    %compute displacements
    disp_net(k)   = norm(prj1_pt(k,:)-prj2_pt(k,:));
    disp_horiz(k) = norm(prj1_pt(k,1:2)-prj2_pt(k,1:2));
    disp_vert(k)  = abs(prj1_pt(k,3)-prj2_pt(k,3));
end
fprintf('Sampling complete.\n',k,samp_n)

%quantiles
q = (1:length(disp_net))'/length(disp_net);
%displacement quantile indices
[~, i_q] = sort(disp_net);
%selected quantiles
[~, i_q50] = min( abs(q-0.50) ); i_q50 = i_q(i_q50);

% distribution comparision
% - - - - - - -
%net displacement
fig_title = [prof_name,': net displacement'];
figid = plot_disp_distribution(disp_net,fig_title);
%horizontal displacement
fig_title = [prof_name,': horizontal displacement'];
figid = plot_disp_distribution(disp_horiz,fig_title);
%vertical displacement
fig_title = [prof_name,': vertical displacement'];
figid = plot_disp_distribution(disp_vert,fig_title);


%plot percentile range (lines)
figid = plot_profile_disp_quantiles(disp_net,data,prj1_data,prj2_data,i_s1,i_s2,prj1_fun,prj2_fun,prj1_pt,prj2_pt);
%plot percentile range (filled)
figid = plot_profile_disp_quantile_range(disp_net,data,prj1_data,prj2_data,i_s1,i_s2,prj1_fun,prj2_fun,prj1_pt,prj2_pt);

% rupture sampling
% - - - - - - - 
figid = plot_profile_rupture_loc(data,rup_pt_samp,prj1_pt(i_q50,:),prj2_pt(i_q50,:), ...
                                 prj1_data,prj2_data,prj1_fun{i_q50},prj2_fun{i_q50});


