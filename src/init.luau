--!strict
-- https://doc.rust-lang.org/std/option/enum.Option.html
-- Services
-- Packages
-- Modules
-- Types
type State = "S" | "N"
type OptionImpl<V> = {
	__index: OptionImpl<V>,
	__tostring: (self: any) -> string,
	__eq: (self: any, other: Option<V>) -> boolean,
	isSome: (self: any) -> boolean,
	isNone: (self: any) -> boolean,
	inspect: (self: any, fn: (value: V) -> ()) -> (),
	match: <O>(self: any, some: (some: V) -> O, none: () -> O) -> O,
	--type swapping with map stuff is technically okay, but I can't get the type engine to recognize that
	map: (self: any, fn: (some: V) -> V) -> Option<V>,
	mapOr: (self: any, mapFn: (some: V) -> V, alt: V) -> Option<V>,
	mapOrElse: (self: any, mapFn: (some: V) -> V, elseFn: () -> V) -> Option<V>,
	unwrap: (self: any) -> V,
	unwrapOr: (self: any, alt: V) -> V,
	unwrapOrElse: (self: any, fn: () -> V) -> V,
	asNullable: (self: any) -> V?,
	expect: (self: any, msg: string) -> V,
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
	local self: any = setmetatable({
		_state = STATE_NONE :: string,
		_value = nil,
	}, Option :: OptionImpl<any>)
	table.freeze(self)
	return self
end
local asSome = function<V>(some: V): Option<V>
	assert(typeof(some) ~= "nil", "some() value cannot be nil")
	local self: any = setmetatable({
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

function Option:__eq(other: Option<unknown>): boolean
	if self:isSome() and other:isSome() then
		return self._value == other._value
	end
	return self:isNone() and other:isNone()
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

function Option:map(fn: (some: unknown) -> unknown): Option<unknown>
	if self:isSome() then
		return asSome(fn(self._value))
	end
	return asNone()
end

function Option:mapOr(mapFn: (some: unknown) -> unknown, alt: unknown): Option<unknown>
	if self:isSome() then
		return asSome(mapFn(self._value))
	end
	return asSome(alt)
end

function Option:mapOrElse(mapFn: (some: unknown) -> unknown, elseFn: () -> unknown): Option<unknown>
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

-- deprecated, don't use
do
	local opt: any = Option
	function opt:unpack()
		return self:asNullable()
	end
end

-- new quality of life method for interfacing with non-option based systems
function Option:asNullable()
	if self:isSome() then
		return self._value
	end
	return nil
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
	isOption = function(value: unknown?): boolean
		if typeof(value) == "table" then
			return getmetatable(value :: any) == Option
		end
		return false
	end,
	try = function<V>(fn: () -> V?): Option<V>
		local out = fn()
		if typeof(out) == "nil" then
			return asNone()
		else
			return asSome(out)
		end
	end,
	from = function<V>(v: V?): Option<V>
		if typeof(v) == "nil" then
			return asNone()
		else
			return asSome(v)
		end
	end,
}
