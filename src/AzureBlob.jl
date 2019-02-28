module AzureBlob

import Base64
import Dates
import HTTP
import Nettle
import TimeZones

using Pipe

export 
    storage_signature,
    get_blob,
    put_blob

const X_MS_VERSION = "2017-04-17"

# Dates.RFC1123Format with " GMT" in the end
const RFC1123_GMT = Dates.DateFormat("e, dd u yyyy HH:MM:SS G\\MT")

const UTC = TimeZones.tz"UTC"
const LOCALZONE = try
		TimeZones.localzone()
	catch
		UTC
	end

include("rest.jl")
include("signature.jl")

end # module
