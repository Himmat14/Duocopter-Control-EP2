
clc; clear; close all;

%%
%% 1) GEOMETRY & LOADS
% a0       = 6e-2;        % width @ root [m]
% a_tip    = 2e-2;        % width @ tip  [m]
% t        = 8e-3;        % constant thickness [m]
L        = 0.30;        % arm length [m]
% t_f      = 4e-3;        % I Beam top thickness [m]
% t_w      = 0e-3;        % I Beam midsection thickness [m]


P_end    = 13;          % thrust load at tip [N] (in +x)
T_end    = 0.305;       % torque at tip [N·m] (about z)
e        = 7e-3;        % eccentricity into page (y) [m]

%% 2) MATERIAL
E        = 1.7e9;       % Young's modulus    [Pa]
nu       = 0.35;        % Poisson's ratio
G        = E/(2*(1+nu));% Shear modulus      [Pa]
K_eff    = 1;           % Euler effective-length factor
yield = 51e6;           % Yeild stress       [Pa]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% USE HERE:
design = optimize_Ibeam(0.007,2.0); % (m, non-dim)
disp(design)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% NOTESSSSS

% VARIES I-BEAM GEOMETRY SEE REFEENCE IMAGE IN WHATSAPP CHAT

% a0      = INITIAL HEIGHT 
% a_tip   = FINAL TIP HEIGHT
% t       = THICKNESS (WIDTH) OF THE TOP AND BOTTOM BEAMS / WIDTH OF STRUCTURE
% t_w     = THICKNESS OF CANETER STRUTS
% t_f     = THICKNESS (HEIGHT) OF TOP AND BOTTOM BEAMS

% OBJECTIVE FUNCTION = VOLUME

% CONSTRAINTS:

% DEFLECTIONS (IN PLANE & OUT OF PLANE)

% SAFETY FACTOR


%% 11) OPTIMIZATION ROUTINE with Parallel Processing
function design = optimize_Ibeam(v_max, SF_min)
  % Start parallel pool if none exists
  if isempty(gcp('nocreate'))
    parpool; 
  end

  % Bounds and initial guess (unchanged)
  lb = [0.06, 0.02, 0.008, 0.001,0.001];
  ub = [0.06, 0.02, 0.008, 0.010,0.010];
  x0 = [0.06, 0.02, 0.008, 0.008,0.008];


  % fmincon with parallel derivatives
  opts = optimoptions('fmincon', ...
                      'Display','iter', ...
                      'Algorithm','sqp', ...
                      'UseParallel',true);

  [x_opt, vol] = fmincon(@obj, x0, [],[],[],[], lb,ub, @cons, opts);

  design.a0     = x_opt(1);
  design.a_tip  = x_opt(2);
  design.t      = x_opt(3);
  design.t_w    = x_opt(4);
  design.t_f    = x_opt(5);
  design.volume = vol;

  %% Objective: cross‐sectional volume
  function V = obj(x)
    a0   = x(1); a_tip = x(2); t  = x(3);
    t_w  = x(4); t_f   = x(5);
    L    = 0.30;
    z    = linspace(0,L,1000);
    a    = a0 + (a_tip-a0)*(z/L);
    A    = a.*t - (t-t_w).*(a-2*t_f);
    V    = trapz(z, A);
  end

  %% Nonlinear constraints
  function [c,ceq] = cons(x)
    [v_ip_tip, v_oop_tip, sigma_vm_max] = analyze_IB(x);
    yield = 51e6;           % Yeild stress       [Pa]
    c = [ v_ip_tip  - v_max; ...
          v_oop_tip - v_max; ...
          sigma_vm_max - yield/SF_min ];
    ceq = [];
  end

  %% Structural analysis (same formulas & names as before)
  function [v_ip_tip, v_oop_tip, sigma_vm_max] = analyze_IB(x)
    a0    = x(1); a_tip = x(2); t    = x(3);
    t_w   = x(4); t_f   = x(5);
    L     = 0.30;
    N   = 1e6;

    P_end    = 13;          % thrust load at tip [N] (in +x)
    T_end    = 0.305;       % torque at tip [N·m] (about z)
    e        = 7e-3;        % eccentricity into page (y) [m]
    
    %% 2) MATERIAL
    E        = 1.7e9;       % Young's modulus    [Pa]
    nu       = 0.35;        % Poisson's ratio
    G        = E/(2*(1+nu));% Shear modulus      [Pa]
    K_eff    = 1;           % Euler effective-length factor
    yield = 51e6;           % Yeild stress       [Pa]

    % Section 3
    z     = linspace(0,L,N)'; dz=z(2)-z(1);
    a     = a0 + (a_tip-a0)*(z./L);
    B     = a; H=t*ones(size(z));
    A_sec = B.*H - (t-t_w).*(a-2*t_f);
    I_ip  = (H.*B.^3)/12 - ((t-t_w).*(a-2*t_f).^3)/12;
    I_oop = (B.*H.^3)/12 - (((t-t_w).^3).*(a-2*t_f))/12;
    J_sec = I_ip + I_oop;
    c_ip  = B/2;

    % Section 4
    Vloc  = P_end*ones(size(z));
    M_ip  = P_end*(L-z);
    M_oop = P_end*e*ones(size(z));
    Mtot  = M_ip + M_oop;

    % Section 5
    C1_ip  = cumsum(Mtot./(E.*I_ip))*dz;
    v_ip   = cumsum(C1_ip)*dz;
    v_ip_tip = v_ip(end);

    C1_oop = cumsum(M_oop./(E.*I_oop))*dz;
    v_oop  = cumsum(C1_oop)*dz;
    v_oop_tip = v_oop(end);

    % Section 7
    sigma_b_ip = Mtot.*c_ip./I_ip;
    tau_t_loc  = T_end.*c_ip./J_sec;
    sigma_vm   = sqrt(sigma_b_ip.^2 + 3*tau_t_loc.^2);
    sigma_vm_max = max(sigma_vm);
  end
end








