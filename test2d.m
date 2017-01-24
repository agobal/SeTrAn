%% Arash Gobal 
%
% The purpose of this program is to test a FEM model to analyze truss
% structures 

clear all
clc


%% 1. Defining node coordinates and bar arrangements

% Nodal coordinates
number_of_nodes = 20;
x_nodes = zeros(number_of_nodes, 1);
y_nodes = zeros(number_of_nodes, 1);

x_nodes = [1; 1; 2; 2; 3; 3; 4; 4; 5; 5; 6; 6; 7; 7; 8; 8; 9; 9; 10; 10];
y_nodes = [1; 2; 1; 2; 1; 2; 1; 2; 1; 2; 1; 2; 1; 2; 1; 2; 1; 2; 1; 2];

bar_count = 37;
bars = zeros(bar_count, 2);

bars(1, :) = [1 2]; bars(2, :) = [1 3]; bars(3, :) = [1 4]; bars(4, :) = [2 4];
bars(5, :) = [3 4]; bars(6, :) = [3 5]; bars(7, :) = [3 6]; bars(8, :) = [4 6];
bars(9, :) = [5 6]; bars(10, :) = [5 7]; bars(11, :) = [5 8]; bars(12, :) = [6 8];
bars(13, :) = [7 8]; bars(14, :) = [7 9]; bars(15, :) = [7 10]; bars(16, :) = [8 10];
bars(17, :) = [9 10]; bars(18, :) = [9 11]; bars(19, :) = [9 12]; bars(20, :) = [10 12];
bars(21, :) = [11 12]; bars(22, :) = [11 13]; bars(23, :) = [11 14]; bars(24, :) = [12 14];
bars(25, :) = [13 14]; bars(26, :) = [13 15]; bars(27, :) = [13 16]; bars(28, :) = [14 16];
bars(29, :) = [15 16]; bars(30, :) = [15 17]; bars(31, :) = [15 18]; bars(32, :) = [16 18];
bars(33, :) = [17 18]; bars(34, :) = [17 19]; bars(35, :) = [17 20]; bars(36, :) = [18 20];
bars(37, :) = [19 20];

bar_length = zeros(bar_count, 1);
bar_angle = zeros(bar_count, 2);
for i = 1:bar_count
    bar_length(i, 1) = sqrt( (x_nodes(bars(i, 1), 1) - x_nodes(bars(i, 2), 1))^2 + (y_nodes(bars(i, 1), 1) - y_nodes(bars(i, 2), 1))^2 );
    bar_angle(i, 1) = (x_nodes(bars(i, 2), 1) - x_nodes(bars(i, 1), 1))/bar_length(i, 1);
    bar_angle(i, 2) = (y_nodes(bars(i, 2), 1) - y_nodes(bars(i, 1), 1))/bar_length(i, 1);
end

%% Relationships for plane stress problem

E = 207000000000;  %modulus of elasticity
A = pi*0.05^2;

%% Assembly of the stiffness matrix
K_local = zeros(4, 4);
K_global = zeros(2*number_of_nodes, 2*number_of_nodes);

for i = 1:bar_count
    c = bar_angle(i, 1);
    s = bar_angle(i, 2);
    K_local = (A*E/bar_length(i, 1))*[c^2 c*s -c^2 -c*s;
                 c*s s^s -c*s -s^2;
                 -c^2 -c*s c^2 c*s;
                 -c*s -s^2 c*s s^2];
    
    a = bars(i, 1);
    b = bars(i, 2);
    K_global((2*(a - 1) + 1):2*a, (2*(b - 1) + 1):2*b) = K_global((2*(a - 1) + 1):2*a, (2*(b - 1) + 1):2*b) + K_local(1:2, 3:4);
    K_global((2*(a - 1) + 1):2*a, (2*(a - 1) + 1):2*a) = K_global((2*(a - 1) + 1):2*a, (2*(a - 1) + 1):2*a) + K_local(1:2, 1:2);
    K_global((2*(b - 1) + 1):2*b, (2*(a - 1) + 1):2*a) = K_global((2*(b - 1) + 1):2*b, (2*(a - 1) + 1):2*a) + K_local(3:4, 1:2);
    K_global((2*(b - 1) + 1):2*b, (2*(b - 1) + 1):2*b) = K_global((2*(b - 1) + 1):2*b, (2*(b - 1) + 1):2*b) + K_local(3:4, 3:4);
end

%% Solving the problem

F = zeros(2*number_of_nodes, 1);
u = zeros(2*number_of_nodes, 1);

% Choosing force nodes
force_nodes = [];
for i = 1:number_of_nodes
    if x_nodes(i, 1) == 10
        force_nodes = [force_nodes i];
    end
end

for i = 1:length(force_nodes)
    j = 2*(force_nodes(i) - 1);
    F(j, 1) = -10000000;
end

% Choosing the fixed nodes
fixed_nodes = [];
fixed_dofs = [];
for i = 1:number_of_nodes
    if x_nodes(i, 1) == 1
        fixed_nodes = [fixed_nodes i];
        fixed_dofs = [fixed_dofs (2*i-1) (2*i)];
    end
end
free_dofs = [1:(2*number_of_nodes)];
free_dofs(fixed_dofs) = [];

u(free_dofs) = K_global(free_dofs, free_dofs)\F(free_dofs);

for i = 1:bar_count
    l1 = linspace(x_nodes(bars(i, 1)), x_nodes(bars(i, 2)), 100);
    l2 = linspace(y_nodes(bars(i, 1)), y_nodes(bars(i, 2)), 100);
    plot(l1, l2);
    hold on
end
hold on
for i = 1:bar_count
    l1 = linspace(x_nodes(bars(i, 1)) + u(2*bars(i, 1) - 1), x_nodes(bars(i, 2)) + u(2*bars(i, 2) - 1), 100);
    l2 = linspace(y_nodes(bars(i, 1)) + u(2*bars(i, 1)), y_nodes(bars(i, 2)) + u(2*bars(i, 2)), 100);
    plot(l1, l2, 'r-');
    hold on
end
