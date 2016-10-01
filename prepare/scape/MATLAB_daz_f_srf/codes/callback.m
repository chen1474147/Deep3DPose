function callback(hObj,event,isShape,idx) %#ok<INUSL>
    % Called to set zlim of surface in figure axes
    % when user moves the slider control
    %val = 51 - get(hObj,'Value');
    %zlim(ax,[-val val]);
    val = get(hObj, 'Value');
    global handle shapeParam poseParam body texts
    if(isShape)
        shapeParam(idx) = val;
        body = Body(poseParam, shapeParam);
        set(handle,'Vertices', body.points);
        set(texts{idx}, 'String', num2str(val));
    end
    
end