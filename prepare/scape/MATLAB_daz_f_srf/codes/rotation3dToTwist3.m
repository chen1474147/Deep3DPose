function res = rotation3dToTwist3( m )
    c = (m(1,1,:)+m(2,2,:)+m(3,3,:)-1) / 2;
    t = acos(c);
    v = bsxfun(@rdivide, [m(3,2,:)-m(2,3,:); m(1,3,:)-m(3,1,:); m(2,1,:)-m(1,2,:)],(2*sin(t)));
    v(~isfinite(v)) = 0;
    res = bsxfun(@times, v, t);
end