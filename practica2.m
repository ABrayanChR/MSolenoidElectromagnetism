function Practica2_Completa_Corregida()
    clear, clc, close all
    % ---------------------------------------------------------------------
    % CONFIGURACIÓN GLOBAL
    % ---------------------------------------------------------------------
    P.e0 = 1; P.mu0 = 1; P.e1 = 1;
    P.c = 1/sqrt(P.e0*P.mu0);
    P.I0 = 1; 
    P.N = 10; % Densidad de vueltas
    P.R = 1;
    
    fprintf('INICIANDO PRÁCTICA 2 - ANÁLISIS NUMÉRICO DE ENERGÍA\n');
    fprintf('=====================================================\n');
    
    %% --------------------------------------------------------------------
    % EJERCICIO 1: CAMPOS VS DISTANCIA RADIAL
    % --------------------------------------------------------------------
    fprintf('\n>>> EJERCICIO 1: Comparación Espacial (t = pi/8)\n');
    t_target = pi/8;
    rho_vec = linspace(0.01, 3, 100); 
    
    % --- CASO A: w0 = 5 (Radiación) ---
    w0_a = 5;
    [E_ana_5, B_ana_5] = solver_analitico_espacial(rho_vec, t_target, w0_a, P);
    [E_num_5, B_num_5] = solver_numerico_fft_espacial(rho_vec, t_target, w0_a, P, 100, 20); 
    
    % --- CASO B: w0 = 0.01 (Cuasiestático) ---
    w0_b = 0.01; 
    [E_ana_qs, B_ana_qs] = solver_analitico_espacial(rho_vec, t_target, w0_b, P);
    [E_num_qs, B_num_qs] = solver_numerico_fft_espacial(rho_vec, t_target, w0_b, P, 10, 600); 
    
    % GRAFICAR EJERCICIO 1
    fig1 = figure('Name', 'Ejercicio 1: Campos vs Distancia', 'WindowState', 'maximized');
    subplot(2,2,1); plot(rho_vec, E_ana_5, 'b', rho_vec, E_num_5, 'ro'); xline(P.R,'k--');
    title(sprintf('E_\\phi (\\omega_0=%.2f)', w0_a)); legend('Analítico', 'Numérico'); grid on;
    subplot(2,2,2); plot(rho_vec, B_ana_5, 'b', rho_vec, B_num_5, 'ro'); xline(P.R,'k--');
    title(sprintf('B_z (\\omega_0=%.2f)', w0_a)); grid on;
    subplot(2,2,3); plot(rho_vec, E_ana_qs, 'g', rho_vec, E_num_qs, 'mx'); xline(P.R,'k--');
    title(sprintf('E_\\phi (\\omega_0=%.2f)', w0_b)); xlabel('\rho (m)'); grid on;
    subplot(2,2,4); plot(rho_vec, B_ana_qs, 'g', rho_vec, B_num_qs, 'mx'); xline(P.R,'k--');
    title(sprintf('B_z (\\omega_0=%.2f)', w0_b)); xlabel('\rho (m)'); grid on;
    saveas(fig1, 'Ejercicio1_CamposEspaciales.png');

    %% --------------------------------------------------------------------
    % EJERCICIO 2: EVOLUCIÓN TEMPORAL
    % --------------------------------------------------------------------
    fprintf('\n>>> EJERCICIO 2: Evolución Temporal\n');
    w0_3 = 5;
    radios_obs = [0.5, 1.1, 5];
    t_plot = linspace(0, 2*pi/w0_3, 100);
    t_num = 0:0.01:20;
    
    fig2 = figure('Name', 'Ejercicio 2: Evolución Temporal', 'WindowState', 'maximized');
    for k = 1:length(radios_obs)
        r = radios_obs(k);
        [E_t_ana, B_t_ana] = solver_analitico_temporal(r, t_plot, w0_3, P);
        [E_t_num, B_t_num] = solver_numerico_fft_temporal(r, w0_3, t_num, P);
        
        subplot(3, 1, k);
        yyaxis left; plot(t_plot, E_t_ana, 'b-', t_num, E_t_num, 'bo'); ylabel('Campo E');
        yyaxis right; plot(t_plot, B_t_ana, 'r-', t_num, B_t_num, 'rx'); ylabel('Campo B');
        title(sprintf('\\rho = %.1f m', r)); xlim([0, 2*pi/w0_3]); 
        if k==1, legend('E Ana', 'E Num', 'B Ana', 'B Num'); end
    end
    saveas(fig2, 'Ejercicio2_Temporal.png');
    
    %% --------------------------------------------------------------------
    % EJERCICIO 3: ENERGÍA TOTAL ACUMULADA (CASO COSENOIDAL)
    % --------------------------------------------------------------------
    fprintf('\n>>> EJERCICIO 3: Energía Total Acumulada (Cosenoidal - Numérico)\n');
    
    rho_E = linspace(0.01, 3, 50); 
    w_list = [5, 0.01]; 
    Fs = 100; T_sim = 20; 
    t_vec_cos = 0:1/Fs:T_sim-1/Fs;
    
    fig3 = figure('Name', 'Ejercicio 3: Energía Acumulada Cosenoidal', 'WindowState', 'maximized');
    
    for k = 1:length(w_list)
        wk = w_list(k);
        I_cos = P.I0 * cos(wk * t_vec_cos);
        [E_Tot_Rad, E_Tot_In] = calcular_energia_numerica_generica(rho_E, I_cos, t_vec_cos, P);
        
        subplot(length(w_list), 1, k);
        plot(rho_E, E_Tot_Rad, 'b-o', 'LineWidth', 1.5); hold on;
        yline(E_Tot_In, 'g--', 'LineWidth', 2);
        xline(P.R, 'r:', 'Radio Solenoide');
        
        title(sprintf('Energía Total Acumulada (T_{sim}=%ds, \\omega_0=%.2f)', T_sim, wk));
        ylabel('Energía [J/m]');
        legend('E_{radiada}(\rho) (Numérica)', 'E_{entrada} (Numérica)', 'Location', 'best');
        if k == length(w_list), xlabel('Radio \rho (m)'); end
        grid on;
    end
    saveas(fig3, 'Ejercicio3_EnergiaCoseno.png');
    
    %% --------------------------------------------------------------------
    % EJERCICIO 4: PULSO GAUSSIANO (ENERGÍA TOTAL)
    % --------------------------------------------------------------------
    fprintf('\n>>> EJERCICIO 4: Pulso Gaussiano\n');
    w0_g = 5; gamma = 1/(2*w0_g);
    Fs = 100; T_sim = 40; t_vec = 0:1/Fs:T_sim-1/Fs; t_center = 10; 
    I_gauss = P.I0 * cos(w0_g*(t_vec - t_center)) .* exp(-gamma * (t_vec - t_center).^2);
    
    rho_g = linspace(0.1, 5, 50);
    [E_Tot_Rad_G, E_Tot_In_G] = calcular_energia_numerica_generica(rho_g, I_gauss, t_vec, P);
    
    fig4 = figure('Name', 'Ejercicio 4: Energía Gaussiana', 'WindowState', 'maximized');
    subplot(2,1,1); plot(t_vec, I_gauss, 'k'); title('Corriente I(t)'); xlim([5 15]); grid on;
    subplot(2,1,2); plot(rho_g, E_Tot_Rad_G, 'b-o', 'LineWidth', 1.5); hold on;
    yline(E_Tot_In_G, 'g--', 'LineWidth', 2); xline(P.R, 'r--');
    title('Energía Total Acumulada [J/m]'); legend('E_{radiada}(\rho)', 'E_{entrada}'); grid on;
    saveas(fig4, 'Ejercicio4_EnergiaGauss.png');
    
    % Surf
    fprintf('    Calculando surf...\n');
    rho_surf = linspace(0.1, 4, 30); [R_m, T_m] = meshgrid(rho_surf, t_vec);
    E_mat = zeros(size(T_m));
    for i=1:length(rho_surf), [E_mat(:,i), ~] = solver_numerico_fft_temporal_arbitraria(rho_surf(i), I_gauss, t_vec, P); end
    fig5 = figure; surf(R_m, T_m, E_mat); shading interp; view([45 45]);
    title('Campo E (Gaussiano)'); xlabel('\rho'); ylabel('t');
    saveas(fig5, 'Ejercicio4_Surf.png');
    
    %% --------------------------------------------------------------------
    % EJERCICIO 5: ANÁLISIS DE ERROR (NUMÉRICO VS ANALÍTICO)
    % --------------------------------------------------------------------
    fprintf('\n>>> EJERCICIO 5: Análisis de Error Relativo\n');
    % Utilizamos los datos calculados en el Ejercicio 1 (t = pi/8)
    
    % Definición de función anónima para error relativo con protección de división por cero
    % Error = |Num - Ana| / (|Ana| + epsilon)
    calc_error = @(ana, num) abs(num - ana) ./ (abs(ana) + 1e-15);
    
    % Calculamos errores para Caso A (w=5)
    Err_E_5 = calc_error(E_ana_5, E_num_5);
    Err_B_5 = calc_error(B_ana_5, B_num_5);
    
    % Calculamos errores para Caso B (w=0.01)
    Err_E_qs = calc_error(E_ana_qs, E_num_qs);
    Err_B_qs = calc_error(B_ana_qs, B_num_qs);
    
    fig6 = figure('Name', 'Ejercicio 5: Errores Relativos', 'WindowState', 'maximized');
    
    % Subplot 1: Error E (w=5)
    subplot(2,2,1);
    semilogy(rho_vec, Err_E_5, 'r-', 'LineWidth', 1.5);
    title('Error Relativo E_\phi (\omega_0=5)');
    ylabel('Error Relativo'); grid on; xline(P.R, 'k--');
    
    % Subplot 2: Error B (w=5)
    subplot(2,2,2);
    semilogy(rho_vec, Err_B_5, 'r-', 'LineWidth', 1.5);
    title('Error Relativo B_z (\omega_0=5)');
    ylabel('Error Relativo'); grid on; xline(P.R, 'k--');
    
    % Subplot 3: Error E (w=0.01)
    subplot(2,2,3);
    semilogy(rho_vec, Err_E_qs, 'm-', 'LineWidth', 1.5);
    title('Error Relativo E_\phi (\omega_0=0.01)');
    ylabel('Error Relativo'); xlabel('\rho (m)'); grid on; xline(P.R, 'k--');
    
    % Subplot 4: Error B (w=0.01)
    subplot(2,2,4);
    semilogy(rho_vec, Err_B_qs, 'm-', 'LineWidth', 1.5);
    title('Error Relativo B_z (\omega_0=0.01)');
    ylabel('Error Relativo'); xlabel('\rho (m)'); grid on; xline(P.R, 'k--');
    
    saveas(fig6, 'Ejercicio5_Errores.png');
    
    fprintf('\n>>> PRÁCTICA FINALIZADA.\n');
end

%% ========================================================================
%  FUNCIONES DE CÁLCULO
%  ========================================================================

function [E_rad_total, E_in_total] = calcular_energia_numerica_generica(rho_vec, I_t, t_vec, P)
    % Esta función calcula numéricamente la energía total integrada en el tiempo
    % para CUALQUIER forma de onda de corriente I_t (Coseno, Gaussiana, etc.)
    
    Fs = 1/(t_vec(2)-t_vec(1));
    I_w = fft(I_t);
    L = length(t_vec);
    w_vec = 2*pi * (0:L-1)*(Fs/L);
    half = floor(L/2);
    w_vec(half+1:end) = w_vec(half+1:end) - 2*pi*Fs;
    dt = 1/Fs;
    
    % 1. Energía de Entrada (Trabajo de la fuente)
    [He_s, ~] = get_tf(P.R, w_vec, P);
    % Fem inducida en superficie
    E_surf_t = real(ifft(He_s .* I_w)); 
    % Potencia inst = - J * E (J = N*I)
    P_in_t = -real(P.N * I_t) .* E_surf_t * (2*pi*P.R);
    E_in_total = sum(P_in_t) * dt;
    
    % 2. Energía Radiada (Salida) vs rho
    E_rad_total = zeros(size(rho_vec));
    for i = 1:length(rho_vec)
        r = rho_vec(i);
        [He, Hb] = get_tf(r, w_vec, P);
        
        E_t = real(ifft(He .* I_w));
        B_t = real(ifft(Hb .* I_w));
        
        % Vector de Poynting Instantáneo S(t) = 1/mu0 * E*B
        S_t = (1/P.mu0) * E_t .* B_t;
        
        % Energía acumulada = Integral(S dt) * Area
        E_rad_total(i) = sum(S_t) * dt * (2*pi*r);
    end
end

% --- SOLVER NUMÉRICO ESPACIAL (CORREGIDO) ---
function [E_val, B_val] = solver_numerico_fft_espacial(rho_vec, t_target, w0, P, Fs, T_sim)
    t_vec = 0:1/Fs:T_sim-1/Fs;
    I_t = P.I0 * cos(w0 * t_vec);
    I_w = fft(I_t);
    L = length(t_vec);
    f = (0:L-1)*(Fs/L);
    w_vec = 2*pi * f;
    half = floor(L/2);
    w_vec(half+1:end) = w_vec(half+1:end) - 2*pi*Fs;
    
    [~, idx] = min(abs(t_vec - t_target));
    E_val = zeros(size(rho_vec)); 
    B_val = zeros(size(rho_vec));
    
    for i = 1:length(rho_vec)
        [He, Hb] = get_tf(rho_vec(i), w_vec, P);
        
        % Cálculo correcto: IFFT completa, luego extraer índice
        E_full_t = real(ifft(He .* I_w));
        B_full_t = real(ifft(Hb .* I_w));
        
        E_val(i) = E_full_t(idx);
        B_val(i) = B_full_t(idx);
    end
end

% --- MOTORES DE CÁLCULO RESTANTES ---
function [E, B] = solver_analitico_espacial(rho, t, w, P)
    k0 = w*sqrt(P.mu0*P.e0);
    for i = 1:length(rho)
        r = rho(i);
        W = P.R * ( k0*besselj(1, k0*P.R)*besselh(0,1,k0*P.R) - k0*besselj(0,k0*P.R)*besselh(1,1,k0*P.R) );
        if r <= P.R
           G = -P.R*besselh(1,1,k0*P.R)*besselj(1,k0*r)/W; dG = (-P.R*besselh(1,1,k0*P.R)/W)*besselj(0,k0*r)*k0;
        else
           G = -P.R*besselj(1,k0*P.R)*besselh(1,1,k0*r)/W; dG = (-P.R*besselj(1,k0*P.R)/W)*besselh(0,1,k0*r)*k0;
        end
        E_c = 1i*w*P.mu0*P.N*P.I0*G; B_c = P.mu0*P.N*P.I0*dG;
        E(i) = real(E_c*exp(1i*w*t)); B(i) = real(B_c*exp(1i*w*t));
    end
end
function [E_t, B_t] = solver_numerico_fft_temporal(r, w0, t_vec, P)
    Fs=1/(t_vec(2)-t_vec(1)); I_t=P.I0*cos(w0*t_vec); [He, Hb]=get_tf_vec(r, t_vec, P);
    E_t=real(ifft(He.*fft(I_t))); B_t=real(ifft(Hb.*fft(I_t)));
end
function [E_t, B_t] = solver_numerico_fft_temporal_arbitraria(r, I_t, t_vec, P)
    [He, Hb]=get_tf_vec(r, t_vec, P); E_t=real(ifft(He.*fft(I_t))); B_t=real(ifft(Hb.*fft(I_t)));
end
function [E,B] = solver_analitico_temporal(r, t_vec, w, P)
    E=zeros(size(t_vec)); B=zeros(size(t_vec));
    for k=1:length(t_vec), [E(k),B(k)]=solver_analitico_espacial(r, t_vec(k), w, P); end
end
function [He, Hb] = get_tf_vec(r, t_vec, P)
    Fs=1/(t_vec(2)-t_vec(1)); L=length(t_vec); w_vec=2*pi*(0:L-1)*(Fs/L); 
    half=floor(L/2); w_vec(half+1:end)=w_vec(half+1:end)-2*pi*Fs;
    [He, Hb]=get_tf(r, w_vec, P);
end
function [He, Hb] = get_tf(r, w_vec, P)
    wa=abs(w_vec)+eps; k=wa*sqrt(P.mu0*P.e0); W=P.R*(k.*besselj(1,k*P.R).*besselh(0,1,k*P.R)-k.*besselj(0,k*P.R).*besselh(1,1,k*P.R));
    if r<=P.R, G=-P.R*besselh(1,1,k*P.R).*besselj(1,k*r)./W; dG=(-P.R*besselh(1,1,k*P.R)./W).*besselj(0,k*r).*k;
    else, G=-P.R*besselj(1,k*P.R).*besselh(1,1,k*r)./W; dG=(-P.R*besselj(1,k*P.R)./W).*besselh(0,1,k*r).*k; end
    He=1i*wa*P.mu0*P.N.*G; Hb=P.mu0*P.N*dG;
    neg=w_vec<0; He(neg)=conj(He(neg)); Hb(neg)=conj(Hb(neg));
end