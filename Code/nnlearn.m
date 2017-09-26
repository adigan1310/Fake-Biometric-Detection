function nnlearn

Nclass = 2;
Nuser = 5;
Nsamples = 5;
Tx = {'Original','Fake'};
Ind = 1;

for Nc=1:1:Nclass
    Dname = strcat('C_',int2str(Nc));
    H = msgbox(['Extracting Features from ',Tx{Nc},' Samples']);
    pause(1.5);
    close(H);
    Ldr = waitbar(0,'Pleasewait....');
    for Nu=1:1:Nuser
        ufile = strcat('u',int2str(Nu),'_');
        for Ns = 1:1:Nsamples
            Ifile = strcat(ufile,int2str(Ns),'.bmp');
            cd Rsamples
            cd(Dname)
            Inp = imread(Ifile);
            cd ..
            cd ..        
            qinp = imresize(Inp,[256,256]);

            if size(qinp,3)>1
               qinp = rgb2gray(qinp); 
            end

            Nneigh = 8;
            R = 1; K = 3;
            Nbins =  factorial(Nneigh)./( factorial(K)* factorial(Nneigh-K)); 

            Limage = ldpattern(qinp,R);

            Lhist = hist(Limage(:),Nbins);
            nLhist = Lhist./sum(Lhist);

            %%%%DRLBP based texture analysis
            %%%%%Define Radius, Neighbourhood size
            Nneigh = 8;
            r = 1;
            B = 8;
            drlbpmap = drlbp_mapping(Nneigh);        %%%%%%%Generate Mapping Table for Uniform LBP Code

            L = 2*r + 1; 
            C = round(L/2);
            Nbins = 2.^B;

            Cinp = padarray(double(qinp),[1 1],'symmetric','both');  %%%%%Add Pads to an Image to process border pixels

            max_row = size(Cinp,1)-L+1;
            max_col = size(Cinp,2)-L+1;

            lbpout = zeros(max_row, max_col);        %%%%%%Det LBP Code

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

            [Ix,Iy] = gradient(double(qinp),1,1);   %%%%Find the Gradient Magnitude to weigh LBP Code 
            Gm = sqrt(abs(Ix).^2+abs(Iy).^2);

            for ii=1:1:Nbins
                Delt = zeros(size(Gm));
                Delt(lbpout==(ii-1)) = 1;
                hlbp(ii) = sum(sum(Gm.*Delt));  
            end

            for ii=1:1:2^(B-1)                            %%%%%Find Histogram of RLBP and Difference LBP
                hrlbp(ii) = hlbp(ii)+hlbp((2^B)-1-ii);
                hdlbp(ii) = abs(hlbp(ii)-hlbp((2^B)-1-ii));
            end

            for jj=1:1:Nbins                    %%%%Find DRLBP Histogram by concatenating RLBP and DLBP
                if (jj<=2^(B-1))
                    hdrlbp(jj) = hrlbp(jj);
                else
                    hdrlbp(jj) = hdlbp(jj-2^(B-1));
                end
            end

            mbins = drlbpmap.Mbins;            %%%%Mapping 256 bins DRLBP Histogram to 60 bins DRLBP Histogram
            drmap = drlbpmap.map_table;

            for k=1:1:mbins
                bcor = find(drmap==k-1);
                drlbp_h(k) = sum(hdrlbp(bcor));
            end

            drlbp_nh = drlbp_h./sum(drlbp_h);     %%%%%%Normalized DRLBP Histogram

            [LPQcode,LPQ_nh] = rilpq_pattern(qinp);    %%%%%Rotation Invariant Local Phase quantization Codes and its histogram

            Dtemp = [nLhist(:);drlbp_nh(:);LPQ_nh(:)];

            Fcharacs(:,Ind) = Dtemp;
            Ind = Ind+1;
        end
        waitbar(Nu/Nuser,Ldr);
    end
    close(Ldr);
end

nan_val= isnan(Fcharacs);
Fcharacs(find(nan_val== 1)) = 0;

save Fcharacs Fcharacs;

%%%%%Assigning target values to each class of features
Ts = Nuser*Nsamples; T =1;
Nc = Ts;

for ti=1:1:size(Fcharacs,2)
   
    if Nc<1
        T= T+1;
        Nc= Ts-1;
    else
       Nc= Nc-1; 
    end
    deval(:,ti) = T;

end

%%%%%%Probabilistic Neural network with RBF Creation and training
vdeval = ind2vec(deval);

netp = newpnn(Fcharacs,vdeval);

save netp netp;

H = msgbox('Training Completed','Msg: ');
pause(1.5);
close(H);

       
        