"""
Return the content size of an object as needed in [`storage_signature`](@ref).

# Examples
```jldoctest
julia> contentsize("foo")
3
```
"""
contentsize(obj::String) = length(obj)


"""
Print `DateTime` in RFC 1123 format as required by the REST interface.

The RFC 1123 expects to have "GMT" (aka UTC) at the end of the string,
cf. <https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings>.
However, the Dates package does not include the timezone by default.
"""
http_date(dt::Dates.DateTime) = Dates.format(dt, RFC1123_GMT)


"""
Generate signature for Azure storage.
"""
function storage_signature(; url::String, verb::String,
                         storageaccount::String, storagekey,
                         container::String, timestamp::String,
                         headers::String = "", CMD::String = "",
                         contentsize::String = "", 
                         contenttype::String = "")

	# TODO: Rename to storage_signature?
	# TODO: verb must be "GET" or "PUT"
	# TODO: timestamp must be valid
    time_arg = string("x-ms-date:", timestamp, "\nx-ms-version:", X_MS_VERSION)
    if length(headers) > 0
        time_arg = string(headers, "\n", time_arg)
    end

    location_arg = string("/", storageaccount, "/", container, CMD)

    signature = string(verb, "\n\n\n", contentsize, "\n\n", contenttype, 
                       "\n\n\n\n\n\n\n", time_arg, "\n", location_arg)

    # TODO: Check that storagekey is UTF8 encoded
	encode_storagekey(storagekey, signature)
end


"""
	encode_storagekey(storagekey, signature)

Encode the storage key using a signature string from [`storage_signature`](@ref).
"""
function encode_storagekey(storagekey, signature)
	@pipe storagekey |>
		Base64.base64decode |>
		Nettle.digest("sha256", _, signature) |>
		Base64.base64encode
end
