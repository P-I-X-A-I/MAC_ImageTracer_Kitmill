#include "mainController.h"

@implementation mainController ( PO_UTILITY )

- (void)setCurvePointFrom:(potrace_dpoint_t)headPoint
                  poCurve:(potrace_curve_t*)curvePtr
            pointStripPtr:(double**)dpPtr
                    index:(int)idx
{
    
    double hP[2];
    double uP[2];
    double wP[2];
    double eP[2];
    potrace_dpoint_t U = curvePtr->c[idx][0];
    potrace_dpoint_t W = curvePtr->c[idx][1];
    potrace_dpoint_t E = curvePtr->c[idx][2];
    

    
    hP[0] = headPoint.x;    hP[1] = headPoint.y;
    uP[0] = U.x;            uP[1] = U.y;
    wP[0] = W.x;            wP[1] = W.y;
    eP[0] = E.x;            eP[1] = E.y;
    
    
    for( int i = 0 ; i < 10 ; i++ )
    {
        double t = 0.1 * i;
        double A = (1.0 - t)*(1.0 - t)*(1.0 - t);
        double B = 3.0*t*(1.0 - t)*(1.0 - t);
        double C = 3.0*t*t*(1.0 - t);
        double D = t*t*t;
        
        double tP[2];
        tP[0] = A*hP[0] + B*uP[0] + C*wP[0] + D*eP[0];
        tP[1] = A*hP[1] + B*uP[1] + C*wP[1] + D*eP[1];
        
        *(*dpPtr) = tP[0];
        (*dpPtr)++;
        *(*dpPtr) = tP[1];
        (*dpPtr)++;
        
    }
}

- (void)setCornerPointFrom:(potrace_dpoint_t)headPoint
                   poCurve:(potrace_curve_t*)curvePtr
             pointStripPtr:(double**)dpPtr
                     index:(int)idx
{
    double hX = headPoint.x;
    double hY = headPoint.y;
    double nextX = curvePtr->c[idx][1].x;
    double nextY = curvePtr->c[idx][1].y;
    
    
    *(*dpPtr) = hX;
    (*dpPtr)++;
    
    *(*dpPtr) = hY;
    (*dpPtr)++;

    *(*dpPtr) = nextX;
    (*dpPtr)++;

    *(*dpPtr) = nextY;
    (*dpPtr)++;

}

@end