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

% System Definition
sys_plant = nlsys(f,h,x_0)

u_0 = [0.25;0.5];
sys_plant_1 = sys_plant.update(u_0);

% Simulation ---------------------
N = 100;
t_step = 0.1;
t_max = N * t_step - t_step;
T = reshape(0:t_step:t_max,N,1);
u_0= [0.5, 0.25]; %U'
U = u_0.* abs(sin(T)); %U'

%Plant
SYS_plant = nlsim(sys_plant,U,T,x_0);
X_plant = SYS_plant.X;
T_plant = SYS_plant.T;
U_plant = SYS_plant.U;

% ploting
%Option 1:
[fig,~] = SYS_plant.plot(1,1,1,-1,2,1);
[fig,~] = SYS_plant.plot(2,2,2,fig,2,2);

%Option 2:
SYS_plant.plot;

close all
%PID control
k_p = 1;
k_i = 0.1;
k_d = 0.001;

sys_cntrl = nlsys.pid(k_p,k_i,k_d);
sys_cntrl = nlsys.append(sys_cntrl,sys_cntrl); %U is two dims...
sys_plant_cntrl_open = nlsys.series(sys_plant,sys_cntrl); %Foward loop
sys_plant_cntrl_closed = nlfeedback(sys_plant_cntrl_open); %Unity feedback

SYS_closed = nlsim(sys_plant_cntrl_closed,U,T)


