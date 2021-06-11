% Tank Level Simulation, Control, and Estimator/Detector
% Jonas Wagner 2020-12-15

clear
close all

%% Initial Setup

% Nonlinear State Eq
f = @TankLevelDynamics_SimplifiedNonlinear;
h = nlsys.h_default(2,2); % n = 2, q = 2
x_0 = [ 0.5;
        0.25];

% System Definition
sys_plant = nlsys(f,h,x_0)

u_0 = [0.25;0.5];
sys_plant_1 = sys_plant.update(u_0);

%% Simulation ---------------------
N = 100;
t_step = 0.1;
t_max = N * t_step - t_step;
T = 0:t_step:t_max;
u_0= [1.0; 0.5];
U = [u_0(1) * ones(size(T)); u_0(2) * abs(sin(T))];

%Plant
SYS_plant = nlsim(sys_plant,U,T,x_0);
X_plant = SYS_plant.X;
T_plant = SYS_plant.T;
U_plant = SYS_plant.U;

%% ploting
%Option 1: Side by side (with 1 and 2 representing which states)
[fig,~] = SYS_plant.plot(1,1,1,-1,2,1);
[fig,~] = SYS_plant.plot(2,2,2,fig,2,2);

%Option 2: Comparrison (default)
% SYS_plant.plot;

%Option 3: No output (w/ zero)
% SYS_plant.plot(-1,-1,0);

% close all

%% PID control
k_p = 2;
k_i = 1.5;
k_d = 0;%0.001;

sys_cntrl = nlsys.pid(k_p,k_i,k_d);
sys_cntrl = nlsys.append(sys_cntrl,sys_cntrl); %U is two dims...
sys_plant_cntrl_open = nlsys.series(sys_cntrl, sys_plant); %Foward loop
sys_plant_cntrl_closed = nlfeedback(sys_plant_cntrl_open); %Unity feedback

U = [u_0(1)*ones(size(T));u_0(2)*ones(size(T))+sin(T)];

SYS_closed = nlsim(sys_plant_cntrl_closed,U,T);

SYS_closed.plot([3,4],[1,2],-1);