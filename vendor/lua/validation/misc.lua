local validation   = require "validation"
local lh           = require "lhutil"
local base64       = require "base64"
local re           = require "re"
local escapeuri    = lh.encodeURI
local unescapeuri  = lh.decodeURI
local base64enc    = base64.encode
local base64dec    = base64.decode
local match        = re.match
local validators   = validation.validators
local factory      = getmetatable(validators)
function factory.escapeuri()
    return function(value)
        return true, escapeuri(value)
    end
end
function factory.unescapeuri()
    return function(value)
        return true, unescapeuri(value)
    end
end
function factory.base64enc()
    return function(value)
        return true, base64enc(value)
    end
end
function factory.base64dec()
    return function(value)
        local decoded = base64dec(value)
        if decoded == nil then
            return false
        end
        return true, decoded
    end
end
function factory.regex(regex, options)
    return function(value)
        return (match(value, regex, options)) ~= nil
    end
end
validators.escapeuri   = factory.escapeuri()
validators.unescapeuri = factory.unescapeuri()
validators.base64enc   = factory.base64enc()
validators.base64dec   = factory.base64dec()
return {
    escapeuri   = validators.escapeuri,
    unescapeuri = validators.unescapeuri,
    base64enc   = validators.base64enc,
    base64dec   = validators.base64dec,
    md5         = validators.md5,
    regex       = factory.regex
}
