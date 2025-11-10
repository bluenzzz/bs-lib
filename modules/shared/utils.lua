Lib.Utils = {}

if IsDuplicityVersion() then

else
    Lib.Utils.parsePart = function(key)
        if (type(key) == 'string' and string.sub(key, 1, 1) == 'p') then
            return true, tonumber(string.sub(key, 2))
        else
            return false, tonumber(key)
        end
    end

    Lib.Utils.toFloat = function(number)
        number = ((not number) and 0.0 or tonumber(number))
        return (number + 0.0)
    end
end