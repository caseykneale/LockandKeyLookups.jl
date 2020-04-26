using LockandKeyLookups
using Test, DataFrames

@testset "LockandKeyLookups - iterations" begin
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
    a = DataFrame( Dict( :a => 1:2:endrng, :b => 1:2:endrng ) )
    b = DataFrame( Dict( :b => 1:1:endrng, :c => 1:1:endrng ) )
    #Test sparse key stream!
    LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b ] ), X -> X.a, X -> X.b ) ]
    @test all( LKL_result .== [ 1 => ( 1, 1 ) , 2 => ( 1, 3 ), 3 => ( 1, 5 ) ] )

    c = DataFrame( Dict( :b => 1:2:endrng, :c => 1:2:endrng ) )
    #Test sparse key stream with 2 pins!
    LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b, c ] ), X -> X.a, X -> X.b ) ]
    @test all( LKL_result .== [ 1 => ( 1, 1 ), 1 => ( 2, 1 ), 2 => ( 1, 3 ), 2 => ( 2, 2 ), 3 => ( 1, 5 ), 3 => ( 2, 3 ) ] )

    b = DataFrame( Dict( :b => 2:2:endrng, :c => 2:2:endrng ) )
    #Test sparse key stream with NO matches!
    LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b ] ), X -> X.a, X -> X.b ) ]
    @test isempty( LKL_result )

    c = DataFrame( Dict( :b => 2:2:20, :c => 2:2:20 ) )
    #Test sparse key stream with 2 streams that have NO matches!
    LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b, c ] ), X -> X.a, X -> X.b ) ]
    @test isempty( LKL_result )

    a = DataFrame( Dict( :a => 101:2:111, :b => 101:2:111 ) )
    b = DataFrame( Dict( :b => 20:1:25, :c => 20:1:25 ) )
    c = DataFrame( Dict( :b => 107:1:115, :c => 107:1:115 ) )
    #Sparse stream some matching some not
    LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b,c ] ), X -> X.a, X -> X.c ) ]
    @test all( LKL_result .== [ 4 => ( 2, 1 ) , 5 => ( 2, 3 ), 6 => ( 2, 5 ) ] )
end

@testset "LockandKeyLookups - Arbitrary functions" begin
    a = DataFrame( Dict( :a => 7:1:11, :b => 7:1:11 ) )
    b = DataFrame( Dict( :b => 1:1:22, :c => 1:1:22 ) )

    #test changing a value
    LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b ] ), X -> X.a,
                        X -> X.b/2.0 ) ]
    @test all( LKL_result .== [ 1 => ( 1, 14 ) , 2 => ( 1, 16 ), 3 => ( 1, 18 ), 4 => ( 1, 20 ), 5 => ( 1, 22 ) ] )

    #test changing a comparator but not really
    LKL_result = [ i for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b ] ), X -> X.a,
                        X -> X.b / 2.0, (k, t) -> (1.0 .* k) == (t ./ 1.0) ) ]
    println(LKL_result)
    @test all( LKL_result .== [ 1 => ( 1, 14 ) , 2 => ( 1, 16 ), 3 => ( 1, 18 ), 4 => ( 1, 20 ), 5 => ( 1, 22 ) ] )

end
#DEVELOPERS: Useful snippit for debugging
# for i in LockandKeyLookup( eachrow( a ), eachrow.( [ b ] ), X -> X.a, X -> X.b )
#      println( i )
#      println(b[i[2][2],:b])
# end
