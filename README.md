# EvalDataFrames [![Build Status](https://github.com/michikawa07/EvalDataFrames.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/michikawa07/EvalDataFrames.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://michikawa07.github.io/EvalDataFrames.jl/stable/) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://michikawa07.github.io/EvalDataFrames.jl/dev/) [![Build Status](https://travis-ci.com/michikawa07/EvalDataFrames.jl.svg?branch=main)](https://travis-ci.com/michikawa07/EvalDataFrames.jl)


Unitfulパッケージによって提供される単位付き数値をDataFrame+CSVで保存後に読み込みすることを念頭に作成した.

DataFrameの指定したカラムの文字列をjuliaの構文で評価する．

# Quick Start

```julia
julia> using EvalDataFrames

julia> df = DataFrame(A = ["1+2","sqrt(2)"])
2×1 DataFrame
 Row │ A       
     │ String  
─────┼─────────
   1 │ 1+2
   2 │ sqrt(2)

julia> df |> eval!
2×1 DataFrame
 Row │ A       
     │ Real    
─────┼─────────
   1 │ 3
   2 │ 1.41421
```

```julia
julia> df = DataFrame(
			A = ["1+2", "1(N/s*kg^2)"],
			B = [:(1+2), :(1u"N")],
			C = ["1+2", "1u\"N\""],
			D = ["[1+2][1]", "[sqrt(1m)]"],
       )
2×4 DataFrame
 Row │ A            B         C       D
     │ String       Expr      String  String     
─────┼───────────────────────────────────────────
   1 │ 1+2          1 + 2     1+2     [1+2][1]
   2 │ 1(N/s*kg^2)  1 * u"N"  1u"N"   [sqrt(1m)]

julia> eval!(df,:A, parser=uparse)
2×4 DataFrame
 Row │ A            B         C       D
     │ Number       Expr      String  String     
─────┼───────────────────────────────────────────
   1 │           3  1 + 2     1+2     [1+2][1]
   2 │ 1 kg² N s⁻¹  1 * u"N"  1u"N"   [sqrt(1m)]

julia> eval!(df,:B, :C)
2×4 DataFrame
 Row │ A            B       C       D
     │ Number       Number  Number  String     
─────┼─────────────────────────────────────────
   1 │           3       3       3  [1+2][1]
   2 │ 1 kg² N s⁻¹     1 N     1 N  [sqrt(1m)]	
```