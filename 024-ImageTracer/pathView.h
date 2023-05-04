//
//  pathView.h
//  024-ImageTracer
//
//  Created by 渡辺圭介 on 2015/08/24.
//  Copyright (c) 2015年 KeisukeWatanabe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface pathView : NSView
{
    NSWindow* mainWindow_obj;
    double* pStrip_Red_ptr;
    double* pStrip_Blue_ptr;
    double scaleFactor;
    BOOL isDrawable;
    int mode;
}

@property (atomic) NSWindow* mainWindow_obj;
@property (readwrite) double* pStrip_Red_ptr;
@property (readwrite) double* pStrip_Blue_ptr;
@property (readwrite) double scaleFactor;
@property (readwrite) BOOL isDrawable;
@property (readwrite) int mode;
@end
