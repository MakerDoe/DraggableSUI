-- CustomEnum v1

export type EnumItem = {}

local strictIndex = function(_, key)
	error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(key)))
end

local strictNewIndex = function(_, key)
	error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)))
end

local _EnumValue = {
	__index = strictIndex,
	__newindex = strictNewIndex,

	__eq = function(self, other)
		return self.__value == other.__value and self.__id == other.__id
	end,

	__tostring = function(self)
		return self.__name
	end,
}

local _Items = {
	__index = strictIndex,
	__newindex = strictNewIndex,
}

local _Enum = {
	GetEnumItems = function(self)
		return self.__items
	end,

	__tostring = function(self)
		return self.__name
	end,

	__index = function(self, key)
		return self.__items[key]
	end,

	__newindex = strictNewIndex,
}

local CustomEnum = {}

function CustomEnum.new(list: { string }, name: string?): { EnumItem }
	if name then
		if not (typeof(name) == "string") then
			error("Second parameter must be a type of string")
		end
	end

	local newEnum = { __name = name or "Custom Enum" }
	local items = {}

	for index, key: string in ipairs(list) do
		items[key] = setmetatable({
			__id = math.floor(math.random() * os.clock()),
			__value = index - 1,
			__name = key,
		}, _EnumValue)
	end

	newEnum.__items = setmetatable(items, _Items)
	return setmetatable(newEnum, _Enum)
end

function CustomEnum.Is(obj: EnumItem): boolean
	return type(obj) == "table" and getmetatable(obj) == _EnumValue
end

return CustomEnum
