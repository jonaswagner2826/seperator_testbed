classdef nlsys
    %NLSYS This class describes non-linear dynamical systems for simulation
    %   Class developed to do similar things as the MATLAB control systems
    %   toolbox but for nonlinear state and output funactions  
    properties
        % System Parameters
        % f - State_eq... linear or nonlinear function describing the
        % update of the state itself. Should be @(x,u)
        f
        % h - Output_equation... should be @(x,u)
        h
        % x - Current state of the system, should be of the correct size
        % to satisfy f(x,u)...
        x
        % Ts is the DT step size (-1 = CT) 
        Ts
        % t is the current time
        t
        % u is the current input (no input = 0)
        u
        % y is the current output
        y
        
        % System size
        % n - number of states
        n (1,1) int32
        % p - number of inputs
        p (1,1) int32
        % q - number of outputs
        q (1,1) int32
    end
    
    %% Constructor
    methods
        % System Constructor
        function sys = nlsys(f, h, x, Ts, t, u)
            % NLSYS this is the constructor for nlsys objects
            arguments
                % f is state eq (or nlsys or lti object)
                f       = 'empty';
                % h is output eq (optional) default = output just x
                h       = 'empty';
                % x is the current state (optional) default = relaxed
                x (:,1) = 0;
                % Ts is the DT step size (optional) default = CT (Ts = -1)
                Ts      = -1;
                % t is the current time (optional) default t = 0
                t       = 0;
                % u is the current input (optional default u = 0
                u       = 0;
            end
            
            % Empty Construction
            if nargin == 0 
                sys.Ts = -1; % default to CT
                sys.t = 0; % default to t = 0
                sys.u = 0; % default to u = 0
                return
            end
            % Conversion setups
            if isa(f,'nlsys')% direct nlsys conversion
                sys_old = f;
                f = sys_old.f;
                if nargin < 2
                    h = sys_old.h;
                end
                if nargin < 3 % not sure why this would ever be used...
                    x = sys_old.x;
                end
                if nargin < 4
                    Ts = sys_old.Ts;
                end
            end

            if isa(f,'lti')% conversions from lti sys
                [a,b,c,d] = ssdata(f);
                f = nlsys.f_lti_default(a,b);%@(x,u) a*x + b*u;
                if nargin < 2
                    h = nlsys.h_lti_default(c,d);%@(x,u) c*x + d*u;
                    q = size(c,1);
                end
            end

            if isa(f,'double')
                k = f;
                f = nlsys.f_lti_default(0,0);
                h = nlsys.h_lti_default(0,k);
                n = 1;
                p = size(k,1);
                q = size(k,1);
            end

            % State Equation
            sys.f = f;

            % System Size
            try
                temp = f();
            catch
                warning('size of f errors')
                n = -1;
                p = -1;
            end
            if exist('n','var') == 0
                n = temp(1);
                p = temp(2);
            end
            sys.n = n; % Number of States
            sys.p = p; % Number of Inputs

            % Output Equation
            if ~ isa(h,'function_handle')
                if isa(f,'nlsys')
                    h = f.h;
                else
                    h = nlsys.h_default(n,p);
                end
            end
            sys.h = h;

            % Output Size
            if nargin >= 2
                temp = h(); %temp(1) = n, temp(2) = p, temp(3) = q
                if temp(1) == -1
                    temp(1) = sys.n;
                end
                if temp(2) == -1
                    temp(2) = sys.p;
                end
                if temp(1) ~= sys.n || temp(2) ~= sys.p
                    if sys.f(x,zeros(sys.p,1)) ~= 0
                        warning('h() may not be compatible with f()')
                        sys.n = temp(1);
                        sys.p = temp(2);
                    end
                end
                q = temp(3);
            elseif exist('q','var') == 0
                q = sys.n;
            end
            sys.q = q;% Number of outputs

            % System State
            if x == 0 %no input given for x
                x = zeros(sys.n,1);
            end
            if size(x,1) ~= sys.n
%                 error('x incorrect size')
            end
            sys.x = x;

            % DT Step Size (default = -1 = CT)
            sys.Ts = Ts;

            % Current time (default = 0)
            sys.t = t;
            
            % Current input (default = 0)
            if u == 0
                u = zeros(sys.p,1);
            end
            sys.u = u;

            % Validization
            try
                x_test = sys.f(x,zeros(sys.p,1));
            catch
                error('f(x,0) does not work')
            end
            if size(x_test,1) ~= sys.n
                if x_test ~= 0
%                     error('f(x,0) incorrect size')
                end
            end
%             try
%                 y_test = sys.h(x,0);
%             catch
% %                 error('h(x,0) does not work')
%             end
%             if size(y_test,1) ~= sys.q
%                 error('h(x,0) incorrect size')
%             end
            
            % Additional dependent properties
            sys.y = sys.output;
        end
    end
    
    %% Overload Methods
    methods
        function disp(sys)
            % DISP overload of display of class
            fprintf('f(x,u) = \n \n')
            try
                pretty(sys.f(sym('x',[sys.n,1]),sym('u',[sys.p,1])))
            catch
                warning('issue with pretty of f(x,u).\n');
            end
            fprintf('h(x,u) = \n \n')
            try
                pretty(sys.h(sym('x',[sys.n,1]),sym('u',[sys.p,1])))
            catch
                warning('issue with pretty of h(x,u).\n');
            end
            fprintf('x = \n')
            disp(sys.x)
            fprintf('n = %i, p = %i, and q = %i.\n', sys.n, sys.p, sys.q);
            if sys.Ts == -1
                fprintf('Continous-time nonlinear state-space model.\n')
            else
                fprintf('Discrete-time nonlinear state-space model with Ts = %3f.\n',...
                    sys.Ts)
            end
        end
        
        function sys = plus(sys1,sys2)
            % PLUS overloaded plus = parrellel addition of systems
            try
                if ~isa(sys1,'nlsys')
                    try
                        sys1 = nlsys(sys1);
                    catch
                        error('sys1 has error')
                    end
                end
                if ~isa(sys2,'nlsys')
                    try
                        sys2 = nlsys(sys2);
                    catch
                        error('sys2 has error')
                    end
                end
                sys = nlsys.parrellel(sys1,sys2);
%                 warning('Non parrellel addition not done yet')
            catch ME
                rethrow(ME)
%                 error('Non parrellel addition not done yet') 
            end
        end
        
        function sys = mtimes(sys1,sys2)
            % MTIMES overloads * with series
            sys = times(sys1,sys2);
        end
        
        function sys = times(sys1,sys2)
            % Times overloads .* with series
            try
                if ~isa(sys1,'nlsys')
                    try
                        sys1 = nlsys(sys1);
                    catch
                        error('sys1 has error')
                    end
                end
                if ~isa(sys2,'nlsys')
                    try
                        sys2 = nlsys(sys2);
                    catch
                        error('sys2 has error')
                    end
                end
                sys = nlsys.parrellel(sys1,sys2);
            catch ME
                rethrow(ME)
            end
        end
        
    end
    
    %% System Operations
    methods
        % Standard System Operations
        function dx = dx(sys,u,x)
            % DX - returns state update eq (dx)
            arguments
                % sys is the nonlin sys
                sys
                % u is the input
                u
                % x is the current state
                x = sys.x
            end
            dx = sys.f(x,u);
        end
        
        function y = output(sys,u,x)
            arguments
                % sys is the nonlin sys
                sys
                % u is the input
                u = sys.u
                % x is the current state
                x = sys.x
            end
            y = sys.h(x,u);
        end
        
        function x = CT_Update(sys,u,t,x)
            arguments
                % sys is the nonlin sys
                sys nlsys
                % u is the input
                u
                % t is the time step
                t
                % x is the current state
                x = sys.x
            end            
            x = x + sys.dx(u,x) * t; %replace with ode45...
        end
        
        function x = DT_Update(sys,u,n,x)
            %DT_Update... does n foward steps
            arguments
                % sys is the nonlin sys
                sys nlsys
                % u is the input
                u
                % n is the number of time steps
                n (1,1) int32
                % x is the current state
                x = sys.x
            end
            x = sys.f(x,u);
            if n > 1
                for i = 2:n
                    x = sys.f(x,u);
                end
            end
        end
        
        function sys = update(sys,u,t,x)
            % UPDATE - return an updated system based on u and t...
            % and x (optional)
            arguments
                % sys is the nonlin sys
                sys nlsys
                % u is the input (optional) default = natural response
                u (:,1) = sys.u
                % t is the time step to be updated by
                t = 1;
                % x is the current state (optional) default = sys.x
                x (:,1) = sys.x
            end
            % Acounting for symbolic explicitly
            if isa(t,'sym')
                if sys.Ts == -1
                    x = CT_Update(sys,u,t,x);
                    sys = nlsys(sys.f,sys.h,x);
                    return;
                else
                    error('DT not possible with symbolic t')
                end
            end
            
            % Input Validation
%             if size(u,2) ~= sys.p
%                 error('u incorrect size')
%             end
            if size(x,1) ~= sys.n
                error('x incorrect size')
            end
            if t <=0
                error('t must be greater then zero')
            end
            
            % Update Equation
            t_new = sys.t + t;            
            if sys.Ts == -1 % Standard CT update
                x = CT_Update(sys,u,t,x);
            else % DT update
                old_n = floor(sys.t / sys.Ts);
                new_n = floor(t_new / sys.Ts);
                n_steps = new_n - old_n;
                x = DT_Update(sys,u,n_steps,x);
            end

            % New sys definition
            sys = nlsys(sys.f,sys.h,x,sys.Ts,t_new,u);
        end
    end
    
    
%     %% Simulation
%     methods (Static)
%         % nlsim... important iterative method version...
% 
%     end
    
    %% Simple Composite Systems
    methods (Static)
        % Interconnected Systems
        function sys = series(sys1,sys2)
            % SERIES combines two nlsys objects in series
            
            % System Parameters
            [f1, h1, x1, n1, p1, q1, Ts1, t1] = nlsys.data_export(sys1);
            [f2, h2, x2, n2, p2, q2, Ts2, t2] = nlsys.data_export(sys2);
            
            % Compatibility 
            if q1 ~= p2
                error('sys1 and sys2 incompatible');
            end
            if Ts1 ~= Ts2
                error('sys1 and sys2 Ts different');
            end
            if t1 ~= t2
                warning('t1 ~= t2, set to 0')
                t1 = 0;
            end

            % Sys definition
            new_x = [x1;x2];
            n = n1 + n2;
            p = p1;
            q = q2;
            Ts = Ts1;
            t = t1;

            sys = nlsys.data_input(@new_f, @new_h, new_x, n, p, q, Ts, t);
            
            function f = new_f(x,u)
                % NEW_F function defining new series state function
                if nargin == 0
                    f = [n,p];
                else
                    x1 = x(1:n1);
                    x2 = x((n1+1):(n1+n2));
                    dx1 = f1(x1,u);
                    y1 = h1(x1,u);
                    dx2 = f2(x2,y1);
                    f = [dx1; dx2];
                end
            end
            
            function h = new_h(x,u)
                % NEW_H function defining new series output function
                if nargin == 0
                    h = [n,p,q];
                else
                    x1 = x(1:n1);
                    x2 = x((n1+1):(n1+n2));
                    y1 = h1(x1,u);
                    y2 = h2(x2,y1);
                    h = y2;
                end
            end
                        
        end
        
        function sys = parrellel(sys1,sys2)
            % PARRELLEL combines two nlsys objects in parrellel... assumes
            % that they have the same input and an un scaled sum outputs
            
            % System Parameters
            [f1, h1, x1, n1, p1, q1, Ts1, t1] = nlsys.data_export(sys1);
            [f2, h2, x2, n2, p2, q2, Ts2, t2] = nlsys.data_export(sys2);   
            
            % Compatibility 
            if p1 ~= p2 || q1 ~= q2 %sys1.p ~= sys2.p || sys1.q ~= sys2.q
                error('sys1 and sys2 incompatible');
            end
            if Ts1 ~= Ts2 %sys1.Ts ~= sys2.Ts
                error('sys1 and sys2 Ts different');
            end
            if t1 ~= t2
                warning('t1 ~= t2, set to 0')
                t1 = 0;
            end
            
            % Sys definition
            new_x = [x1;x2];
            n = n1 + n2;
            p = p1;
            q = q2;
            Ts = Ts1;
            t = t1;

            sys = nlsys.data_input(@new_f, @new_h, new_x, n, p, q, Ts, t);            

            function f = new_f(x,u)
                % NEW_F function defining new parrellel state function
                if nargin == 0
                    f = [n,p];
                else
                    x1 = x(1:n1);
                    x2 = x((n1+1):(n1+n2));
                    dx1 = f1(x1,u);
                    dx2 = f2(x2,u);
                    f = [dx1; dx2];
                end
            end
            
            function h = new_h(x,u)
                % NEW_H function defining new series output function
                if nargin == 0
                    h = [n,p,q];
                else
                    x1 = x(1:n1);
                    x2 = x((n1+1):(n1+n2));
                    y1 = h1(x1,u);
                    y2 = h2(x2,u);
                    h = y1+y2;
                end
            end
        end

        function sys = append(sys1,sys2)
            % APPEND combines two nlsys objects into a single system
            
            % System Parameters
            [f1, h1, x1, n1, p1, q1, Ts1, t1] = nlsys.data_export(sys1);
            [f2, h2, x2, n2, p2, q2, Ts2, t2] = nlsys.data_export(sys2);   
            
            % Compatibility 
            if Ts1 ~= Ts2 %sys1.Ts ~= sys2.Ts
                error('sys1 and sys2 Ts different');
            end
            if t1 ~= t2
                warning('t1 ~= t2, set to 0')
                t1 = 0;
            end
            
            % Sys definition
            new_x = [x1;x2];
            n = n1 + n2;
            p = p1 + p2;
            q = q1 + q2;
            Ts = Ts1;
            t = t1;

            sys = nlsys.data_input(@new_f, @new_h, new_x, n, p, q, Ts, t);

            function f = new_f(x,u)
                % NEW_F function defining new parrellel state function
                if nargin == 0
                    f = [n,p];
                else
                    x1 = x(1:n1);
                    x2 = x((n1+1):(n1+n2));
                    u1 = u(1:p1);
                    u2 = u((p1+1):(p1+p2));
                    dx1 = f1(x1,u1);
                    dx2 = f2(x2,u2);
                    f = [dx1; dx2];
                end
            end
            
            function h = new_h(x,u)
                % NEW_H function defining new series output function
                if nargin == 0
                    h = [n,p,q];
                else
                    x1 = x(1:n1);
                    x2 = x((n1+1):(n1+n2));
                    u1 = u(1:p1);
                    u2 = u((p1+1):(p1+p2));
                    y1 = h1(x1,u1);
                    y2 = h2(x2,u2);
                    h = [y1; y2];
                end
            end
        end        
        
        
    end

    %% Direct to controllers
    methods (Static)
        function sys = pid(k_p,k_i,k_d)
            [A,B,C,D] = dssdata(pid(k_p,k_i,k_d));
            f = nlsys.f_lti_default(A,B);
            h = nlsys.h_lti_default(C,D);
            sys = nlsys(f,h);
        end
    end
    
    %% Input/ Export
    methods (Static)
        
        % Export to lti classes
        
        function [A,B,C,D] = linearize(sys, x_0, u_0)
            % LINEARIZE linearizes the system around x_0 and u_0
            arguments
                % sys is the nlsys object
                sys
                % x_0 is the equilibrium point... default is sys.x
                x_0 = sys.x;
                % u_0  is the equilibrium input... default is sys.u
                u_0 = sys.u;
            end
%             [f, h, x, n, p, ~, ~] = nlsys.data_export(sys);
            
%             if nargin < 2
%                 x_0 = sys.x;
%             end
%             if nargin < 3
%                 u_0 = sys.u;
%             end
            
            x_sym = sym('x',[sys.n,1]);
            u_sym = sym('u',[sys.p,1]);
            
            A = jacobian(sys.f(x_sym,u_sym),x_sym);
            B = jacobian(sys.f(x_sym,u_sym),u_sym);
            C = jacobian(sys.h(x_sym,u_sym),x_sym);
            D = jacobian(sys.h(x_sym,u_sym),u_sym);
            
            try
                A = double(subs(subs(A,x_sym,x_0),u_sym,u_0));
                B = double(subs(subs(B,x_sym,x_0),u_sym,u_0));
                C = double(subs(subs(C,x_sym,x_0),u_sym,u_0));
                D = double(subs(subs(D,x_sym,x_0),u_sym,u_0));
            catch
                warning('issue with substitution...')
            end
        
        end
        
        function sys_new = ss(sys, x_0, u_0)
            % SS exports nlsys into an ss object
            arguments
                % sys is the nlsys object
                sys
                % x_0 is the equilibrium point... default is sys.x
                x_0 = sys.x;
                % u_0  is the equilibrium input... default is sys.u
                u_0 = sys.u;
            end
            if sys.Ts ~= -1
                error('function no work in DT')
            end
            [A,B,C,D] = nlsys.linearize(sys, x_0, u_0);
            sys_new = ss(A,B,C,D);
        end

        function sys_new = tf(sys, x_0, u_0)
            % TF exports nlsys into an tf object
            arguments
                % sys is the nlsys object
                sys
                % x_0 is the equilibrium point... default is sys.x
                x_0 = -1;
                % u_0  is the equilibrium input... default is 0
                u_0 = -1;
            end
            if sys.Ts ~= -1
                error('function no work in DT')
            end

            [A,B,C,D] = nlsys.linearize(sys, x_0, u_0);
            sys_new = tf(ss(A,B,C,D));
        end
        
        function sys_new = zpk(sys, x_0, u_0)
            % ZPK exports nlsys into an zpk object
            arguments
                % sys is the nlsys object
                sys
                % x_0 is the equilibrium point... default is sys.x
                x_0 = -1;
                % u_0  is the equilibrium input... default is 0
                u_0 = -1;
            end
            if sys.Ts ~= -1
                error('function no work in DT')
            end

            [A,B,C,D] = nlsys.linearize(sys, x_0, u_0);
            sys_new = zpk(ss(A,B,C,D));
        end
    end
    
    methods (Static)
        % Data Inport/Export
        function [f, h, x, n, p, q, Ts, t] = data_export(sys)
            % DATA_EXPORT output all the system properties
            f = sys.f;
            h = sys.h;
            x = sys.x;
            n = sys.n;
            p = sys.p;
            q = sys.q;
            Ts = sys.Ts;
            t = sys.t;
        end
        
        function sys = data_input(f, h, x, n, p, q, Ts, t)
            % DATA_INPUT creates a new nlsys and inputs specific parameters
            sys = nlsys();
            sys.f = f;
            sys.h = h;
            sys.x = x;
            sys.n = n;
            sys.p = p;
            sys.q = q;
            sys.Ts = Ts;
            sys.t = t;
        end
    end
    
    %% Function Manipulation
    methods (Static)
        
        % Anonomous Function Manipulation
        function f = func_sum(varargin)
            % FUNC_SUM sums two varible functions together:
            % Ex: f1(x,u) + f2(x,u) + f3(x,u)
            f = @(x,u) varargin{1}(x,u);
            for i = 2:nargin
                f = @(x,u) f(x,u) + varargin{i}(x,u);
            end
            f = @(x,u) f(x,u);
        end
        
        function func = func_conv(varargin)
            % FUNC_CONV convolves multiple single varible functions
            f = @(x) varargin{1}(x);
            for i = 2:nargin
                f = @(x) varargin{i}(f(x));
            end
            func = @g;
            function y = g(x)
                y = f(x);
            end
        end
        
        % -------- Not done ----------------------
        function f = func_append(varargin)
            % FUNC_APPEND appends two varible functions virtically:
            % Ex: [f1(x,u); f2(x,u); f3(x,u)]
            % unfortunently this does not acount for x and u of different
            % sizes... only single input x and u with different outputs...
            f = @(x,u) varargin{1}(x,u);
            for i = 2:nargin
                f = @(x,u) [f(x,u); varargin{i}(x,u)];
            end
            f = @(x,u) f(x,u);
        end
        % -----------------------------------------
        
    end
    
    %% Default Functions
    methods (Static)
        function h = h_default(varargin)
            h = @h_default_func;
            local_n = varargin{1};
            local_p = varargin{2};
            function y = h_default_func(varargin)
                % H_DEFAULT default h function
                if nargin == 0
                    y = [local_n; local_p; local_n];
                else
                    local_x = varargin{1};
                    local_u = varargin{2}; % Unused
                    y = local_x;
                end
            end
        end

        function f = f_lti_default(A,B)
            f = @lti_state_func;

            % Array sizes
            local_n = size(A,1); % Number of states
            local_p = size(B,2); % Number of inputs
            if A == 0
                local_n = size(B,1);
            end

            function y = lti_state_func(varargin)
                % LTI_STATE_FUNC function developed using state matrices
                if nargin == 0
                    y = [local_n; local_p];
                else
                    local_x = varargin{1};
                    local_u = varargin{2};
                    if size(local_x) ~= [local_n,1]
                        error('x wrong size')
                    end
                    if size(local_u) ~= [local_p,1]
                        error('u wrong size')
                    end
                    y = A * local_x + B * local_u;
                end
            end
        end

        function h = h_lti_default(C,D)
            h = @lti_output_func;

            % Array sizes
            local_n = size(C,2); % Number of states
            local_p = size(D,2); % Number of inputs
            local_q = size(C,1); % Number of ouptuts
            if C == 0
                local_q = size(D,1);
            end

            function y = lti_output_func(varargin)
                % LTI_STATE_FUNC function developed using state matrices
                if nargin == 0
                    y = [local_n; local_p; local_q];
                else
                    local_x = varargin{1};
                    local_u = varargin{2};
                    if size(local_x) ~= [local_n,1]
                        error('x wrong size')
                    end
                    if size(local_u) ~= [local_p,1]
                        error('u wrong size')
                    end
                    y = C * local_x + D * local_u;
                end
            end
        end
    end
    
    
end





