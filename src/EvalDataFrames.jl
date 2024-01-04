module EvalDataFrames

using DataFrames

export eval!


"""
	eval!(df::DataFrame, syms::AbstractArray; parser=Meta.parse, mod=Main)
	eval!(df::DataFrame, syms::InvertedIndex; parser=Meta.parse, mod=Main)
	eval!(df::DataFrame, syms...            ; parser=Meta.parse, mod=Main)
	eval!(df::DataFrame                     ; parser=Meta.parse, mod=Main)

文字列を`parser`メソッドでパースし，`mod`モジュールの`eval`メソッドで評価します．
"""
function eval!(df::DataFrame, syms::AbstractArray; parser=Meta.parse, mod=Main)
	for sym in syms
		try
			df[!,sym] .= df[!, sym] .|> tryeval(parser, mod)
		catch err
			err isa Union{EltypeError, ParseError, EvalError} || throw(err)
			@warn "The colmun '$sym'(::$(eltype(df[!, sym]))) cannot be parse" err _file="line"
		end
	end
	return df
end
eval!(df::DataFrame, syms_inv::InvertedIndex; karg...) = eval!(df, propertynames(df[!,syms_inv]); karg...)
eval!(df::DataFrame, syms...                ; karg...) = eval!(df, collect(syms)                ; karg...)
eval!(df::DataFrame                         ; karg...) = eval!(df, propertynames(df)            ; karg...)
eval!(arg...; karg...) = df::DataFrame -> eval!(df, arg...; karg...)

"""
	tryeval(x, parser, mod)

各要素の評価を試みる
"""
tryeval(parser, mod) = x -> tryeval(x, parser, mod)
tryeval(x::AbstractString, parser, mod) = try parser(x)   catch e; throw(ParseError(x,e)) end |> tryeval(parser, mod) 
tryeval(x::Expr,           parser, mod) = try mod.eval(x) catch e; throw(EvalError(x,e)) end
tryeval(x::QuoteNode,      parser, mod) = try mod.eval(x) catch e; throw(EvalError(x,e)) end
tryeval(x::Number,         parser, mod) = x
tryeval( ::Missing,        parser, mod) = missing
tryeval( ::Nothing,        parser, mod) = nothing
tryeval( ::T,              parser, mod) where T = throw(EltypeError{T}())

struct EltypeError{T} <: Exception end
Base.showerror(io::IO, e::EltypeError{T}) where T =
    print(io, "EltypeError: `tryeval(x::$T, parser, mod)` is not defined");

struct ParseError <:Exception
	 x
	 e::Exception
end
Base.showerror(io::IO, e::ParseError) = begin
    println(io, "ParseError: Following error is occured parsing `$(e.x)`")
	 showerror(io, e.e)
end
struct EvalError <:Exception
	x
	e::Exception
end
Base.showerror(io::IO, e::EvalError) = begin
	println(io, "EvalError: Following error is occured evaluating `$(e.x)`")
	showerror(io, e.e)
end

end