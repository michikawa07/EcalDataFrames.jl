module EvalDataFrames

using DataFrames

export eval!

"""
	eval!(df::DataFrame, syms::AbstractArray; parser=Meta.parse, mod=Main)

Unitfulパッケージによって提供される単位付き数値を
DataFrame+CSVで保存・読み込みすることを念頭に作成したもの
DataFrameの指定したカラムの文字列をjuliaの構文で評価する．
"""
function eval!(df::DataFrame, syms::AbstractArray; parser=Meta.parse, mod=Main)
	for sym in syms
		type=eltype(df[!, sym])
		try
			type <: AbstractString && (df[!,sym] = df[!, sym] .|> parser .|> mod.eval)
			type <: Expr && (df[!,sym] = df[!, sym] .|> mod.eval)
		catch error;
			type <: AbstractString && @warn "following string in the colmun '$sym' cannot be parse" error _file="line"
			type <: AbstractString || @warn "the colmun '$sym' cannot be parse, because the type is $type" _file="line"
		end
	end
	df
end
eval!(df::DataFrame, syms_inv::InvertedIndex; karg...) = eval!(df, propertynames(df[!,syms_inv]); karg...)
eval!(df::DataFrame, syms...; karg...) = eval!(df, collect(syms); karg...)
eval!(df::DataFrame; karg...) = eval!(df, propertynames(df); karg...)

end