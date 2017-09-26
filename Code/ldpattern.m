function ldpout = ldpattern(inp,r)
L = 2*r + 1; 
C = round(L/2);
Cinp = double(inp);

max_row = size(Cinp,1)-L+1;
max_col = size(Cinp,2)-L+1;

ldpout = zeros(max_row, max_col);

for i = 1:max_row
    for j = 1:max_col
        A = Cinp(i:i+L-1, j:j+L-1);
        Ed = Edirect(A);
        Bpos = Ed-Ed(1,1);
        Bpos(Bpos>=0) = 1;
        Bpos(Bpos<0)  = 0;
        ldpout(i,j) = Bpos(L,L)*2.^7 + Bpos(L,C)*2.^6 + Bpos(L,1)*2.^5 + Bpos(C,1)*2.^4 + Bpos(1,1)*2.^3 + Bpos(1,C)*2.^2 + Bpos(1,L)*2.^1 + Bpos(C,L)*2.^0;
    end
end

return;
