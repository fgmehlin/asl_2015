import numpy as np
import matplotlib.pyplot as plt



def main():

    y1 = 7276
    y2 = 8091
    y3 = 7751
    y4 = 9023




    a = np.array([[1,-1,-1,1], [1,1,-1,-1], [1,-1,1,-1], [1,1,1,1]])
    b = np.array([y1,y2,y3,y4])
    [q0, qa, qb, qab] = np.linalg.solve(a,b)

    y_bar = np.mean([y1,y2,y3,y4]) # q0 or sample mean
    sample_var = ((y1-y_bar)**2 + (y2-y_bar)**2 + (y3-y_bar)**2 + (y4-y_bar)**2)/3

    [q04, qa4, qb4, qab4] = np.multiply([q0, qa, qb, qab],4)

    SSA = 4*(qa**2)
    SSB = 4*(qb**2)
    SSAB = 4*(qab**2)
    SST = SSA+SSB+SSAB # total variation

    varA = (SSA/SST) * 100
    varB = (SSB/SST) * 100
    varAB = (SSAB/SST) * 100

    print 'The effects : '
    print '   Sample mean : %.2f' % q0
    print '   Effect of #MW : %.2f' % qa
    print '   Effect of messagesize : %.2f' % qb
    print '   Interaction effect : %.2f' % qab
    print ''
    print '   Sample mean x 4 : %.2f' % q04
    print '   Effect of #MW x 4 : %.2f' % qa4
    print '   Effect of messagesize x 4 : %.2f' % qb4
    print '   Interaction effect x 4 : %.2f' % qab4
    print ''
    print '   Total variation : %.2f' % SST
    print '   varA : %2.f' % varA
    print '   varB : %2.f' % varB
    print '   varAB : %2.f' % varAB





if __name__ == "__main__":
    main()