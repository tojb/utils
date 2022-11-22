#!/usr/bin/env python3

"""
Take an xyz file (or aims geometry)
plus three further command line arguments,
and stitch together a contiguous cluster of atoms
such that there are no big gaps between neighbours.
"""

import numpy as np
import sys

inXYZfile=sys.argv[1]

box_x = float(sys.argv[2])
box_y = float(sys.argv[3])
box_z = float(sys.argv[4])

box  = np.array( [box_x, box_y, box_z] )
hbox = 0.5 * box

#print("# %s  " % inXYZfile, box)
f    = open(inXYZfile, "r")
at_crds  = []
for line in f:
    L = line.split()
    if len(L) == 5 and L[0] == "atom":
        x = float(L[1])
        y = float(L[2])
        z = float(L[3])
        at_crds.append( [x, y, z] )
f.close()
at_crds = np.array(at_crds)

##loop over coordinates, keeping next one 
##imaged to be close to COM of previous ones.
##this is ropy, but works because solute is usually first in the file.
at_imaged = np.copy(at_crds)
com       = at_imaged[0,:]
for i_at in range(1,len(at_crds)):
   dx = at_imaged[i_at,:] - com
   for d in range(3):
       while dx[d] >  hbox[d]:
           print("d ", dx[d], hbox[d])
           dx[d]        -= box[d]
           at_imaged[d] -= box[d]
       while dx[d] < -hbox[d]:
           dx[d]        += box[d]
           at_imaged[d] += box[d]
           
   ##running average centre of mass.
   com *= i_at / (i_at + 1)
   com += at_imaged[i_at,:] / (i_at + 1)
           

f    = open(inXYZfile, "r")
at_crds  = []
i_at     = 0
for line in f:
    L = line.split()
    if len(L) == 5 and L[0] == "atom":
        x = at_imaged[i_at,0]
        y = at_imaged[i_at,1]
        z = at_imaged[i_at,2]
        print("atom %.6f %.6f %.6f %s" %\
                (x,y,z,L[4]))
    else:
        print(line, end="")
f.close()
at_crds = np.array(at_crds)

           
           
           
           
   




        



