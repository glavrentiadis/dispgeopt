function [side1_data,side2_data,rup_pt,azmth_angle,i_s1,i_s2] = sample_unc_mc(flag_samp,side1_data,side2_data,rup_pt_mean,rup_pt_unc,azmth_angle_mean,azmth_angle_unc,samp_pt_p,rup_ax,rup_lim)
% Sample input parameter uncertainty through monte carlo
%
% Input arguments:
%   flag_samp:          flag for uncertainty component samling
%   side1_data (mat[n_s1,5]): coordinates and uncertainty for points of side A 
%   side2_data  (mat[n_s2,5]): coordinates and uncertainty for points of side B 
%   rup_pt_mean (array[2]): mean of rupture location
%   rup_pt_unc (array[2]): ucertainty for rupture location
%   azmth_angle_mean (double): mean azimuth angle
%   azmth_angle_unc (doulbe): uncertainty of azimuth angle
%   samp_pt_p (array[2]): projection points' sampling probability
%   rup_ax (mat[2,2]): principal rupture axes
%   rup_lim (mag[n_r,2]): rupture zone
%
% Output arguments:
%   side1_data
%   side2_data
%   rup_pt
%   azmth_angle
%   i_s1
%   i_s2


%default input
if nargin < 6;  rup_pt_unc      = 2.5;       end
if nargin < 7;  azmth_angle_unc = 5;         end
if nargin < 8;  samp_pt_p       = [0.8,0.8]; end
if nargin < 9;  rup_ax          = eye(2);    end
if nargin < 10; rup_lim         = nan;       end

%confirm sampling specifications
assert(length(flag_samp)==5,'Invalid number of sampling options')

%sample data point populations
if flag_samp(1)
    %data points to select
    while true
        i_s1 = find( binornd(true,samp_pt_p(1)*ones(size(side1_data,1),1)) );
        if length(i_s1)>=4; break; end
    end
    while true
        i_s2 = find( binornd(true,samp_pt_p(2)*ones(size(side2_data,1),1)) );
        if length(i_s2)>=4; break; end
    end
else
    i_s1 = (1:size(side1_data,1))';
    i_s2 = (1:size(side2_data,1))';
end
%data downsampling
side1_data = side1_data(i_s1,:);
side2_data = side2_data(i_s2,:);

%sample horizontal uncertainty
if flag_samp(2)
    %side 1
    side1_data(:,1) = normrnd(side1_data(:,1),side1_data(:,4));
    side1_data(:,2) = normrnd(side1_data(:,2),side1_data(:,4));
    %side 2
    side2_data(:,1) = normrnd(side2_data(:,1),side2_data(:,4));
    side2_data(:,2) = normrnd(side2_data(:,2),side2_data(:,4));
end

%sample verical uncertainty
if flag_samp(3)
    %side 1
    side1_data(:,3) = normrnd(side1_data(:,3),side1_data(:,5));
    %side 2
    side2_data(:,3) = normrnd(side2_data(:,3),side2_data(:,5));
end

%extract projection location
side1_data = side1_data(:,1:3);
side2_data = side2_data(:,1:3);

%sample rupture location
if flag_samp(4)
    while true
        %random variability
        rup_pt = normrnd([0;0],rup_pt_unc);
        %shift and rotation rupture point
        rup_pt = rup_pt_mean + rup_ax * rup_pt;
        %exit if inside polygon
        if all(isnan(rup_lim),'all') || all( inpolygon(rup_pt(1),rup_pt(2),rup_lim(:,1),rup_lim(:,2)) ); break; end
    end
else
    rup_pt = rup_pt_mean;
end

%sample azimuth uncertainty
if flag_samp(5)
    azmth_angle = normrnd(azmth_angle_mean,azmth_angle_unc);
else
    azmth_angle = azmth_angle_mean;
end

end
