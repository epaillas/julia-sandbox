using CellListMap
using StaticArrays
using LinearAlgebra
using PyCall
using DelimitedFiles


function count_pairs!(i, counts)
    counts[i] += 1
    return counts
end 

function compute_filtered_density(data, box_size, rmax)
    data = convert(Array{Float64}, data)
    positions = [data[i, :] for i in 1:size(data, 1)]
    npos = size(positions)[1]
    Lbox = [box_size, box_size, box_size]
    box = Box(Lbox, rmax)

    cl = CellList(positions, box)
    DD = zeros(Int, npos);

    map_pairwise!(
        (x, y, i, j, d2, output) ->
        count_pairs!(i, DD),
        DD, box, cl,
        parallel=true
    )

    bin_volume = 4 / 3 * pi * rmax^3 
    mean_density = npos / (box_size^3) 
    
    delta = DD / (bin_volume * mean_density) .- 1

    return delta
end 

