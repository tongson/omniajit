local validation   = require "validation"
local lh           = require "lhutil"
local base64       = require "base64"
local re           = require "re"
local ammonia      = require "ammonia"
local blake3       = require "blake3"
local escapeuri    = lh.encodeURI
local unescapeuri  = lh.decodeURI
local htmlentities = ammonia.clean_text
local base64enc    = base64.encode
local base64dec    = base64.decode
local hash         = blake3.hash
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
function factory.htmlentities()
    return function(value)
        return true, htmlentities(value)
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
function factory.hash(bin)
  return function(value)
    local digest = bin and hash(value)
    return true, digest
  end
end
validators.escapeuri   = factory.escapeuri()
validators.unescapeuri = factory.unescapeuri()
validators.htmlentities = factory.htmlentities()
validators.base64enc   = factory.base64enc()
validators.base64dec   = factory.base64dec()
validators.hash        = factory.hash()
return {
    escapeuri   = validators.escapeuri,
    unescapeuri = validators.unescapeuri,
    htmlentities= validators.htmlentities,
    base64enc   = validators.base64enc,
    base64dec   = validators.base64dec,
    hash        = validators.hash,
    regex       = factory.regex
}
