clear all
close all
L=2*pi;
DT=.5;
NT=200;NTOUT=25;
NG=32;
N=10000;
WP=1;
QM=-1;
V0=0.2;
VT=0.04;
XP1=1;
V1=0.01;
mode=1;
Q=WP.^2/(QM*N/L);
rho_back=-Q*N/L;
dx=L/NG;
% initial loading for the 2 Stream instability
xp=linspace(0,L-L/N,N)';
vp=VT*randn(N,1);
xp=xp+XP1*(L/N)*sin(2*pi*xp/L*mode);
vp(1:2:N-1)=random('normal',V0,VT,[N/2 1]);
vp(2:2:N)=random('normal',-V0,VT,[N/2 1]);
vp=vp+V1*sin(2*pi*xp/L*mode); % add sin variations
%
p=1:N;p=[p p];
un=ones(NG-1,1);
Poisson=spdiags([un -2*un un],[-1 0 1],NG-1,NG-1);
% Main computational cycle
for it=1:NT
% update xp
xp=xp+vp*DT;
% apply bc on the particle positions
out=(xp<0); xp(out)=xp(out)+L;
out=(xp>=L);xp(out)=xp(out)-L;
% projection p->g
g1=floor(xp/dx-.5)+1;g=[g1;g1+1];
fraz1=1-abs(xp/dx-g1+.5);fraz=[fraz1;1-fraz1];
% apply bc on the projection
out=(g<1);g(out)=g(out)+NG;
out=(g>NG);g(out)=g(out)-NG;
mat=sparse(p,g,fraz,N,NG);
rho=full((Q/dx)*sum(mat))'+rho_back;
% computing fields
Phi=Poisson\(-rho(1:NG-1)*dx^2);Phi=[Phi;0];
Eg=([Phi(NG); Phi(1:NG-1)]-[Phi(2:NG);Phi(1)])/(2*dx);
% projection q->p and update of vp
vp=vp+mat*QM*Eg*DT;

% plot(xp,vp,'*')
subplot(1,2,1)
plot(xp(1:2:N-1),vp(1:2:N-1),'b.');hold on
plot(xp(2:2:N),vp(2:2:N),'r.');hold off
xlim([0 pi*2])
ylim([-0.6 0.6])

subplot(1,2,2)
histogram(vp,50)
xlim([-0.6 0.6])
pause(0.1)
end

%%
plot(xp(1:N/2),vp(1:N/2),'b*');hold on
plot(xp(N/2+1:N),vp(N/2+1:N),'r*');hold off

