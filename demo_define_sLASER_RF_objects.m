% demo_define_sLASER_RF_objects.m
% Written by Namgyun Lee
% Email: namgyunl@usc.edu, ggang56@gmail.com (preferred)
% Started: 08/22/2019, Last modified: 08/22/2019

close all; clear all; clc;

%% Read RFVAR shapes
demo_read_RFVAR_archived_shapes;

%% Define RF structure
RF = struct('function', [], ... % function of the object. Used to calculate attributes like BW and ref.
                            ... % Possible values: RF_FUNCTION_EXCITATION, RF_FUNCTION_ECHO, RF_FUNCTION_INVERSION
            'freq'    , [], ... % offset frequency with respect to the current F0 [Hz]
            'ref'     , [], ... % reference point in the object, with respect to its begin [msec]
            'time'    , [], ... % time of reference point of object within the sequence [msec]
            'dur'     , [], ... % duration of the object [msec]
                            ... % Note: dur is automatically rounded to multiples of 4 usec, the RF-dwell-time
            'phase'   , [], ... % offset phase with respect to resonance frequency F0 at the reference point [degrees]
            'AM_scale', [], ... % extra amplitude scale factor of the RF pulse
            'FM_scale', [], ... % scale factor for the FM pulse shape [Hz]. All elements in the FM pulse shape 
                            ... % will be multiplied by this factor. The FM pulse shape itself is scaled between -1.0 and 1.0, 
                            ... % with at least one of these values actually occurring.
            'angle'   , [], ... % pulse angle [degrees]
            'shape'   , [], ... % reference to an RFVAR object that defines the AM and/or FM waveforms
            'B1'      , []);    % maximum (circular) magnetic field strength of the pulse [uT]
            
%% Initialize RF objects
ex = RF;

%% Define RF objects

% ex
ex.function = [];
ex.freq     = [];
ex.ref      = [];
ex.time     = [];
ex.dur      = [];
ex.phase    = [];
ex.AM_scale = [];
ex.FM_scale = [];
ex.angle    = [];
ex.shape    = [];
ex.B1       = [];

%% Calculate AM and FM waveforms
UGN1_SPY_pulse_set = 'MPUSPY_PULSE_SET_NORMAL';

switch UGN1_SPY_pulse_set
    case 'MPUSPY_PULSE_SET_NORMAL'
        am_shape = am_spredrex;
        fm_shape = zeros(length(am_shape),1, 'double');
    case 'MPUSPY_PULSE_SET_SHARP'
        am_shape = am_fremex05;
        fm_shape = fm_fremex05;
    case 'MPUSPY_PULSE_SET_CLASSIC_LONG'
    case 'MPUSPY_PULSE_SET_CLASSIC_SHORT'
    case 'MPUSPY_PULSE_SET_BLOCK'
    case 'MPUSPY_PULSE_SET_ADIABATIC'
end        

MGG_GAMMA_1H = 42577.46778; % [Hz/mT]

angle = 90; % [degrees]
B1    = 15; % [uT]

% SPREDREX
am_c_teff     = 0.0611;
am_c_trms     = 0.0646;
am_c_tabs     = 0.1386;
am_c_sym      = 0.8500;
am_c_ref_ex   = 0;
am_c_ref_echo = 0;
fm_c_fm_scale = [];

% angle = gammma * B1 * Teff
% angle = gammma * B1 * am_c_teff * dur
% [degrees] = [Hz/mT] * [uT] * [msec]
% [degrees] = [Hz/mT] * [uT] * [mT/1e3uT] * [msec] * [sec/1e3mec] * [360degrees/cycle]
dur = angle / (MGG_GAMMA_1H * (B1/1e3) * am_c_teff / 1e3 * 360); % [msec]
ref = dur * (am_c_sym - am_c_ref_ex * (angle / 90)^2);

nr_samples = length(am_shape); % (= am_samples and fm_samples)

% The contents of the float array <array-name> should be scaled between -1.0 and
% 1.0, so that at least one of these values occurs.
am = am_shape / max(abs(am_shape));
%fm = fm_shape / max(abs(fm_shape));

% Scale amplitude
am = B1 * am;
%fm = FM_scale * fm;

dt = dur / nr_samples; % [msec]
time_axis = (0:nr_samples-1).' * dt; % [msec]

figure('Color', 'w'); hold on;
plot(time_axis, am);
plot([ref ref], [min(am) max(am)]);
xlabel('Time (msec)');
ylabel('Amplitude (\muT)');


