using DimensionalData, Test

using DimensionalData: val, basetypeof, slicedims, dims2indices, formatdims, grid,
      @dim, reducedims, XDim, YDim, ZDim, Forward

dimz = (X(), Y())

@testset "permutedims" begin
    @test permutedims((Y(1:2), X(1)), dimz) == (X(1), Y(1:2))
    @test permutedims((X(1),), dimz) == (X(1), nothing)
    @test permutedims((Y(), X()), dimz) == (X(:), Y(:))
    @test permutedims([Y(), X()], dimz) == (X(:), Y(:))
    @test permutedims((Y, X),     dimz) == (X, Y)
    @test permutedims([Y, X],     dimz) == (X, Y)
    @test permutedims(dimz, (Y(), X())) == (Y(:), X(:))
    @test permutedims(dimz, [Y(), X()]) == (Y(:), X(:))
    @test permutedims(dimz, (Y, X)    ) == (Y(:), X(:))
    @test permutedims(dimz, [Y, X]    ) == (Y(:), X(:))
end

a = [1 2 3; 4 5 6]
da = DimensionalArray(a, (X((143, 145)), Y((-38, -36))))
dimz = dims(da)

@testset "slicedims" begin
    @test slicedims(dimz, (1:2, 3)) == 
        ((X(LinRange(143,145,2), SampledGrid(span=RegularSpan(2.0)), nothing),),
         (Y(-36.0, SampledGrid(span=RegularSpan(1.0)), nothing),))
    @test slicedims(dimz, (2:2, :)) == 
        ((X(LinRange(145,145,1), SampledGrid(span=RegularSpan(2.0)), nothing), 
          Y(LinRange(-38.0,-36.0, 3), SampledGrid(span=RegularSpan(1.0)), nothing)), ())
    @test slicedims((), (1:2, 3)) == ((), ())
end

@testset "dims2indices" begin
    emptyval = Colon()
    @test dims2indices(grid(dimz[1]), dimz[1], Y, Nothing) == Colon()
    @test dims2indices(dimz, (Y(),), emptyval) == (Colon(), Colon())
    @test dims2indices(dimz, (Y(1),), emptyval) == (Colon(), 1)
    # Time is just ignored if it's not in dims. Should this be an error?
    @test dims2indices(dimz, (Ti(4), X(2))) == (2, Colon())
    @test dims2indices(dimz, (Y(2), X(3:7)), emptyval) == (3:7, 2)
    @test dims2indices(dimz, (X(2), Y([1, 3, 4])), emptyval) == (2, [1, 3, 4])
    @test dims2indices(da, (X(2), Y([1, 3, 4])), emptyval) == (2, [1, 3, 4])
    emptyval=()
    @test dims2indices(dimz, (Y,), emptyval) == ((), Colon())
    @test dims2indices(dimz, (Y, X), emptyval) == (Colon(), Colon())
    @test dims2indices(da, X, emptyval) == (Colon(), ())
    @test dims2indices(da, (1:3, [1, 2, 3]), emptyval) == (1:3, [1, 2, 3])
    @test dims2indices(da, 1, emptyval) == (1, )
end

@testset "dims2indices with transformed grid" begin
    tdimz = Dim{:trans1}(nothing; grid=TransformedGrid(X())), 
            Dim{:trans2}(nothing, grid=TransformedGrid(Y())), 
            Ti(1:1)
    @test dims2indices(tdimz, (X(1), Y(2), Ti())) == (1, 2, Colon())
    @test dims2indices(tdimz, (Dim{:trans1}(1), Dim{:trans2}(2), Ti())) == (1, 2, Colon())
end

@testset "dimnum" begin
    @test dimnum(da, X) == 1
    @test dimnum(da, Y()) == 2
    @test dimnum(da, (Y, X())) == (2, 1)
    @test_throws ArgumentError dimnum(da, Ti) == (2, 1)
end

@testset "reducedims" begin
    @test reducedims((X(3:4; grid=SampledGrid(;span=RegularSpan(1))), 
                      Y(1:5; grid=SampledGrid(;span=RegularSpan(1)))), (X, Y)) == 
                     (X([4], SampledGrid(;span=RegularSpan(2)), nothing), 
                      Y([3], SampledGrid(;span=RegularSpan(5)), nothing))
    @test reducedims((X(3:4; grid=SampledGrid(Ordered(), RegularSpan(1), IntervalSampling(Start()))), 
                      Y(1:5; grid=SampledGrid(Ordered(), RegularSpan(1), IntervalSampling(End())))), (X, Y)) ==
        (X([3], SampledGrid(Ordered(), RegularSpan(2), IntervalSampling(Start())), nothing), 
         Y([5], SampledGrid(Ordered(), RegularSpan(5), IntervalSampling(End())), nothing))

    @test reducedims((X(3:4; grid=SampledGrid(sampling=IntervalSampling(Center()), span=IrregularSpan(2.5, 4.5), )),
                      Y(1:5; grid=SampledGrid(sampling=IntervalSampling(Center()), span=IrregularSpan(0.5, 5.5), ))), (X, Y))[1] ==
                     (X([4], SampledGrid(sampling=IntervalSampling(Center()), span=IrregularSpan(2.5, 4.5)), nothing),
                      Y([3], SampledGrid(sampling=IntervalSampling(Center()), span=IrregularSpan(0.5, 5.5)), nothing))[1]
    @test reducedims((X(3:4; grid=SampledGrid(sampling=IntervalSampling(Start()), span=IrregularSpan(3, 5))),
                      Y(1:5; grid=SampledGrid(sampling=IntervalSampling(End()  ), span=IrregularSpan(0, 5)))), (X, Y))[1] ==
                     (X([3], SampledGrid(sampling=IntervalSampling(Start()), span=IrregularSpan(3, 5)), nothing),
                      Y([5], SampledGrid(sampling=IntervalSampling(End()  ), span=IrregularSpan(0, 5)), nothing))[1]

    @test reducedims((X(3:4; grid=SampledGrid(sampling=PointSampling(), span=IrregularSpan())), 
                      Y(1:5; grid=SampledGrid(sampling=PointSampling(), span=IrregularSpan()))), (X, Y)) ==
        (X([4], SampledGrid(span=IrregularSpan()), nothing), 
         Y([3], SampledGrid(span=IrregularSpan()), nothing))
    @test reducedims((X(3:4; grid=SampledGrid(sampling=PointSampling(), span=RegularSpan(1))), 
                      Y(1:5; grid=SampledGrid(sampling=PointSampling(), span=RegularSpan(1)))), (X, Y)) ==
        (X([4], SampledGrid(span=RegularSpan(2)), nothing), 
         Y([3], SampledGrid(span=RegularSpan(5)), nothing))

    @test reducedims((X([:a,:b]; grid=CategoricalGrid()), 
                      Y(["1","2","3","4","5"]; grid=CategoricalGrid())), (X, Y)) ==
                     (X([:combined]; grid=CategoricalGrid()), 
                      Y(["combined"]; grid=CategoricalGrid()))
end

@testset "dims" begin
    @test dims(da, X) isa X
    @test dims(da, (X, Y)) isa Tuple{<:X,<:Y}
    @test dims(dims(da), Y) isa Y
    @test dims(dims(da), 1) isa X
    @test dims(dims(da), (2, 1)) isa Tuple{<:Y,<:X}
    @test dims(dims(da), (2, Y)) isa Tuple{<:Y,<:Y}
    @test dims(da, ()) == ()
    @test_throws ArgumentError dims(da, Ti)
    x = dims(da, X)
    @test dims(x) == x
end

@testset "hasdim" begin
    @test hasdim(da, X) == true
    @test hasdim(da, Ti) == false
    @test hasdim(dims(da), Y) == true
    @test hasdim(dims(da), (X, Y)) == (true, true)
    @test hasdim(dims(da), (X, Ti)) == (true, false)
    # Abstract
    @test hasdim(dims(da), (XDim, YDim)) == (true, true)
    # TODO : should this actually be (true, false) ?
    # Do we remove the second one for hasdim as well?
    @test hasdim(dims(da), (XDim, XDim)) == (true, true)
    @test hasdim(dims(da), (ZDim, YDim)) == (false, true)
    @test hasdim(dims(da), (ZDim, ZDim)) == (false, false)
end

@testset "setdim" begin
    A = setdim(da, X(LinRange(150,152,2)))
    @test val(dims(dims(A), X())) == LinRange(150,152,2)
end

@testset "swapdims" begin
    @testset "swap type wrappers" begin
        A = swapdims(da, (Z, Dim{:test1}))
        @test dims(A) isa Tuple{<:Z,<:Dim{:test1}}
        @test map(val, dims(A)) == map(val, dims(da))
        @test map(grid, dims(A)) == map(grid, dims(da))
    end
    @testset "swap whole dim instances" begin
        A = swapdims(da, (Z(2:2:4), Dim{:test2}(3:5)))
        @test dims(A) isa Tuple{<:Z,<:Dim{:test2}}
        @test map(val, dims(A)) == (2:2:4, 3:5)
        @test map(grid, dims(A)) == 
            (SampledGrid(span=RegularSpan(2)), 
             SampledGrid(span=RegularSpan(1)))
    end
    @testset "passing `nothing` keeps the original dim" begin
        A = swapdims(da, (Z(2:2:4), nothing))
        dims(A) isa Tuple{<:Z,<:Y}
        @test map(val, dims(A)) == (2:2:4, val(dims(da, 2)))
        A = swapdims(da, (nothing, Dim{:test3}))
        @test dims(A) isa Tuple{<:X,<:Dim{:test3}}
    end
    @testset "new instances are checked against the array" begin
        @test_throws DimensionMismatch swapdims(da, (Z(2:2:4), Dim{:test4}(3:6)))
    end
end

