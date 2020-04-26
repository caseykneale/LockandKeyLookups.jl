using LockandKeyLookups
using Test, DataFrames

@testset "LockandKeyLookups.jl" begin
    # examples...
    endrng = 10
    a = DataFrame( Dict( :a => 1:1:endrng, :b => 1:1:endrng ) )
    b = DataFrame( Dict( :b => 1:5:endrng, :c => 1:5:endrng ) )
    c = DataFrame( Dict( :b => 6:7:endrng, :c => 6:7:endrng ) )
    d = DataFrame( Dict( :b => 6:7:endrng, :c => 6:7:endrng ) )

    # LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b, c, d ] ), X -> X.a, X -> X.b ) ]
    for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b, c, d ] ), X -> X.a, X -> X.b )
        println(i)
    end
    #k,(t,r)
    #println(LKL_result)
    # @test all( LKL_result .== [ 1 => ( 1, 1 ) , 6 => ( 1, 2 ), 6 => ( 2, 1 ), 6 => ( 3, 1 ) ] )

    # function proposed(a::DataFrame, b::DataFrame, c::DataFrame, d::DataFrame)
    #     return [i for i in LockandKeyLookup( eachrow(a), eachrow.([b, c, d]), X -> X.a, X -> X.b ) ]
    # end
    # @benchmark proposed(a, b, c, d)
    #
    # #alternative
    # function alternative(a::DataFrame, b::DataFrame, c::DataFrame, d::DataFrame)::DataFrame
    #     bc = sort( vcat( b, c, d ), :b )
    #     x = join(a, bc, on = :b, kind = :left)
    #     return x
    # end
    # @benchmark alternative(a, b, c, d )

end
