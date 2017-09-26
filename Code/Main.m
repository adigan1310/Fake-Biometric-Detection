close all;
clear all;
clc;

cd Inputs
file = uigetfile('*.*','Pick an Image File');
qinp = imread(file);
cd ..

qinp = imresize(qinp,[256,256]);      

if size(qinp,3)>1
   qinp = rgb2gray(qinp); 
end

figure('Name','Input Image','MenuBar','none');
imshow(qinp);

%LDP%
Nneigh = 8;
R = 1; K = 3;
Nbins =  factorial(Nneigh)./( factorial(K)* factorial(Nneigh-K)); 

Limage = ldpattern(qinp,R);

Lhist = hist(Limage(:),Nbins);
nLhist = Lhist./sum(Lhist);

figure('Name','LDP Code','MenuBar','None');
imshow(Limage,[]);

figure('Name','LDP Histogram','MenuBar','None');
bar(nLhist,0.5);

%DRLBP%
Nneigh = 8;
r = 1;
B = 8;
drlbpmap = drlbp_mapping(Nneigh);        

L = 2*r + 1; 
C = round(L/2);
Nbins = 2.^B;

Cinp = padarray(double(qinp),[1 1],'symmetric','both');  

max_row = size(Cinp,1)-L+1;
max_col = size(Cinp,2)-L+1;

lbpout = zeros(max_row, max_col);      

for i = 1:max_row
    for j = 1:max_col
        A = Cinp(i:i+L-1, j:j+L-1);
        cA= Cinp(i:i+L-1, j:j+L-1);
        dA = A-A(C,C);
        dA(dA>=0) = 1;
        dA(dA<0)  = 0;
        lbpout(i,j) = dA(1,1) + dA(1,C)*2 + dA(1,L)*4 + dA(C,L)*8 + dA(L,L)*16 + dA(L,C)*32 + dA(L,1)*64 + dA(C,1)*128;
    end
end

[Ix,Iy] = gradient(double(qinp),1,1);    
Gm = sqrt(abs(Ix).^2+abs(Iy).^2);

for ii=1:1:Nbins
    Delt = zeros(size(Gm));
    Delt(lbpout==(ii-1)) = 1;
    hlbp(ii) = sum(sum(Gm.*Delt));  
end

for ii=1:1:2^(B-1)                           
    hrlbp(ii) = hlbp(ii)+hlbp((2^B)-1-ii);
    hdlbp(ii) = abs(hlbp(ii)-hlbp((2^B)-1-ii));
end

for jj=1:1:Nbins                    
    if (jj<=2^(B-1))
        hdrlbp(jj) = hrlbp(jj);
    else
        hdrlbp(jj) = hdlbp(jj-2^(B-1));
    end
end

mbins = drlbpmap.Mbins;           
drmap = drlbpmap.map_table;

for k=1:1:mbins
    bcor = find(drmap==k-1);
    drlbp_h(k) = sum(hdrlbp(bcor));
end

drlbp_nh = drlbp_h./sum(drlbp_h);     

figure('Name','LBP Code','MenuBar','none');
imshow(lbpout,[]);

figure('Name','DRLBP Histogram','MenuBar','none');
bar(drlbp_nh,0.5);

%RILPQ%
[LPQcode,LPQ_nh] = rilpq_pattern(qinp);         

figure('Name','LPQ Code','MenuBar','none');
imshow(LPQcode,[]);

figure('Name','RILPQ Histogram','MenuBar','none');
bar(LPQ_nh,0.5);

%PNN%
Ifeat = [nLhist(:);drlbp_nh(:);LPQ_nh(:)];        

load netp;

Cout = sim(netp,Ifeat);
Cout = vec2ind(Cout);

if isequal(Cout,1)
    
    msgbox('FingerPrint is Original');
    
elseif isequal(Cout,2)
    
    msgbox('FingerPrint is Fake'); 
    
else
  
    msgbox('!!!-Retrain system with Updated Samples-!!!');
   
end


