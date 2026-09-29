function out=vdbWorldDerivative(u)
% SAE vehicle frame: +Y right, positive yaw right. Project into SIH +Y left.
u=u(:);
vx=u(1); vyRight=u(2); psiRight=u(3);
out=[vx*cos(psiRight)-vyRight*sin(psiRight); ...
    -vx*sin(psiRight)-vyRight*cos(psiRight)];
end
