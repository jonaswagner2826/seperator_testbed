function dx = TankLevelDynamics_SimplifiedNonlinear(x,u,h,a_s,a_r,k_vv,gamma)
%TankLevelDynamics_SimplifiedNonlinear
%   Basically the simplified non-linear equations for the seperator tank
%   level.
%   u = [q_p; u_v]; x = [x_s; x_r];

arguments
    x
    u
    h = 1;
    a_s = pi * (0.25)^2;
    a_r = pi * (0.75)^2;
    k_vv = 2.16;
    gamma = 0.098;
end

if x == 0
    x = zeros(2,1);
end

% Simplified nonlinear equations
dx = zeros(2,1,class(u)); %same size/shape of u
dx(1) = (1/a_s) * (u(1) - u(2) * k_vv * sqrt(gamma * (x(1) + h - x(2))));
dx(2) = (1/a_r) * (-u(1) + u(2) * k_vv * sqrt(gamma * (x(1) + h - x(2))));

end

