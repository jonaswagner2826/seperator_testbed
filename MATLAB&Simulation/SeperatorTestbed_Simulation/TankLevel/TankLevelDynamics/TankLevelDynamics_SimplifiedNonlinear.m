function dx = TankLevelDynamics_SimplifiedNonlinear(x,u,...
        h,a_s,a_r,k_vv,gamma,x_max,u_max)
%TankLevelDynamics_SimplifiedNonlinear
%   Basically the simplified non-linear equations for the seperator tank
%   level.
%   u = [q_p; u_v]; x = [x_s; x_r];

arguments
    x = 0;
    u = 0;
    h = 1;
    a_s = pi * (0.25)^2;
    a_r = pi * (0.75)^2;
    k_vv = 2.16;
    gamma = 0.098;
    x_max = [2; 1];
    u_max = [0.5; 1];
end

% System Size
n = 2;
p = 2;

%nlsys requirment
if nargin == 0
    dx = [n; p]; % n =2, p = 2
    return;
end

if x == 0
    x = zeros(n,1);
end

if u == 0
    u = zeros(p,1);
end

% % State and Input Saturation
% if ~isa(x,'sym')
%     for i = 1:n
%         if x(i) > x_max(i)
%             x(i) = x_max(i);
%             warning('x_%i at max',i)
%         elseif x(i) < 0
%             x(i) = 0;
%             warning('x_%i below 0',i)
%         end
%     end
% end
% if ~isa(u,'sym')
%     for i = 1:n
%         if u(i) > u_max(i)
%             u(i) = u_max(i);
%             warning('u_%i at max',i)
%         elseif u(i) < 0
%             u(i) = 0;
%             warning('u_%i below 0',i)            
%         end
%     end
% end

% Simplified nonlinear equations
dx = zeros(2,1,class(u)); %same size/shape of u
dx(1) = (1/a_s) * (u(1) - u(2) * k_vv * sqrt(gamma * (x(1) + h - x(2))));
dx(2) = (1/a_r) * (-u(1) + u(2) * k_vv * sqrt(gamma * (x(1) + h - x(2))));

end

