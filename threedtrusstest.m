%% Simple 3d truss for test
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