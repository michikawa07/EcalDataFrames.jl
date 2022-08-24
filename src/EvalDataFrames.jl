module EvalDataFrames

using DataFrames

"""
	Unitfulパッケージによって提供される単位付き数値を
	DataFrame+CSVで保存・読み込みすることを念頭に作成したもの
	DataFrameの指定したカラムの文字列をjuliaの構文で評価する．
"""
function eval!(df::DataFrame, syms::AbstractArray)
	for sym in syms
		type=eltype(df[!, sym])
		type .<: AbstractString || continue
		try
			df[!,sym] = df[!, sym] .|> Meta.parse .|> eval
		catch error;
			type <: AbstractString && @warn "following string in the colmun '$sym' cannot be parse" error _file="line"
			type <: AbstractString || @warn "the colmun '$sym' cannot be parse, because the type is $type" _file="line"
		end
	end
	df
end
eval!(df::DataFrame, syms_inv::InvertedIndex) = eval!(df, propertynames(df[!,syms_inv]))
eval!(df::DataFrame, syms...) = begin
	isempty(syms) && eval!(df, propertynames(df))
	eval!(df, collect(syms))
end

end
