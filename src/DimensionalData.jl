module DimensionalData

# Use the README as the module docs
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end DimensionalData

using Base.Broadcast:
    Broadcasted, BroadcastStyle, DefaultArrayStyle, AbstractArrayStyle, Unknown

using ConstructionBase, LinearAlgebra, RecipesBase, Statistics, Dates

using Base: tail, OneTo


export Dimension, IndependentDim, DependentDim, XDim, YDim, ZDim, TimeDim

export Dim, X, Y, Z, Ti

export Selector, Between, At, Contains, Near

export Locus, Center, Start, End, UnknownLocus, NoLocus

export Order, Ordered, Unordered, UnknownOrder, AutoOrder

export Sampling, PointSampling, IntervalSampling

export Span, RegularSpan, IrregularSpan, UnknownSpan

export Grid, UnknownGrid

export AbstractCategoricalGrid, CategoricalGrid

export AlignedGrid, AbstractSampledGrid, SampledGrid

export UnalignedGrid, TransformedGrid

export AbstractDimensionalArray, DimensionalArray

export data, dims, refdims, metadata, name, shortname,
       val, label, units, order, bounds, locus, grid, <|

export dimnum, hasdim, setdim, swapdims

export @dim


include("interface.jl")
include("grid.jl")
include("dimension.jl")
include("array.jl")
include("selector.jl")
include("broadcast.jl")
include("methods.jl")
include("primitives.jl")
include("utils.jl")
include("plotrecipes.jl")
include("prettyprint.jl")

end
