--!strict
-- https://doc.rust-lang.org/std/option/enum.Option.html
-- Services
-- Packages
-- Modules
-- Types
type State = "S" | "N"
type OptionImpl<V> = {
	__index: OptionImpl<V>,
	__tostring: (self: Option<V>) -> string,
	isSome: (self: Option<V>) -> boolean,
	isNone: (self: Option<V>) -> boolean,
	inspect: (self: Option<V>, fn: (value: V) -> ()) -> (),
	match: <O>(self: Option<V>, some: (some: V) -> O, none: () -> O) -> O,
	--type swapping with map stuff is technically okay, but I can't get the type engine to recognize that
	map: (self: Option<V>, fn: (ok: V) -> V) -> Option<V>,
	mapOr: (self: Option<V>, mapFn: (ok: V) -> V, alt: V) -> Option<V>,
	mapOrElse: (self: Option<V>, mapFn: (ok: V) -> V, elseFn: () -> V) -> Option<V>,
	unwrap: (self: Option<V>) -> V,
	unwrapOr: (self: Option<V>, alt: V) -> V,
	unwrapOrElse: (self: Option<V>, fn: () -> V) -> V,
	expect: (self: Option<V>, msg: string) -> V,
}

export type Option<V> = typeof(setmetatable(
	{} :: {
		_state: string, --"N" | "S", --replaced for performance reasons
		_value: V?,
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

-- Constructors
local asNone = function<V>(): Option<V>
	local self: Option<V> = setmetatable({
		_state = STATE_NONE :: string,
		_value = nil,
	}, Option :: OptionImpl<any>)
	table.freeze(self)
	return self
end
local asSome = function<V>(some: V): Option<V>
	local self: Option<V> = setmetatable({
		_state = STATE_SOME :: string,
		_value = some,
	}, Option :: OptionImpl<any>)
	table.freeze(self)
	return self
end

function Option:__tostring()
	if self:isSome() then
		return "Some<" .. tostring(self._value) .. ">"
	end
	return "None"
end

function Option:isSome(): boolean
	return self._state == STATE_SOME
end

function Option:isNone(): boolean
	return self._state == STATE_NONE
end

function Option:inspect(fn: (value: unknown) -> ())
	if self:isSome() then
		fn(self._value)
	end
	return self
end

function Option:match<O>(some: (some: unknown) -> O, none: () -> O): O
	if self:isSome() then
		return some(self._value)
	else
		assert(self:isNone())
		return none()
	end
end

function Option:map(fn: (ok: unknown) -> unknown): Option<unknown>
	if self:isSome() then
		return asSome(fn(self._value))
	end
	return asNone()
end

function Option:mapOr(mapFn: (ok: unknown) -> unknown, alt: unknown): Option<unknown>
	if self:isSome() then
		return asSome(mapFn(self._value))
	end
	return asSome(alt)
end

function Option:mapOrElse(mapFn: (ok: unknown) -> unknown, elseFn: () -> unknown): Option<unknown>
	if self:isSome() then
		return asSome(mapFn(self._value))
	end
	return asSome(elseFn())
end

function Option:unwrap()
	if self:isSome() then
		return self._value
	end
	error("Option is none")
end

function Option:unwrapOr(alt: unknown): unknown
	if self:isSome() then
		return self._value
	end
	return alt
end

function Option:unwrapOrElse(fn: () -> unknown): unknown
	if self:isSome() then
		return self._value
	end
	return fn()
end

function Option:expect(msg: string)
	if self:isSome() then
		return self._value
	end
	error(msg)
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
