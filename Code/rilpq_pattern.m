function [LPQcode,LPQ_nh] = rilpq_pattern(qinp)

%%%%Create the LPQ filters
Lpq_filt = init_lpqfilt; 

qinp = double(qinp);
[M,N] = size(qinp);
Nangle = size(Lpq_filt,3);             % Number of different oriented LPQ filters
Wsize = sqrt(size(Lpq_filt,2));          % Size of the window.,this is "enlarged" window size, which fits all rotated filters.
R = ceil((Wsize-1)/2);                   % Get radius from window size

% Characteristic orientation filters
Ch_Ori=charOrient(qinp); 

%%% Get characteristic orientations for the pixels that have full neighborhood
ch_ort = Ch_Ori((R+1):(end-R),(R+1):(end-R));
ch_ort=ch_ort(:)';

%%% Reformat image data to matrix containing neighborhoods as columns
F=zeros(Wsize^2,(M-Wsize+1)*(N-Wsize+1));
ii=1;
for i=1:1:Wsize
   for k=1:1:Wsize       
       d=qinp(i:(end-Wsize+i),k:(end-Wsize+k));
       F(ii,:)=d(:)';
       ii=ii+1;
   end
end

%%%Quantize rotations to the available filter angles (quantized angles must be in interval [0,2*pi])
Ang=0:(2*pi/Nangle):(2*pi-2*pi/Nangle);
[temp,rtqind]=min(abs(ch_ort(:)*ones(1,length(Ang)+1)-ones(length(ch_ort(:)),1)*[Ang,2*pi]),[],2);
rtqind(rtqind==(length(Ang)+1))=1;

%%%Compute LPQ response using oriented filters 
G=zeros(8,(M-Wsize+1)*(N-Wsize+1));
for i=1:Nangle
    ii = find(rtqind==i);
    G(:,ii) = Lpq_filt(:,:,i)*F(:,ii);
end

%%% Quantize values and form LPQ codewords
LPQcode = (G(1,:)>=0)+(G(2,:)>=0)*2+(G(3,:)>=0)*4+(G(4,:)>=0)*8+(G(5,:)>=0)*16+(G(6,:)>=0)*32+(G(7,:)>=0)*64+(G(8,:)>=0)*128;

LPQcode = uint8(LPQcode);
LPQcode = reshape(LPQcode,[(M-Wsize+1),(N-Wsize+1)]);

%%%%%Normalized LPQ histogram Features

LPQ_h = hist(LPQcode(:),0:255);
LPQ_nh = LPQ_h/sum(LPQ_h);

return;


