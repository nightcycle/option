--!strict
-- Services
-- Packages
-- Modules
-- Types
type State = "S" | "N"
type OptionImpl<V> = {
	__index: OptionImpl<V>,
	isSome: (self: Option<V>) -> boolean,
	isNone: (self: Option<V>) -> boolean,
	onSome: (self: Option<V>, fn: (value: V) -> ()) -> (),
	onNone: (self: Option<V>, fn: () -> ()) -> (),
	match: <O>(self: Option<V>, some: (some: V) -> O, none: () -> O) -> O,
	unwrap: (self: Option<V>) -> V,
	expect: (self: Option<V>, msg: string) -> V,
}
export type Option<V> = typeof(setmetatable(
	{} :: {
		_state: "N",
		_value: nil,
	} | {
		_state: "S",
		_value: V,
	},
	{} :: OptionImpl<V>
))

-- Constants
local STATE_SOME: "S" = "S"
local STATE_NONE: "N" = "N"
-- Variables
-- References
-- Private Functions
-- Class
local Option = {} :: OptionImpl<unknown>
Option.__index = Option

function Option:isSome(): boolean
	return self._state == STATE_SOME
end

function Option:isNone(): boolean
	return self._state == STATE_NONE
end

function Option:onSome(fn: (value: unknown) -> ())
	if self:isSome() then
		fn(self._value)
	end
end

function Option:onNone(fn: () -> ())
	if self:isNone() then
		fn()
	end
end

function Option:match<O>(some: (some: unknown) -> O, none: () -> O): O
	if self:isSome() then
		return some(self._value)
	else
		assert(self:isNone())
		return none()
	end
end

function Option:unwrap()
	if self:isSome() then
		return self._value
	end
	error("Option is none")
end

function Option:expect(msg: string)
	if self:isSome() then
		return self._value
	end
	error(msg)
end

local asNone = function<V>(): Option<V>
	local self: Option<V> = setmetatable({
		_state = STATE_NONE,
		_value = nil,
	}, Option :: OptionImpl<any>)
	table.freeze(self)
	return self
end
local asSome = function<V>(some: V): Option<V>
	local self: Option<V> = setmetatable({
		_state = STATE_SOME,
		_value = some,
	}, Option :: OptionImpl<any>)
	table.freeze(self)
	return self
end

return {
	none = asNone,
	some = asSome,
	try = function<V>(fn: () -> V?): Option<V>
		local out = fn()
		if typeof(out) == "nil" then
			return asNone()
		else
			return asSome(out)
		end
	end,
}
