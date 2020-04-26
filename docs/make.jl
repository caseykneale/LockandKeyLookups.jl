using Documenter, LockandKeyLookups

makedocs(;
    modules=[LockandKeyLookups],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/caseykneale/LockandKeyLookups.jl/blob/{commit}{path}#L{line}",
    sitename="LockandKeyLookups.jl",
    authors="Casey Kneale",
    assets=String[],
)

deploydocs(;
    repo="github.com/caseykneale/LockandKeyLookups.jl",
)
