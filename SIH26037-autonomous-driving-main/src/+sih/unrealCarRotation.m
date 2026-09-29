function rotation=unrealCarRotation(u)
% Vehicle Dynamics Blockset and Unreal both use SAE positive-right yaw.
u=u(:); rotation=zeros(5,3);
rotation(1,3)=u(1);
rotation(2:3,3)=u(2);
end
