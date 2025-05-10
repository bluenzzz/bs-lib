Lib.KeyMapping = {}

Lib.KeyMapping.Register = function(command, data, cb)
    RegisterCommand(command, cb)
    
    RegisterKeyMapping(command, data.description, data.mapper, data.parameter)
end