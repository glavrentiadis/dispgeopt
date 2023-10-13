function [rup_azmth_mean,rup_azmth_std,rup_loc_std] = input_rupture(flag_rup_unc)
% Dialog box of azimuth angle and uncertainty
%
% Input arguments:
%   flag_azimuth_unc (bool): flag to ask for rupture uncertainty,
%                            location and azimuth
% 
% Output arguments:
%   rup_azmth_mean (double): rupture azimuth (deg)
%   rup_azmth_std (double):  rupture azimuth (deg
%   rup_loc_std (double):   location uncertainty (m)

%default input
if nargin < 1; flag_rup_unc=false; end

%window name
dlgtitle = 'Azimuth Input';

%azimuth angle w\ uncertainty
if ~flag_rup_unc
    prompt   = {'Enter rupture azimuth angle (deg):'};
    definput = {'45'};
    dims     = [1 45];
    inpt     = inputdlg(prompt, dlgtitle, dims, definput);
    rup_azmth_mean = str2double(inpt{1});
    rup_azmth_std  = nan;
    rup_azmth_std  = nan;
else
    prompt   = {'Enter rupture azimuth angle (deg):';
                'Enter rupture azimuth uncertainty (deg):';
                'Enter rupture location uncertainty (m):'};
    definput = {'45.0','5.0','1.0'};
    dims     = [1, 45; 1, 45; 1, 45];
    inpt     = inputdlg(prompt, dlgtitle, dims, definput);
    rup_azmth_mean = str2double(inpt{1});
    rup_azmth_std  = str2double(inpt{2});
    rup_loc_std    = str2double(inpt{3});
end

end