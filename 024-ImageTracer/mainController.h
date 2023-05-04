//
//  mainController.h
//  024-ImageTracer
//
//  Created by 渡辺圭介 on 2015/08/24.
//  Copyright (c) 2015年 KeisukeWatanabe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>


#import "potracelib.h"
#import "clipper.h"

#import "pathView.h"


//***** C++ & C
#include "string.h"
#include <iostream>
#include <fstream>
#include <string>

#define MAX_IMAGE_SIZE 20000
#define MEM_SIZE 200

typedef struct BMPINFO
{
    unsigned char* imgPtr;
    unsigned int isWINDOWS;
    unsigned int imgWidth;
    unsigned int imgHeight;
    unsigned int bpp;
    unsigned int imgDataSize;
    double W_DPI;
    double H_DPI;
}BMP_INFO_t;



@interface mainController : NSObject
{
    IBOutlet NSImageView* imageView_obj;
    IBOutlet pathView* pathView_obj;
    IBOutlet NSMatrix* radioButton_obj;
    IBOutlet NSWindow* mainWindow_obj;
    
    
    // GUI
    IBOutlet NSButton* generateButton_obj;
    IBOutlet NSTextField* Drill_TexField_obj;
    IBOutlet NSSlider* Drill_Slider_obj;
    IBOutlet NSTextField* Loop_TexField_obj;
    IBOutlet NSSlider* Loop_Slider_obj;
    IBOutlet NSTextField* Size_TexField_obj;
    IBOutlet NSButton* saveButton_obj;
    IBOutlet NSTextField* milling_TexField_obj;
    IBOutlet NSSlider* milling_Slider_obj;
    IBOutlet NSTextField* cutout_TextField_obj;
    IBOutlet NSSlider* cutout_Slider_obj;
    IBOutlet NSTextField* mill_unit_TexField_obj;
    IBOutlet NSSlider* mill_unit_Slider_obj;
    IBOutlet NSTextField* cut_unit_TexField_obj;
    IBOutlet NSSlider* cut_unit_Slider_obj;
    
    IBOutlet NSProgressIndicator* progressBar_obj;
    IBOutlet NSSlider* speed_Slider_obj;
    IBOutlet NSTextField* speed_TexField_obj;
    BOOL isProcessed;
    
    // image info
    BMP_INFO_t bitmapInfo_t;
    unsigned char* pixInv_RGB;
    unsigned char* pixBin_Red;
    unsigned char* pixBin_Blue;
    NSBitmapImageRep* imageRep;
    
    // variables
    int mode;
    int dDiameter;
    int millLoop;
    unsigned char RGB[MAX_IMAGE_SIZE][MAX_IMAGE_SIZE][3];
    int millDepth;
    int cutDepth;
    int millUnit;
    int cutUnit;
    int speed;
    
    //potrace state ( path data )
    potrace_bitmap_t poBitmap_Red_t;
    potrace_bitmap_t poBitmap_Blue_t;

    potrace_param_t* poParam_Red_t;
    potrace_param_t* poParam_Blue_t;
    
    potrace_state_t* poState_Red_t;
    potrace_state_t* poState_Blue_t;
    
    potrace_word* poBitmap_Red_Ptr;
    potrace_word* poBitmap_Blue_Ptr;
    
    
    
    
    // point
    double* pointStrip_Red_ptr;
    double* pointStrip_Blue_ptr;
    double* offset_Red_Ptr;
    double* offset_Blue_Ptr;
    
    std::vector<ClipperLib::IntPoint> offset_Red_Vector;
    std::vector<ClipperLib::IntPoint> offset_Blue_Vector;
    
    
    // Gcode
    std::string G_CODE_string;
    
    // OpenGL
    NSOpenGLContext* glContext_obj;
    GLuint VBO_name[2];
    GLuint VAO_name;
    
    GLuint VS_OBJ;
    GLuint GS_OBJ;
    GLuint FS_OBJ;
    GLuint PRG_OBJ;
    GLint UNF_mvpMatrix;
}


- (IBAction)loadImageAndMakePath:(id)sender;
@end


@interface mainController (POTRACE)
- (void)getBMPInformation:(NSURL*)URL;
- (void)checkBMP_andMakeRGBArray;
- (void)makeBinaryArray;
- (void)makePotraceBitmap_W:(int)padW H:(int)padH;
- (void)doTracing;
@end


@interface mainController ( POTRACE_UTILITY )
- (void)setCurvePointFrom:(potrace_dpoint_t)headPoint
                  poCurve:(potrace_curve_t*)curvePtr
            pointStripPtr:(double**)dpPtr
                    index:(int)idx;

- (void)setCornerPointFrom:(potrace_dpoint_t)headPoint
                   poCurve:(potrace_curve_t*)curvePtr
             pointStripPtr:(double**)dpPtr
                     index:(int)idx;
@end


@interface mainController (ALERT)
- (void)showAlertWindow:(NSString*)message sub:(NSString*)subtext;
@end


@interface mainController (GENERATE_BUTTON)
- (IBAction)generateOffsetPath:(id)sender;
- (BOOL)doOffset;
@end


@interface mainController (GUI)
- (IBAction)Slider_Diameter:(id)sender;
- (IBAction)Slider_Loops:(id)sender;
- (IBAction)Slider_Mill:(id)sender;
- (IBAction)Slider_Cut:(id)sender;
- (IBAction)Slider_millUnit:(id)sender;
- (IBAction)Slider_cutUnit:(id)sender;
- (IBAction)Slider_Speed:(id)sender;
- (IBAction)pathMode:(NSMatrix*)sender;
- (IBAction)SaveButton:(id)sender;
@end


