function world=egoToWorld(ego,local)
R=[cos(ego(3)) -sin(ego(3));sin(ego(3)) cos(ego(3))];
world=(ego(1:2)'+R*local(:))';
end
