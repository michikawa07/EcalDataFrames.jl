using EvalDataFrames
using Documenter

DocMeta.setdocmeta!(EvalDataFrames, :DocTestSetup, :(using EvalDataFrames); recursive=true)

makedocs(;
    modules=[EvalDataFrames],
    authors="michikawa07 <michikawa.ryohei@gmail.com> and contributors",
    repo="https://github.com/michikawa07/EvalDataFrames.jl/blob/{commit}{path}#{line}",
    sitename="EvalDataFrames.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://michikawa07.github.io/EvalDataFrames.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/michikawa07/EvalDataFrames.jl",
    devbranch="main",
)
