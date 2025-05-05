# option

A safer alternative to null.

## usage

It's a pretty lightweight package.

### construction

You can create a new option via a few methods

```luau
-- none() creates the option as none
local character: Option<Model> = Option.none()

-- from() accepts a possibly null value, creating as some if not null
character = Option.from(player.Character)

-- some() will error if it receives a null value, but always creates the option as some
character = if player.Character then Option.some(player.Character) else Option.none()

-- try runs a function to get the value (use from if state is static)
character = Option.try(function(): Character?
    return player.Character
end)
```

### helper functions

The package interface has a few handy methods.

```luau
-- map() is also a class method, but this allows for type changing
local name: Option<string> = Option.map(character, function(char: Model)
    return char.Name
end)

-- isOption() checks if an unknown value is an option
assert(Option.isOption(name), `name is not an option`)

-- supports `osyrisrblx/t` standard runtime type refinement
local isAModelOption = Option.type(t.instanceIsA("Model"))
local success, message = isAModelOption(name) -- I know, `message = string?`, it's the standard - we can't dump null overnight
```

### methods

For checking the state of the option:

```luau
if name:isSome() then
    print("name is some!")
end

if name:isNone() then
    print("name is none!")
end

-- only runs when some, otherwise it's passed over
name:inspect(function(str)
    print(`name is "{str}"!`)
end)
```

For extracting the state of the option

```luau

-- if the option is none, the thread panics
local nameStr = name:unwrap()
nameStr = name:expect(`name is none()`) -- same as unwrap, but custom error message

-- both functions need to return the same type, used for flattening the option
nameStr = name:match(function(some)
    return name
end, function()
    return "Default Name"
end)

-- if you don't need to process the some() value, unwrapOr is a handy alternative
nameStr = name:unwrapOr("Default Name")

-- only calls the function if there's a none value - good for performance if getting the value is process heavy
nameStr = name:unwrapOrElse(function()
    return "Default Name"
end)

local maybeNameStr: string? = name:asNullable() -- most of the ecosystem uses null values, it's silly to pretend otherwise

-- constructs a new option with the return value of the callback
local lowerCaseName: Option<string> = name:map(function(some)
    return some:lower()
end)
```

## bloxidize

If you like this, check out my suite of rust inspired packages: [bloxidize](https://github.com/nightcycle/bloxidize)