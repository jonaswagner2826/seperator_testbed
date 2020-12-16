% Tank Level Estimator
% Jonas Wagner - 2020-12-10
clear
close all

% System Parameters --------------------------------------------
% Constants - Defined symbolic
syms H A_s A_r K_vv Gamma

% Constants - Estimates
h = 2;
a_s = pi * (0.25)^2;
a_r = pi * (0.75)^2;
k_vv = 2.16;
gamma = 0.098;

% State Varibles
syms x_s x_r
syms X_s_e X_r_e

X_s = x_s - X_s_e;
X_r = x_r - X_r_e;

x_s_e = 10;
x_r_e = 0.25;
x_e = [x_s_e, x_r_e];

x = [x_s; x_r];
X = [X_s; X_r];
X_e = [X_s_e; X_r_e];

% System Inputs
syms q_p u_v
syms Q_p_e U_v_e

Q_p = q_p - Q_p_e;
U_v = u_v - U_v_e;

q_p_e = 2;
u_v_e = 0.25;
u_e = [q_p_e, u_v_e];

u = [q_p; u_v];
U = [Q_p; U_v];
U_e = [Q_p_e; U_v_e];

% Symplifed Non-linear System Dynamics -----------------------------
% Simplified State Equations
% f_1 = (1/A_s) * (Q_p - U_v * K_vv * sqrt(Gamma * (X_s + H - X_r)));
% f_2 = (1/A_r) * (-Q_p + U_v * K_vv * sqrt(Gamma * (X_s + H - X_r)));
% 
% f = [f_1; f_2]


f = TankLevelDynamics_SimplifiedNonlinear(X,U,H,A_s,A_r,K_vv,Gamma); %Tank Level Dyanmics


% Output Equations
g_1 = X_s;
g_2 = X_r;

g = [g_1; g_2];

% Linearization --------------------------------------
% Equalibrium Points
f_e = subs(f, [X_s, X_r, Q_p, U_v], [X_s_e, X_r_e, Q_p_e, U_v_e]);
g_e = subs(g, [X_s, X_r, Q_p, U_v], [X_s_e, X_r_e, Q_p_e, U_v_e]);

% System Matrices
A = subs(jacobian(f,x),[X,U],[X_e,U_e]);
B = subs(jacobian(f,u),[X,U],[X_e,U_e]);
C = subs(jacobian(g,x),[X,U],[X_e,U_e]);
D = subs(jacobian(g,u),[X,U],[X_e,U_e]);

% Linearized Equations
x_dot = A * x + B * u;
y = C * x + D * u;

X_dot = A * x + B * u + f_e;
Y = C * x + D * u;





% Discretization ------------------------------------------------
syms T
t_step = 1;

% System Matrices
F = expm(A * T);
syms tau
G = F * int(expm(-A*tau), tau, 0, T) * B;

% Linear DT System -----------------------------------------
F_num = double(subs(F,[H A_s A_r K_vv Gamma T X_s_e X_r_e Q_p_e U_v_e],...
                      [h a_s a_r k_vv gamma t_step x_s_e x_r_e q_p_e u_v_e]));
G_num = double(subs(G,[H A_s A_r K_vv Gamma T X_s_e X_r_e Q_p_e U_v_e],...
                      [h a_s a_r k_vv gamma t_step x_s_e x_r_e q_p_e u_v_e]));
C_num = double(C);
D_num = double(D);

sys = ss(F_num, G_num, C_num, D_num, t_step);

% Full-Order Observer Design -----------------------------------
p = [0.5 0.5];

L = place(F_num',C_num',p).';

A_obsv = F_num - L * C_num;
B_obsv = [G_num - L * D_num, L];
C_obsv = C_num;
D_obsv = [D_num, zeros(2)];

sys_obsv = ss(A_obsv,B_obsv,C_obsv,D_obsv,t_step);


% Simulation ----------------------------------
T1 = 0;
T2 = 50;
T = t_step;

t = T1:T:T2;
N = size(t,2);


g = [u_e(1) * sin(2*t/N);
     u_e(2) * ones(1,N)];
 
noisePower = 20;
x = lsim(sys, g, t);
% x = nlsim(@SimplifiedNonlinear,g,t,0,0.1);
y = awgn(x,noisePower,'measured');
x_est = lsim(sys_obsv, [g',y], t');


x_measure_error = y - x;
x_est_error = x_est-x;

figure()
plot([x_est, y])

figure()
plot([x_est_error(:,1),x_measure_error(:,1)])
legend('est','measure')



