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
	parse_skipmissing(x) = ismissing(x) ? x : parser(x)
	StringMissing = Union{Missing, AbstractString}
	ExprMissing   = Union{Missing, Expr}
	for sym in syms
		T = eltype(df[!, sym])
		try
			T <: StringMissing && @. df[!,sym] = df[!, sym] |> parse_skipmissing |> mod.eval
			T <: ExprMissing   && @. df[!,sym] = df[!, sym] |> mod.eval
			T <: Union{StringMissing, ExprMissing} || @warn "the colmun '$sym' (type $T) cannot be parse" _file="line"
		catch e
			T <: StringMissing && @warn "following string in the colmun '$sym' cannot be parse" e _file="line"
			T <: StringMissing || @warn "the colmun '$sym' cannot be parse, because the type is $T" e _file="line"
		end
	end
	df
end
eval!(df::DataFrame, syms_inv::InvertedIndex; karg...) = eval!(df, propertynames(df[!,syms_inv]); karg...)
eval!(df::DataFrame, syms...                ; karg...) = eval!(df, collect(syms)                ; karg...)
eval!(df::DataFrame                         ; karg...) = eval!(df, propertynames(df)            ; karg...)
eval!(arg...; karg...) = df::DataFrame -> eval!(df, arg...; karg...)

end