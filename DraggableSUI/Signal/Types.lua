export type Event = {
	Connect: (self: Event, func: (...any) -> ()) -> SignalConnection,
	Once: (self: Event, func: (...any) -> ()) -> SignalConnection,
	Wait: (self: Event) -> ...any,
}

export type SignalConnection = {
	Disconnect: (self: SignalConnection) -> (),
}

export type Signal = {
	GetConnections: (self: Signal) -> (),
	DisconnectAll: (self: Signal) -> (),
	Fire: (self: Signal, ...any) -> (),
	Destroy: (self: Signal) -> (),

	Event: Event,
}

return 0
