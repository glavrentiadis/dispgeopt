function [rup_azmth_mean,rup_azmth_std,rup_loc_std,rup_ax] = input_rupture(flag_rup_unc)
% Dialog box of azimuth angle and uncertainty
%
% Input arguments:
%   flag_azimuth_unc (bool): flag for rupture uncertainty
%                            (azimuth and location)
%                               0: azimuth uncertainty
%                               1: azimuth and radial location uncertinaty
%                               2: azimuth and radial location uncertinaty
% 
% Output arguments:
%   rup_azmth_mean (double):   rupture azimuth (deg)
%   rup_azmth_std  (double):   rupture azimuth (deg)
%   rup_loc_std    (double):   rupture location uncertainty (m)
%   rup_ax         (mat[2,2]): principal rupture axis (along strike, perpendicular to strike) 

%default input
if nargin < 1; flag_rup_unc=1; end

%window name
dlgtitle = 'Azimuth Input';

%azimuth angle w\ uncertainty
switch flag_rup_unc
    case 0
        prompt   = {'Enter rupture azimuth angle (deg):'};
        definput = {'45'};
        dims     = [1 45];
        inpt     = inputdlg(prompt, dlgtitle, dims, definput);
        rup_azmth_mean = str2double(inpt{1});
        rup_azmth_std  = nan;
        rup_azmth_std  = nan;
        rup_ax_ratio   = 1;
    case 1
        prompt   = {'Enter rupture azimuth angle (deg):';
                    'Enter rupture azimuth uncertainty (deg):';
                    'Enter rupture location uncertainty (m):'};
        definput = {'45.0','5.0','1.0'};
        dims     = [1, 45; 1, 45; 1, 45];
        inpt     = inputdlg(prompt, dlgtitle, dims, definput);
        rup_azmth_mean = str2double(inpt{1});
        rup_azmth_std  = str2double(inpt{2});
        rup_loc_std    = str2double(inpt{3});
        rup_ax_ratio   = 1;
    case 2
        prompt   = {'Enter rupture azimuth angle (deg):';
                    'Enter rupture azimuth uncertainty (deg):';
                    'Enter rupture location uncertainty (m):'
                    'Enter along/perpendicular to strike ratio'};
        definput = {'45.0','5.0','1.0','1.0'};
        dims     = [1, 45; 1, 45; 1, 45; 1, 45];
        inpt     = inputdlg(prompt, dlgtitle, dims, definput);
        rup_azmth_mean = str2double(inpt{1});
        rup_azmth_std  = str2double(inpt{2});
        rup_loc_std    = str2double(inpt{3});
        rup_ax_ratio   = str2double(inpt{4});
end

%principal rupture axis
rup_ax      = axis_rot(-deg2rad(rup_azmth_mean));
rup_ax(:,1) = rup_ax_ratio * rup_ax(:,1);
rup_ax      =  sqrt(2)/norm(rup_ax) * rup_ax;

end