#!/usr/bin/env python3

import numpy as np
import sys

if len(sys.argv) != 2:
    raise(ValueError("Require a pqr file (coords and radii) as input."))
inFile = sys.argv[1]

def vanMeelNeighbourhood( ats, rCut=10. ):
  
    N = len(ats)    
    deltas = [np.array([-1, 0, 0],dtype=int),\
              np.array([ 0,-1, 0],dtype=int),\
              np.array([ 0, 0,-1],dtype=int),\
              np.array([ 1, 0, 0],dtype=int),\
              np.array([ 0, 1, 0],dtype=int),\
              np.array([ 0, 0, 1],dtype=int),\
              np.array([ 0,-1,-1],dtype=int),\
              np.array([-1, 0,-1],dtype=int),\
              np.array([-1,-1, 0],dtype=int),\
              np.array([ 0, 1, 1],dtype=int),\
              np.array([ 1, 0, 1],dtype=int),\
              np.array([ 1, 1, 0],dtype=int),\
              np.array([ 0,-1, 1],dtype=int),\
              np.array([-1, 0, 1],dtype=int),\
              np.array([-1, 1, 0],dtype=int),\
              np.array([ 0, 1,-1],dtype=int),\
              np.array([ 1, 0,-1],dtype=int),\
              np.array([ 1,-1, 0],dtype=int),\
              np.array([-1, 1, 1],dtype=int),\
              np.array([ 1,-1, 1],dtype=int),\
              np.array([-1,-1, 1],dtype=int),\
              np.array([ 1, 1,-1],dtype=int),\
              np.array([-1, 1,-1],dtype=int),\
              np.array([ 1,-1,-1],dtype=int),\
              np.array([-1,-1,-1],dtype=int),\
              np.array([ 1, 1, 1],dtype=int),\
             ]

    ##build a neighbour system for linear-scaling type stuff.
    cells   = {}
    i_cells = np.floor(ats[:,:3]/rCut).astype(int)
    for i in range(N):
         key = "%i_%i_%i" % (i_cells[i,0],i_cells[i,1],i_cells[i,2])
         if key in cells:
            cells[key].append(i)
         else:
            cells[key] = [i]

    nebs = [[] for i in range(N)]
    dist = [[] for i in range(N)]
    vanMeelNebs = np.zeros((N), dtype=np.int)
    vanMeelRad  = np.zeros((N))
    for i in range(N):
        key = "%i_%i_%i" % (i_cells[i,0],i_cells[i,1],i_cells[i,2])
        for j in cells[key]:
            if j == i:
                 continue
            else:
                 r = np.linalg.norm(ats[i]-ats[j])
                 dist[i].append(r)
                 nebs[i].append(j)
     
        for delt in deltas:
            key = "%i_%i_%i" %\
      (i_cells[i,0]+delt[0],i_cells[i,1]+delt[1],i_cells[i,2]+delt[2])
            if key in cells:
                for j in cells[key]:
                   r = np.linalg.norm(ats[i]-ats[j])
                   dist[i].append(r)
                   nebs[i].append(j)

        ##sort the neb list
        dist[i]  = np.array(dist[i])
        index    = np.argsort(dist[i])
        dist[i]  = dist[i][index]
        nebs[i]  = np.array(nebs[i])[index]

        ##Van Meel Algorithm (van Meel and Frenkel 2012)
        m     = 3
        while m < len(dist[i])-1:
           Rim = np.sum(dist[i][:m])/(m-2.)
           if Rim <= dist[i][m]:
               vanMeelNebs[i] = m
               vanMeelRad[i]  = Rim
               break
           else:
               m+=1
 
    return vanMeelNebs, vanMeelRad



f = open(inFile, "r")
ats = []
for line in f:
#    x = line[30:38]
#    print("read x: .%s." % x)
#    x = float(x)
#    y = float(line[38:46])
#    z = float(line[46:54])
#    r = float(line[46:54])
     ##PQR are whitespace separated:
     L = line.split()
     if L[0] == "ATOM":
        atdat = np.array([float(L[5]),float(L[6]),float(L[7]),float(L[9])])
        ats.append(atdat)
ats       = np.array(ats)
nebs, rad = vanMeelNeighbourhood(ats)

np.savetxt("vanMeel.dat", np.vstack((\
                                     ats.transpose(),\
                                     nebs.transpose(),\
                                     rad.transpose() )).transpose() )

atVol = (4./3) * np.pi * np.sum(ats[:,3]**3) 

print("summed atomic volumes %f , see vanMeel.dat for van Meel neb info." % atVol)
