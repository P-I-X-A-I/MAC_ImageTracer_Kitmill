//
//  mainController.m
//  024-ImageTracer
//
//  Created by 渡辺圭介 on 2015/08/24.
//  Copyright (c) 2015年 KeisukeWatanabe. All rights reserved.
//

#import "mainController.h"

@implementation mainController

- (id)init
{
    self = [super init];
    
    mode = 0;
    
    pixInv_RGB = NULL;
    
    pixBin_Red = NULL;
    pixBin_Blue = NULL;
    
    poBitmap_Red_Ptr = NULL;
    poBitmap_Blue_Ptr = NULL;
    
    poParam_Red_t = NULL;
    poParam_Blue_t = NULL;
    
    poState_Red_t = NULL;
    poState_Blue_t = NULL;
    
    pointStrip_Red_ptr = NULL;
    pointStrip_Blue_ptr = NULL;
    
    offset_Red_Ptr = NULL;
    offset_Blue_Ptr = NULL;
    
    return self;
}

- (void)awakeFromNib
{
    NSLog(@"mainController AFN");
   
    [radioButton_obj selectCellAtRow:mode column:0];
    imageView_obj.imageAlignment = NSImageAlignBottomLeft;
    imageView_obj.imageScaling = NSImageScaleProportionallyUpOrDown;

    pathView_obj.mainWindow_obj = mainWindow_obj;
    pathView_obj.isDrawable = NO;
    pathView_obj.pStrip_Red_ptr = nil;
    pathView_obj.pStrip_Blue_ptr = nil;
    pathView_obj.scaleFactor = 0.0;
    pathView_obj.mode = mode;
    
    generateButton_obj.enabled = NO;
    saveButton_obj.enabled = NO;
    radioButton_obj.enabled = NO;
    
    Size_TexField_obj.stringValue = @"W0mm x H0mm";
    
    Drill_TexField_obj.stringValue = @"Drill diameter : 0.4mm";
    dDiameter = 4;
    [Drill_Slider_obj setFloatValue:dDiameter];
    
    Loop_TexField_obj.stringValue = @"Loops for milling : 1";
    millLoop = 1;
    [Loop_Slider_obj setIntValue:millLoop];
    
    
    milling_TexField_obj.stringValue = @"Milling depth : 0.3mm";
    millDepth = 0;
    [milling_Slider_obj setIntValue:millDepth];
    
    cutout_TextField_obj.stringValue = @"Cutout depth : 1.5mm";
    cutDepth = 2;
    [cutout_Slider_obj setIntValue:cutDepth];
    
    mill_unit_TexField_obj.stringValue = @"0.3mm";
    millUnit = 2;
    [mill_unit_Slider_obj setIntValue:millUnit];
    
    cut_unit_TexField_obj.stringValue = @"0.5mm";
    cutUnit = 4;
    [cut_unit_Slider_obj setIntValue:cutUnit];
    
    speed_TexField_obj.stringValue = @"Speed : 12mm/s";
    speed = 2;
    [speed_Slider_obj setIntValue:speed];
    
    // disable gui
    [Drill_TexField_obj setEnabled:NO];
    [Drill_Slider_obj setEnabled:NO];
    
    [Loop_TexField_obj setEnabled:NO];
    [Loop_Slider_obj setEnabled:NO];
    
    [milling_TexField_obj setEnabled:NO];
    [milling_Slider_obj setEnabled:NO];
    
    [cutout_TextField_obj setEnabled:NO];
    [cutout_Slider_obj setEnabled:NO];
    
    [speed_TexField_obj setEnabled:NO];
    [speed_Slider_obj setEnabled:NO];
    
}


- (void)loadImageAndMakePath:(id)sender
{
    std::cout << "button" << std::endl;
    
    NSOpenPanel* openImagePanel_obj = [NSOpenPanel openPanel];
    
    openImagePanel_obj.title = @"Select bitmap image file";
    openImagePanel_obj.allowsMultipleSelection = NO;
    openImagePanel_obj.allowedFileTypes = [NSArray arrayWithObjects:@"bmp", nil];
    
    [openImagePanel_obj beginWithCompletionHandler:^(NSInteger result)
     {
         if( result == NSFileHandlingPanelOKButton )
         {
             NSURL* fileURL = [openImagePanel_obj URL];
             [self getBMPInformation:fileURL];
             
         }
         else if( result == NSFileHandlingPanelCancelButton )
         {
             // do nothing
             return;
         }
     }
     ];
}



@end
