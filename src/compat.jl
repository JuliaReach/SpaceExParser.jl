using Compat
using Compat: @warn

@static if VERSION >= v"0.7"
    const _parse_s = Base.Meta.parse
    const _parse_t = Base.parse
else
    const _parse_s = parse
    const _parse_t = parse
end
