using CellListMap
using StaticArrays
using LinearAlgebra
using PyCall
using DelimitedFiles


function count_pairs!(i, j, counts)
    counts[i] += 1
    counts[j] += 1
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
        (x, y, i, j, d2, DD) ->
        count_pairs!(i, j, DD),
        DD, box, cl,
        parallel=true
    )

    bin_volume = 4 / 3 * pi * rmax^3 
    mean_density = npos / (box_size^3) 
    
    delta = DD / (bin_volume * mean_density) .- 1

    return delta
end 

print(string("I'm using ", Threads.nthreads(), " threads."))

np = pyimport("numpy")

# process data
data = np.genfromtxt("test_data/R101_S15.csv",
    skip_header=1, delimiter=",", usecols=(0, 1, 2)
)
box_size = 2000
rmax = 50

# compute density PDF using Julia module
delta = compute_filtered_density(data, box_size, rmax)
