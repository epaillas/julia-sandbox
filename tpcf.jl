using CellListMap
using StaticArrays
using LinearAlgebra

function _count_pairs_r!(d2, rbins, counts)
    d = sqrt.(d2)
    ibin = searchsortedfirst(rbins, d) - 1
    if ibin > 0
        counts[ibin] += 1
    end
    return counts
end 


function count_pairs_r(
    positions1, positions2, box_size, rbins
)
    print(Threads.nthreads())
    positions1 = convert(Array{Float64}, positions1)
    positions2 = convert(Array{Float64}, positions2)
    rbins = convert(Array{Float64}, rbins)
    D1D2 = zeros(Int, length(rbins) - 1)
    
    rmax = maximum(rbins)
    Lbox = [box_size, box_size, box_size]
    box = Box(Lbox, rmax)

    cl = CellList(positions1, positions2, box)

    D1D2 = map_pairwise!(
        (x, y, i, j, d2, output) ->
        _count_pairs_r!(d2, rbins, D1D2),
        D1D2, box, cl,
        parallel=true,
        reduce=reduce
    )

    return D1D2
end

