%% ------------------------------------------------------------------------
% Duocopter Arm — constant thickness, tapered width + tip point‐load + torque
%    using exact solid-rectangle section properties
% -------------------------------------------------------------------------
clc; clear; close all;

%% 1) GEOMETRY & LOADS
a0       = 6e-2;        % width @ root [m]
a_tip    = 2e-2;        % width @ tip  [m]
t        = 8e-3;        % constant thickness [m]
L        = 0.30;        % arm length [m]

P_end    = 13;          % thrust load at tip [N] (in +x)
T_end    = 0.305;       % torque at tip [N·m] (about z)
e        = 7e-3;        % eccentricity into page (y) [m]

%% 2) MATERIAL
E        = 1.7e9;       % Young's modulus    [Pa]
nu       = 0.35;        % Poisson's ratio
G        = E/(2*(1+nu));% Shear modulus      [Pa]
K_eff    = 1;           % Euler effective-length factor
yield = 51e6;           % Yeild stress       [Pa]

%% 3) DISCRETISATION & SECTION PROPERTIES
N   = 1e4;
z   = linspace(0, L, N)';     % 0 at root → L at tip
dz  = z(2) - z(1);

% Tapered width
a   = a0 + (a_tip - a0)*(z./L);

% Treat rectangle: B = a(z), H = t
B   = a;          % rectangle width
H   = t * ones(size(z));  % constant thickness

% Exact area
A   = B .* H;               

% Exact 2nd moments of area
I_ip   = (H .* B.^3) / 12;   % bending about y-axis (in-plane)
I_oop  = (B .* H.^3) / 12;   % bending about x-axis (out-of-plane)

% Polar moment approx for solid rect: J = Ix + Iy
J      = I_ip + I_oop;

% Outer fiber distances
c_ip   = B/2;
c_oop  = H/2;

%% 4) INTERNAL FORCE & MOMENT (point load + eccentricity)
V     = P_end*ones(size(z));
M_ip  = P_end*(L - z);       % bending about y from thrust line
M_oop = P_end*e   * ones(size(z)); % bending about x from eccentricity
M     = M_ip + M_oop;        % total moment for in-plane deflection


%% 5) DEFLECTION & TWIST
% Bending deflection via double integration
C1_ip   = cumsum( M ./ (E .* I_ip) ) * dz;
v_ip    = cumsum( C1_ip ) * dz;          % in-plane deflection

C1_oop  = cumsum( M_oop ./ (E .* I_oop) ) * dz;
v_oop   = cumsum( C1_oop ) * dz;         % out-of-plane deflection

theta   = cumsum( T_end ./ (G .* J) ) * dz;  % torsional twist


%% 6) EULER BUCKLING
Imin_ip   = min(I_ip);
Imin_oop  = min(I_oop);

Pcr_ip    = pi^2 * E * Imin_ip  / ( (K_eff*L)^2 );
Pcr_oop   = pi^2 * E * Imin_oop / ( (K_eff*L)^2 );

Pcr_e_ip  = Pcr_ip  / (1 + e*pi/L);
Pcr_e_oop = Pcr_oop / (1 + e*pi/L);

%% 7) STRESSES
sigma_b_ip  = M .* c_ip   ./ I_ip;   % in-plane bending [Pa]
sigma_b_oop = M .* c_oop  ./ I_oop;  % out-of-plane bending [Pa]
tau_s       = 1.5 * V     ./ A;      % transverse shear [Pa]
tau_t       = T_end * c_ip ./ J;     % torsional shear [Pa]

% Von Mises combining bending and torsion
sigma_vm = sqrt( sigma_b_ip.^2 + 3*(tau_t).^2 );

%% 8) PLOT — distributions + oop defl
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
tiledlayout(3,3,'Padding','compact','TileSpacing','compact');

nexttile
plot(z,a,'LineWidth',1.5), title('Width'), xlabel('z [m]'), ylabel('a(z) [m]'), grid on;

nexttile
plot(z,V,'LineWidth',1.5), title('Shear'), xlabel('z'), ylabel('V [N]'), grid on;

nexttile
plot(z,M,'LineWidth',1.5), title('Moment'), xlabel('z'), ylabel('M [N·m]'), grid on;

nexttile
plot(z, v_ip*1e3,'LineWidth',1.5), title('Deflection (in-plane)'), xlabel('z'), ylabel('v [mm]'), grid on;

nexttile
plot(z, v_oop*1e3,'LineWidth',1.5), title('Deflection (out-of-plane)'), xlabel('z'), ylabel('v_{oop} [mm]'), grid on;

nexttile
plot(z, theta*180/pi,'LineWidth',1.5), title('Twist'), xlabel('z'), ylabel('\theta [°]'), grid on;

nexttile([1 2])
bar(1:4,[Pcr_ip Pcr_e_ip Pcr_oop Pcr_e_oop],'FaceColor',[.2 .6 .8]);
xticklabels({'P_{cr,ip}','P_{cr,e,ip}','P_{cr,oop}','P_{cr,e,oop}'});
title('Buckling'), ylabel('Load [N]'), grid on;

sgtitle('Duocopter Arm — Structural Distributions','FontWeight','Bold');

%% 9) PLOT — stresses including Von Mises & yield limit
figure('Units','normalized','Position',[0.2 0.2 0.6 0.6]);
plot(z, sigma_b_ip/1e6,'-','LineWidth',1.5); hold on;
plot(z, sigma_b_oop/1e6,'-','LineWidth',1.5);
plot(z, tau_s/1e6,'--','LineWidth',1.5);
plot(z, tau_t/1e6,':','LineWidth',1.5);
plot(z, sigma_vm/1e6,'-k','LineWidth',2);
yline(yield/1e6,'r--','LineWidth',1.5);
hold off;
xlabel('z [m]'); ylabel('Stress [MPa]');
legend('\sigma_{b,ip}','\sigma_{b,oop}','\tau_s','\tau_t','\sigma_{vm}','\sigma_{yield}');
title('Stress Distributions (Von Mises + Yield)'); grid on;

%% 10) OUTPUT SUMMARY
fprintf('Tip deflection (ip)    = %.2f mm\n',v_ip(end)*1e3);
fprintf('Tip deflection (oop)   = %.2f mm\n',v_oop(end)*1e3);
fprintf('Tip twist              = %.2f°\n',theta(end)*180/pi);
fprintf('Max sigma_{vm}        = %.2f MPa (yield = %.0f MPa)\n',...
        max(sigma_vm)/1e6, yield/1e6);
fprintf('Buckling: Pcr_ip=%.1f N, Pcr_e_ip=%.1f N\n',Pcr_ip,Pcr_e_ip);
fprintf('          Pcr_oop=%.1f N, Pcr_e_oop=%.1f N\n',Pcr_oop,Pcr_e_oop);





