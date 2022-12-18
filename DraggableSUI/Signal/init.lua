-- Signal v1

local Types = require(script.Types)

local Signal = {}
Signal.__index = Signal
Signal.__tostring = function()
	return "Signal"
end

local Event = {}
Event.__index = Event
Event.__tostring = function()
	return "Event"
end

local Connection = {}
Connection.__index = Connection
Connection.__tostring = function()
	return "Connection"
end

local function ApplyStrictMethods(tbl: {})
	setmetatable(tbl, {
		__index = function(_, key)
			error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(key)), 2)
		end,

		__newindex = function(_, key)
			error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)), 2)
		end,
	})
end

function Signal.new()
	return setmetatable({
		_proxyHandler = nil,

		Event = Event.new(),
	}, Signal)
end

function Signal.Wrap(rbxScriptSignal: RBXScriptSignal): Types.Signal
	if not (typeof(rbxScriptSignal) == "RBXScriptSignal") then
		error("Argument #1 must be a RBXScriptSignal; got " .. typeof(rbxScriptSignal))
	end

	local signal = Signal.new()

	rawset(Signal, "_proxyHandler", rbxScriptSignal:Connect(function(...)
		signal:Fire(...)
	end))

	return signal
end

function Signal.Is(obj: Types.Signal): boolean
	return type(obj) == "table" and getmetatable(obj) == Signal
end

function Signal:Fire(...)
	local item = self.Event._handlerListHead

	while item do
		if item.Connected then
			coroutine.wrap(item._func)(...)
		end

		item = item._next
	end
end

function Signal:GetConnections(): { Types.SignalConnection }
	local items = {}
	local item = self.Event._handlerListHead

	while item do
		table.insert(items, item)
		item = item._next
	end

	return items
end

function Signal:DisconnectAll()
	local event = self.Event
	local item = event._handlerListHead

	while item do
		item.Connected = false
		item = item._next
	end

	event._handlerListHead = false
end

function Signal:Destroy()
	self:DisconnectAll()

	local proxyHandler = rawget(self, "_proxyHandler")

	if proxyHandler then
		proxyHandler:Disconnect()
	end
end

function Event.new()
	return setmetatable({
		_handlerListHead = false,
	}, Event)
end

function Event:Connect(func: (...any) -> ()): Types.SignalConnection
	local connection = Connection.new(self, func)

	if self._handlerListHead then
		connection._next = self._handlerListHead
		self._handlerListHead = connection
	else
		self._handlerListHead = connection
	end

	return connection
end

function Event:Once(func: (...any) -> ()): Types.SignalConnection
	local connection: Types.SignalConnection
	local done = false

	connection = self:Connect(function(...)
		if done then
			return
		end

		done = true
		connection:Disconnect()
		func(...)
	end)

	return connection
end

function Event:Wait(): ...any
	local waitingCoroutine = coroutine.running()
	local done = false

	local connection: Types.SignalConnection

	connection = self:Connect(function(...)
		if done then
			return
		end

		done = true
		connection:Disconnect()
		task.spawn(waitingCoroutine, ...)
	end)

	return coroutine.yield()()
end

function Connection.new(event: Types.Event, func: (...any) -> ())
	return setmetatable({
		Connected = true,
		_event = event,
		_func = func,
		_next = false,
	}, Connection)
end

function Connection:Disconnect()
	if not self.Connected then
		return
	end

	local event = self._event
	self.Connected = false

	if event._handlerListHead == self then
		event._handlerListHead = self._next
	else
		local prev = event._handlerListHead

		while prev and not (prev._next == self) do
			prev = prev._next
		end

		if prev then
			prev._next = self._next
		end
	end
end

ApplyStrictMethods(Connection)
ApplyStrictMethods(Signal)
ApplyStrictMethods(Event)

return Signal :: {
	Wrap: (rbxScriptSignal: RBXScriptSignal) -> Types.Signal,
	Is: (obj: Types.Signal) -> boolean,
	new: () -> Types.Signal,
}
