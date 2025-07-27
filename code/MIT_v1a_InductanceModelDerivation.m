%clearvars; close all;
% =================================================================================================
%  3D-MIT symbolic modelling based on coupled–inductor model and 2×2 reluctance system
% =================================================================================================
%
%  Solving the reluctance network of the 3D-MIT to its coupled-inductor
%  model, and the respective T-circuit transformer model parameters.
%
% =================================================================================================
% (c) 2025, Hans Wouters, MIT Licence
% =================================================================================================

colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000"];
hex2rgb = @(hex) sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;


syms Ra Rb Rg real                        % core and gap reluctances
syms Np1 Ns1 Np2 Ns2 N dN Ip Is real           % winding data & currents


%% 1. Magneto-motive-force (MMF) sources for each window

MMF = [ Np1*Ip - Ns1*Is ;           % top window (dot convention)
        Np2*Ip - Ns2*Is ];          % bottom window


%% 2. Build the reluctance matrix based on Kirchhoff KVL
%    Rs = Ra + 2*Rg   is the series reluctance of one outer window

Rs = Ra + 2*Rg;
R  = [ Rs + Rb,  -Rb ;
       -Rb    ,  Rs + Rb ];


%% 3. Solve for fluxes (symbolically)

phi  = simplify(R \ MMF);         % same as inv(R)*MMF but faster
phi_A1 = phi(1);
phi_A2 = phi(2);
phi_B = simplify(phi_A2 - phi_A1);     % Kirchhoff KCL

disp('phi_A1 ='), pretty(phi_A1);
disp('phi_A2 ='), pretty(phi_A2);
disp('phi_B ='), pretty(phi_B);


%% 4. Solve for self-inductances based on L11*Ip = lambda_p |is=0

% Flux linkages
lambda_p = simplify(Np1*phi_A1 + Np2*phi_A2);
lambda_s = simplify(Ns1*-phi_A1 + Ns2*-phi_A2);

% Self- and mutual inductances
L11 = simplify(subs(lambda_p/Ip, Is, 0));      % substitute Is→0 and divide by Ip
L22 = simplify(subs(lambda_p/Ip, Is, 0));      % substitute Is→0 and divide by Ip
L21 = simplify(subs(lambda_s/Ip, Is, 0));      % substitute Is→0 and divide by Ip
L12 = simplify(subs(lambda_p/Is, Ip, 0));      % substitute Ip→0 and divide by Is
disp('L11 ='), pretty(L11);
disp('L22 ='), pretty(L22);
disp('L21 ='), pretty(L21);
disp('L12 ='), pretty(L12);


%% 5. Convert to T-circuit transformer model

Lm = -L12;
Lkp = simplify(L11-Lm);
Lks = simplify(L22-Lm);
Ln = simplify(Lm/Lkp);
disp('Lm ='), pretty(Lm);
disp('Lkp ='), pretty(Lkp);
disp('Ln ='), pretty(Ln);


%% 6. Simplify based on winding distribution constraints

S = struct( ...
    'Np1',(N+dN)/2, ...
    'Np2',(N-dN)/2, ...
    'Ns1',(N-dN)/2, ...
    'Ns2',(N+dN)/2);

Lm_sim  = simplify(subs(Lm , S));
Lkp_sim = simplify(subs(Lkp, S));
Lks_sim = simplify(subs(Lks, S));
Ln_sim  = simplify(subs(Ln , S));

disp('Lm simplified ='), pretty(Lm_sim);
disp('Lkp_sim simplified ='), pretty(Lkp_sim);
disp('Ln_sim simplified ='), pretty(Ln_sim);




%% APPENDIX: Solve for example cases

Np1_proto1 = 4; Ns1_proto1 = 3;
Np2_proto1 = 3; Ns2_proto1 = 4;
Rg_proto1 = 6e5;
Ra_proto1 = Rg_proto1/100;
Rb_proto1 = Rg_proto1/100;

Lm_proto1 = double(simplify( ...
        subs(1e6*Lm, ...
             [Np1, Np2, Ns1, Ns2, Ra, Rb, Rg], ...   % symbols to replace
             [Np1_proto1, Np2_proto1, Ns1_proto1, Ns2_proto1, Ra_proto1, Rb_proto1, Rg_proto1])));  % replacement values

Lkp_proto1 = double(simplify( ...
        subs(1e6*Lkp, ...
             [Np1  Np2  Ns1  Ns2   Ra        Rb     Rg], ...   % symbols to replace
             [Np1_proto1, Np2_proto1, Ns1_proto1, Ns2_proto1, Ra_proto1, Rb_proto1, Rg_proto1])));  % replacement values

Lk_proto1 = double(simplify( ...
        subs(2e6*Lkp, ...
             [Np1  Np2  Ns1  Ns2   Ra        Rb     Rg], ...   % symbols to replace
             [Np1_proto1, Np2_proto1, Ns1_proto1, Ns2_proto1, Ra_proto1, Rb_proto1, Rg_proto1])));  % replacement values

Ln_proto1 = Lm_proto1/Lkp_proto1;
fprintf('\nPrototype #1 test case\n');
fprintf('Lm = %8.3f µH\n', Lm_proto1);
fprintf('Lkp = %8.3f µH\n', Lkp_proto1);
fprintf('Lk = %8.3f µH\n', Lk_proto1);
fprintf('Ln = %8.1f \n', Ln_proto1);


Np1_proto2 = 5; Ns1_proto2 = 4;
Np2_proto2 = 4; Ns2_proto2 = 5;
Rg_proto2 = 765167;
Ra_proto2 = Rg_proto2/100;
Rb_proto2 = Rg_proto2/100;

Lm_proto2 = double(simplify( ...
        subs(1e6*Lm, ...
             [Np1, Np2, Ns1, Ns2, Ra, Rb, Rg], ...   % symbols to replace
             [Np1_proto2, Np2_proto2, Ns1_proto2, Ns2_proto2, Ra_proto2, Rb_proto2, Rg_proto2])));  % replacement values

Lkp_proto2 = double(simplify( ...
        subs(1e6*Lkp, ...
             [Np1  Np2  Ns1  Ns2   Ra        Rb     Rg], ...   % symbols to replace
             [Np1_proto2, Np2_proto2, Ns1_proto2, Ns2_proto2, Ra_proto2, Rb_proto2, Rg_proto2])));  % replacement values

Lk_proto2 = double(simplify( ...
        subs(2e6*Lkp, ...
             [Np1  Np2  Ns1  Ns2   Ra        Rb     Rg], ...   % symbols to replace
             [Np1_proto2, Np2_proto2, Ns1_proto2, Ns2_proto2, Ra_proto2, Rb_proto2, Rg_proto2])));  % replacement values

Ln_proto2 = Lm_proto2/Lkp_proto2;
fprintf('\nPrototype #2 test case\n');
fprintf('Lm = %8.3f µH\n', Lm_proto2);
fprintf('Lkp = %8.3f µH\n', Lkp_proto2);
fprintf('Lk = %8.3f µH\n', Lk_proto2);
fprintf('Ln = %8.1f \n', Ln_proto2);



%% Appendix: Solve simplified models for same cases

N_proto_1 = 7; dN_proto1 = 1;
Rg_proto1 = 6e5;
Ra_proto1 = Rg_proto1/100;
Rb_proto1 = Rg_proto1/100;

Lm_proto1 = double(simplify( ...
        subs(1e6*Lm_sim, ...
             [N, dN, Ra, Rb, Rg], ...   % symbols to replace
             [N_proto_1, dN_proto1, Ra_proto1, Rb_proto1, Rg_proto1])));  % replacement values

Lkp_proto1 = double(simplify( ...
        subs(1e6*Lkp_sim, ...
             [N, dN, Ra, Rb, Rg], ...   % symbols to replace
             [N_proto_1, dN_proto1, Ra_proto1, Rb_proto1, Rg_proto1])));  % replacement values

Lk_proto1 = double(simplify( ...
        subs(2e6*Lkp_sim, ...
             [N, dN, Ra, Rb, Rg], ...   % symbols to replace
             [N_proto_1, dN_proto1, Ra_proto1, Rb_proto1, Rg_proto1])));  % replacement values

Ln_proto1 = Lm_proto1/Lkp_proto1;
fprintf('\nPrototype #1 test case\n');
fprintf('Lm = %8.3f µH\n', Lm_proto1);
fprintf('Lkp = %8.3f µH\n', Lkp_proto1);
fprintf('Lk = %8.3f µH\n', Lk_proto1);
fprintf('Ln = %8.1f \n', Ln_proto1);


N_proto_2 = 9; dN_proto2 = 1;
Rg_proto2 = 765167;
Ra_proto2 = Rg_proto2/100;
Rb_proto2 = Rg_proto2/100;

Lm_proto2 = double(simplify( ...
        subs(1e6*Lm_sim, ...
             [N, dN, Ra, Rb, Rg], ...   % symbols to replace
             [N_proto_2, dN_proto2, Ra_proto2, Rb_proto2, Rg_proto2])));  % replacement values

Lkp_proto2 = double(simplify( ...
        subs(1e6*Lkp_sim, ...
             [N, dN, Ra, Rb, Rg], ...   % symbols to replace
             [N_proto_2, dN_proto2, Ra_proto2, Rb_proto2, Rg_proto2])));  % replacement values

Lk_proto2 = double(simplify( ...
        subs(2e6*Lkp_sim, ...
             [N, dN, Ra, Rb, Rg], ...   % symbols to replace
             [N_proto_2, dN_proto2, Ra_proto2, Rb_proto2, Rg_proto2])));  % replacement values

Ln_proto2 = Lm_proto2/Lkp_proto2;
fprintf('\nPrototype #2 test case\n');
fprintf('Lm = %8.3f µH\n', Lm_proto2);
fprintf('Lkp = %8.3f µH\n', Lkp_proto2);
fprintf('Lk = %8.3f µH\n', Lk_proto2);
fprintf('Ln = %8.1f \n', Ln_proto2);