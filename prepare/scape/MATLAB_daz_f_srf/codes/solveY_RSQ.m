function Y = solveY_RSQ( R, S, Q )
T = mtimesx(mtimesx(R(:,:,Meta.instance.t2bone), S, 'SPEED'), Q, 'SPEED');
Y = solveY(T);
end
