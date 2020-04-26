using LockandKeyLookups
using Test, DataFrames

@testset "LockandKeyLookups.jl" begin
    # examples...
    endrng = 3
    a = DataFrame( Dict( :a => 1:1:endrng, :b => 1:1:endrng ) )
    b = DataFrame( Dict( :b => 1:1:endrng, :c => 1:1:endrng ) )
    #Test single stream complete match
    LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b ] ), X -> X.a, X -> X.b ) ]
    @test all( LKL_result .== [ 1 => ( 1, 1 ) , 2 => ( 1, 2 ), 3 => ( 1, 3 ) ] )
    #Test two streams complete match
    c = DataFrame( Dict( :b => 1:1:endrng, :c => 1:1:endrng ) )
    LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b, c ] ), X -> X.a, X -> X.b ) ]
    @test all( LKL_result .== [ 1 => ( 1, 1 ), 1 => ( 2, 1 ), 2 => ( 1, 2 ), 2 => ( 2, 2 ), 3 => ( 1, 3 ), 3 => ( 2, 3 ) ] )
    #Test 3 streams with heterogeniety of matches
    endrng = 10
    a = DataFrame( Dict( :a => 1:1:endrng, :b => 1:1:endrng ) )
    b = DataFrame( Dict( :b => 1:5:endrng, :c => 1:5:endrng ) )
    c = DataFrame( Dict( :b => 6:7:endrng, :c => 6:7:endrng ) )
    d = DataFrame( Dict( :b => 6:7:endrng, :c => 6:7:endrng ) )
    LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b, c, d ] ), X -> X.a, X -> X.b ) ]
    @test all( LKL_result .== [ 1 => ( 1, 1 ) , 6 => ( 1, 2 ), 6 => ( 2, 1 ), 6 => ( 3, 1 ) ] )

    endrng = 5
    println("=====TEST GOAL=====")
    a = DataFrame( Dict( :a => 1:2:endrng, :b => 1:2:endrng ) )
    b = DataFrame( Dict( :b => 1:1:endrng, :c => 1:1:endrng ) )
    # #Test sparse key stream!
    LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b ] ), X -> X.a, X -> X.b ) ]
    @test all( LKL_result .== [ 1 => ( 1, 1 ) , 2 => ( 1, 3 ), 3 => ( 1, 5 ) ] )

    # for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b ] ), X -> X.a, X -> X.b )
    #      println( i )
    #      println(b[i[2][2],:b])
    #  end

end

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
