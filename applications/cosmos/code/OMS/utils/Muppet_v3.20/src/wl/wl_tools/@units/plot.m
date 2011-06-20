function plot(x,y)
x = units(x);
y = units(y);
plot(double(x),double(y))
xlabel([inputname(1) ' (' base(x) ')'])
ylabel([inputname(2) ' (' base(y) ')'])
