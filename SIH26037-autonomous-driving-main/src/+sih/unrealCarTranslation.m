function translation=unrealCarTranslation(u)
% Map SIH +Y-left ground pose to Unreal/SAE +Y-right, Z-down coordinates.
u=u(:); translation=zeros(5,3);
translation(1,:)=[u(1),-u(2),0];
% The Sedan mesh already has wheel sockets. These rows are offsets from
% those default sockets, not axle locations in the mesh.
end
