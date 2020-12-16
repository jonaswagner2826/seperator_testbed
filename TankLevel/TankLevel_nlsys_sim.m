% Tank Level Simulation, Control, and Estimator/Detector
% Jonas Wagner 2020-12-15

clear
close all

% Initial Setup

% Nonlinear State Eq
f = @TankLevelDynamics_SimplifiedNonlinear;
h = nlsys.h_default(2,2); % n = 2, q = 2
x_0 = [ 0.5;
        0.25];


sys_plant = nlsys(f,h,x_0)

u_0 = [0.25;0.5];
sys_plant_1 = sys_plant.update(u_0)

sys_cntrl = nlsys(pid(1,1));

sys_cntrl = nlsys.append(sys_cntrl,sys_cntrl)

% sys_plant_cntrl = nlsys.series(sys_plant,sys_cntrl)