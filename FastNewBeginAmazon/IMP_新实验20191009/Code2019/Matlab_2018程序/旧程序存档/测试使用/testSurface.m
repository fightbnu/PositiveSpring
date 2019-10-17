% Create a grid of x and y points
points = linspace(0, 1, 101);
[X, Y] = meshgrid(points, points);

% Define the function Z = f(X,Y)
%Z = 2./exp((X-.5).^2+Y.^2)-2./exp((X+.5).^2+Y.^2);
Z=X.^2+Y.^2;
% Create the surface plot using the surf command
figure
surf(X, Y, Z)