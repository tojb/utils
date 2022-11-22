#!/usr/bin/env python2
from __future__ import division
 
def simpson(f, a, b, n):
    """Approximates the definite integral of f from a to b by
    the composite Simpson's rule, using n subintervals"""
    h = 1.0
    s = f[a] + f[b]
 
    for i in range(1, n, 2):
        s += 4.0 * f[a + i]
    for i in range(2, n-1, 2):
        s += 2.0 * f[a + i]
 
    return s / 3.0
 


#print simpson(lambda x:x**9, 0.0, 10.0, 100000)
# displays 1000000000.0

#######Execution starts here

f=open('./eps_N_2500_0.741.dat', 'r')


count=0
eps=[]
dph=[]
while True:
    x=f.readline()
    x=x.rstrip()
    if x is None: break
  
    asList=x.split(" ");
    if len(asList) == 2:  	
    	eps.append(float(asList[0])) 
    	dph.append(float(asList[1]))
    	count     = count + 1
    else:
	break


print str(eps)+" "+str(dph)
print simpson(dph, 0, count-1, count-1)/count


