% =========================================================================
% MT3005 - Cinemática inversa numérica de manipuladores 
%                         seriales
% -------------------------------------------------------------------------

%% Dev. Miguel Zea
% Modificado por Fernando Sandoval, 2023
% Verificar existencia de:
% robot_fkine 
% robot_ikine
% Funciones necesarias dentro del proyecto.

class = 2

% condicionales para manejo del control
if class == 1
    % configuracion final
    % clase 1
    qtest = [pi/2, 0, pi, -pi/2, pi/3, -pi/3]';
elseif class ==2
    % clase 2
    qtest = [0.1, pi/2, 0, pi/2, -pi/3, 0]';
end

% configuracion inicio
q0 = zeros(6, 1);

% possible fields: {'pinv', 'dampedls', 'transpose'}
Tdtest = robot_fkine(qtest);

[qpos,qpos_hist] = robot_ikine(Tdtest, q0, 'pos', 'pinv');

%% Simulacion
mdl_puma560;

% Histórico de la configuración
figure('WindowState', 'maximized');

subplot(1,2,1);
plot(qpos_hist', 'LineWidth', 1);

ylabel('$\mathbf{q}_k$', 'Interpreter', 'latex', 'FontSize', 18);
xlabel('$k$', 'Interpreter', 'latex', 'FontSize', 18);
grid minor;

% Animación del histórico
subplot(1,2,2);
p560.plot3d(q0');
pause(0.5);
p560.plot3d(qpos');