local block = require('radio.core.block')
local types = require('radio.types')

local SubtractBlock = block.factory("SubtractBlock")

function SubtractBlock:instantiate()
    self:add_type_signature({block.Input("in1", types.ComplexFloat32Type), block.Input("in2", types.ComplexFloat32Type)}, {block.Output("out", types.ComplexFloat32Type)})
    self:add_type_signature({block.Input("in1", types.Float32Type), block.Input("in2", types.Float32Type)}, {block.Output("out", types.Float32Type)})
    self:add_type_signature({block.Input("in1", types.Integer32Type), block.Input("in2", types.Integer32Type)}, {block.Output("out", types.Integer32Type)})
end

function SubtractBlock:initialize()
    self.data_type = self.signature.inputs[1].data_type
end

function SubtractBlock:process(x, y)
    local out = self.data_type.vector(x.length)
    for i = 0, x.length-1 do
        out.data[i] = x.data[i] - y.data[i]
    end
    return out
end

return {SubtractBlock = SubtractBlock}