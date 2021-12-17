from julia.api import Julia
import numpy as np
import matplotlib.pyplot as plt

# import Julia modules
jl = Julia(compiled_modules=False)
from julia import Main
jl.eval('include("filtered_density.jl")')

# read simulation data
data = np.genfromtxt("test_data/R101_S15.csv",
    skip_header=1, delimiter=",", usecols=(0, 1, 2)
)
box_size = 2000
rmax = 20

# add this so that Julia can recognize these varaibles
Main.data = data
Main.box_size = box_size
Main.rmax = rmax

# compute density PDF using Julia module
delta = jl.eval("compute_filtered_density(data, box_size, rmax)")

# plot the results
fig, ax = plt.subplots(figsize=(4.5, 4.5))
ax.hist(delta, bins=50, density=True)

ax.set_xlabel(r'$\Delta(R = 20\, h^{-1}{\rm Mpc})$', fontsize=15)
ax.set_ylabel('PDF', fontsize=15)

plt.tight_layout()
plt.savefig('density_PDF.png')

