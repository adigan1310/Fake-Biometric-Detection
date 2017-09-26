function Eout = Edirect(Ein)

%%%%Initialize Edge Response mask using Kirsch templates
M0 = [-3 -3 5;-3 0 5;-3 -3 5];
M1 = [-3 5 5;-3 0 5;-3 -3 -3];
M2 = [5 5 5;-3 0 -3;-3 -3 -3];
M3 = [5 5 -3;5 0 -3;-3 -3 -3];
M4 = [5 -3 -3;5 0 -3;5 -3 -3];
M5 = [-3 -3 -3;5 0 -3;5 5 -3];
M6 = [-3 -3 -3;-3 0 -3;5 5 5];
M7 = [-3 -3 -3;-3 0 5;-3 5 5];

%%%%Edge Directional Response
m0 = abs(sum(sum(Ein.*M0)));
m1 = abs(sum(sum(Ein.*M1)));
m2 = abs(sum(sum(Ein.*M2)));
m3 = abs(sum(sum(Ein.*M3)));
m4 = abs(sum(sum(Ein.*M4)));
m5 = abs(sum(sum(Ein.*M5)));
m6 = abs(sum(sum(Ein.*M6)));
m7 = abs(sum(sum(Ein.*M7)));

Eout = [m3 m2 m1;m4 0 m0;m5 m6 m7];

return;