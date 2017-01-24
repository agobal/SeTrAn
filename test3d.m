%% Arash Gobal 
%
% The purpose of this program is to test a FEM model to analyze truss
% structures 

clear all
clc


%% 1. Defining node coordinates and bar arrangements

% Nodal coordinates
number_of_nodes = 8;
x_nodes = zeros(number_of_nodes, 1);
y_nodes = zeros(number_of_nodes, 1);
z_nodes = zeros(number_of_nodes, 1);

x_nodes = [1; 1; 1; 1; 2; 2; 2; 2];
y_nodes = [1; 2; 1; 2; 1; 2; 1; 2];
z_nodes = [1; 1; 2; 2; 1; 1; 2; 2];

bar_count = 18;
bars = zeros(bar_count, 2);

bars(1, :) = [1 2]; bars(2, :) = [1 3]; bars(3, :) = [1 4]; bars(4, :) = [1 5];
bars(5, :) = [2 4]; bars(6, :) = [2 5]; bars(7, :) = [2 6]; bars(8, :) = [3 4];
bars(9, :) = [3 5]; bars(10, :) = [3 7]; bars(11, :) = [4 6]; bars(12, :) = [4 7];
bars(13, :) = [4 8]; bars(14, :) = [5 6]; bars(15, :) = [5 7]; bars(16, :) = [6 7];
bars(17, :) = [6 8]; bars(18, :) = [7 8];

bar_length = zeros(bar_count, 1);
bar_angle = zeros(bar_count, 3);
for i = 1:bar_count
    bar_length(i, 1) = sqrt( (x_nodes(bars(i, 1), 1) - x_nodes(bars(i, 2), 1))^2 + (y_nodes(bars(i, 1), 1) - y_nodes(bars(i, 2), 1))^2 + (z_nodes(bars(i, 1), 1) - z_nodes(bars(i, 2), 1))^2 );
    bar_angle(i, 1) = (x_nodes(bars(i, 2), 1) - x_nodes(bars(i, 1), 1))/bar_length(i, 1);
    bar_angle(i, 2) = (y_nodes(bars(i, 2), 1) - y_nodes(bars(i, 1), 1))/bar_length(i, 1);
    bar_angle(i, 3) = (z_nodes(bars(i, 2), 1) - z_nodes(bars(i, 1), 1))/bar_length(i, 1);
end

%% Relationships for plane stress problem

E = 207000000000;  %modulus of elasticity
A = pi*0.05^2;

%% Assembly of the stiffness matrix
K_local = zeros(6, 6);
K_global = zeros(3*number_of_nodes, 3*number_of_nodes);

for i = 1:bar_count
    cx = bar_angle(i, 1);
    cy = bar_angle(i, 2);
    cz = bar_angle(i, 3);
    K_local = (A*E/bar_length(i, 1))*[cx^2 cx*cy cx*cz -cx^2 -cx*cy -cx*cz;
                                      cx*cy cy^2 cy*cz -cx*cy -cy^2 -cy*cz;
                                      cx*cz cy*cz cz^2 -cx*cz -cy*cz -cz^2;
                                      -cx^2 -cx*cy -cx*cz cx^2 cx*cy cx*cz;
                                      -cx*cy -cy^2 -cy*cz cx*cy cy^2 cy*cz;
                                      -cx*cz -cy*cz -cz^2 cx*cz cy*cz cz^2];
    
    a = bars(i, 1);
    b = bars(i, 2);
    K_global((3*(a - 1) + 1):3*a, (3*(b - 1) + 1):3*b) = K_global((3*(a - 1) + 1):3*a, (3*(b - 1) + 1):3*b) + K_local(1:3, 4:6);
    K_global((3*(a - 1) + 1):3*a, (3*(a - 1) + 1):3*a) = K_global((3*(a - 1) + 1):3*a, (3*(a - 1) + 1):3*a) + K_local(1:3, 1:3);
    K_global((3*(b - 1) + 1):3*b, (3*(a - 1) + 1):3*a) = K_global((3*(b - 1) + 1):3*b, (3*(a - 1) + 1):3*a) + K_local(4:6, 1:3);
    K_global((3*(b - 1) + 1):3*b, (3*(b - 1) + 1):3*b) = K_global((3*(b - 1) + 1):3*b, (3*(b - 1) + 1):3*b) + K_local(4:6, 4:6);
end

%% Solving the problem

F = zeros(3*number_of_nodes, 1);
u = zeros(3*number_of_nodes, 1);

% Choosing force nodes
force_nodes = [];
for i = 1:number_of_nodes
    if x_nodes(i, 1) == 2
        force_nodes = [force_nodes i];
    end
end

for i = 1:length(force_nodes)
    j = 3*(force_nodes(i) - 1);
    F(j, 1) = -10000000;
end

% Choosing the fixed nodes
fixed_nodes = [];
fixed_dofs = [];
for i = 1:number_of_nodes
    if x_nodes(i, 1) == 1
        fixed_nodes = [fixed_nodes i];
        fixed_dofs = [fixed_dofs (3*i-2) (3*i-1) (3*i)];
    end
end
free_dofs = [1:(3*number_of_nodes)];
free_dofs(fixed_dofs) = [];

u(free_dofs) = K_global(free_dofs, free_dofs)\F(free_dofs);

for i = 1:bar_count
    l1 = linspace(x_nodes(bars(i, 1)), x_nodes(bars(i, 2)), 100);
    l2 = linspace(y_nodes(bars(i, 1)), y_nodes(bars(i, 2)), 100);
    l3 = linspace(z_nodes(bars(i, 1)), z_nodes(bars(i, 2)), 100);
    plot3(l1, l2, l3);
    hold on
end
hold on
for i = 1:bar_count
    l1 = linspace(x_nodes(bars(i, 1)) + u(3*bars(i, 1) - 2), x_nodes(bars(i, 2)) + u(3*bars(i, 2) - 2), 100);
    l2 = linspace(y_nodes(bars(i, 1)) + u(3*bars(i, 1) - 1), y_nodes(bars(i, 2)) + u(3*bars(i, 2) - 1), 100);
    l3 = linspace(z_nodes(bars(i, 1)) + u(3*bars(i, 1)), y_nodes(bars(i, 2)) + u(3*bars(i, 2)), 100);
    plot3(l1, l2, l3, 'r-');
    hold on
end
