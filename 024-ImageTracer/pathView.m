//
//  pathView.m
//  024-ImageTracer
//
//  Created by 渡辺圭介 on 2015/08/24.
//  Copyright (c) 2015年 KeisukeWatanabe. All rights reserved.
//

#import "pathView.h"

@implementation pathView

@synthesize mainWindow_obj;
@synthesize pStrip_Red_ptr;
@synthesize pStrip_Blue_ptr;
@synthesize scaleFactor;
@synthesize isDrawable;
@synthesize mode;

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    [[NSColor clearColor] set];
    NSRectFill(dirtyRect);
    
    if( isDrawable )
    {
    
        double* pRed_Ptr = pStrip_Red_ptr;
        double* pBlue_Ptr = pStrip_Blue_ptr;
        double SF = scaleFactor;
        
        double val_X, val_Y;
        BOOL isFirstPoint = YES;
        

    
        NSGraphicsContext* gc = [NSGraphicsContext currentContext];
        if( gc == nil )
        {
            NSLog(@"GRAPHICS CONTEXT IS NIL");
            return;
        }
        [gc saveGraphicsState];
    
    
        // set color
        NSBezierPath* tempPath = [NSBezierPath bezierPath];
        [tempPath moveToPoint:NSMakePoint(0.0, 0.0)];
        
        
        
        // get point (Blue)
        if( mode == 0 || mode == 2 )
        {
            [[NSColor blackColor] setStroke];
        }
        else if( mode == 1 )
        {
            [[NSColor redColor] setStroke];
        }
            isFirstPoint = YES;
        
        while(1)
        {
            val_X = (*pBlue_Ptr); pBlue_Ptr++;
            val_Y = (*pBlue_Ptr);
            
            
            if( (int)val_X == -200 || (int)val_Y == -200 )// end code
            {
                [tempPath closePath];
                break;
            }
            else if( (int)val_X == -100 )// knot point
            {
                // val_Y is num of point
                isFirstPoint = YES;
                [tempPath closePath];
            }
            else
            {
                if(isFirstPoint)
                {
                    isFirstPoint = NO;
                    [tempPath moveToPoint:NSMakePoint((CGFloat)val_X*SF, (CGFloat)val_Y*SF)];
                }
                else
                {
                    [tempPath lineToPoint:NSMakePoint((CGFloat)val_X*SF, (CGFloat)val_Y*SF)];
                }
            }
            
            pBlue_Ptr++;
        }// while
        
        [tempPath stroke];
        [tempPath removeAllPoints];
        [tempPath moveToPoint:NSMakePoint(0.0, 0.0)];

        
        // get point (RED)
        [[NSColor redColor] setStroke];
        
        isFirstPoint = YES;
        
        while(1)
        {
            val_X = (*pRed_Ptr); pRed_Ptr++;
            val_Y = (*pRed_Ptr);
            

            if( (int)val_X == -200 || (int)val_Y == -200 )// end code
            {
                [tempPath closePath];
                break;
            }
            else if( (int)val_X == -100 ) // knot point
            {
                // valY is num of point
                isFirstPoint = YES;
                [tempPath closePath];
            }
            else
            {
                if( isFirstPoint )
                {
                    isFirstPoint = NO;
                    [tempPath moveToPoint:NSMakePoint((CGFloat)val_X*SF, (CGFloat)val_Y*SF)];
                }
                else
                {
                    [tempPath lineToPoint:NSMakePoint((CGFloat)val_X*SF, (CGFloat)val_Y*SF)];
                }
            }
            
            pRed_Ptr++;
        }//while

    
        [tempPath stroke];
        [gc restoreGraphicsState];

        // Drawing code here.
        
    }// isDrawable
}



@end
