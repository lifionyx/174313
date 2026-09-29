function stop=vdbGoalReached(u)
% Benchmark-only early termination at the exact existing goal criterion.
u=u(:);
stop=double(u(1)>=u(3)-1 && abs(u(2))<1.5);
end
