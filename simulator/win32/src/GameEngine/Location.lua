local Location = Struct('Location')

function Location:Init(x, y, z)
    Property(self,
        Prop('x', x),
        Prop('y', y),
        Prop('z', z)
    )
end

return Location