#import "mainController.h"

@implementation mainController (POTRACE)

 void callback(double progress, void* data)
{
    printf( "%f\n", progress );
}

- (void)getBMPInformation:(NSURL *)URL
{
    // set image to NSImageView
    NSImage* tempImage = [[NSImage alloc] initWithContentsOfURL:URL];
    [imageView_obj setImage:tempImage];


    
    // get filehandle(binary) of bmp
    NSFileHandle* FH = [NSFileHandle fileHandleForReadingFromURL:URL error:nil];
    if(FH == nil )
    {
        [self showAlertWindow:@"File import error" sub:@"image file can't be load"];
        return;
    }
    
    
    
    // init pathView
    pathView_obj.pStrip_Blue_ptr = nil;
    pathView_obj.pStrip_Red_ptr = nil;
    pathView_obj.scaleFactor = 0.0;
    pathView_obj.isDrawable = NO;
    
    
    
    // get header
    
    // file type (from 0,  2byte) , always "BM"
    NSData* tempData = [FH readDataToEndOfFile];
    unsigned int OFFSET;
    unsigned int SIZE;
    
    // it always "BM"
    char* temp = (char*)malloc(3);
    [tempData getBytes:temp range:NSMakeRange(0, 2)];
    char* tempCopy = temp;
    tempCopy += 2;
    *tempCopy = '\n';
    NSLog(@"%s", temp );
    free(temp);
    
    
    // file size (from 2, 4byte)
    unsigned int* fileSize = (unsigned int*)malloc(4);
    [tempData getBytes:fileSize range:NSMakeRange(2, 4)];
    NSLog(@"%d", *fileSize);
    free(fileSize);
    
    
    // data offset(from 10, 4byte)
    unsigned int* dataOffset = (unsigned int*)malloc(4);
    [tempData getBytes:dataOffset range:NSMakeRange(10, 4)];
    NSLog(@"data offset %d", *dataOffset);
    OFFSET = *dataOffset;
    free(dataOffset);
    
    
    // info header size (from 14, 4byte)
    unsigned int* infoHeaderSize = (unsigned int*)malloc(4);
    [tempData getBytes:infoHeaderSize range:NSMakeRange(14, 4)];
    NSLog(@"info header size %d", *infoHeaderSize);
    if( *infoHeaderSize == 40 )
    {
        bitmapInfo_t.isWINDOWS = 1;
    }
    else
    {
        bitmapInfo_t.isWINDOWS = 0;
        [self showAlertWindow:@"Invarid file format" sub:@"This bitmap image may be OS/2 format. Please use WINDOWS bmp format."];
        
        [imageView_obj setImage:nil];
        free(infoHeaderSize);
        return;
    }
    free(infoHeaderSize);
    
    
    // image Width (from 18, 4byte)
    unsigned int* imageWidth = (unsigned int*)malloc(4);
    [tempData getBytes:imageWidth range:NSMakeRange(18, 4)];
    NSLog(@"image Width %d", *imageWidth);
    bitmapInfo_t.imgWidth = *imageWidth;
    free(imageWidth);
    
    
    
    // image Height ( from 22, 4byte )
    unsigned int* imageHeight = (unsigned int*)malloc(4);
    [tempData getBytes:imageHeight range:NSMakeRange(22, 4)];
    NSLog(@"image Height %d", *imageHeight);
    bitmapInfo_t.imgHeight = *imageHeight;
    free(imageHeight);
    
    
    // check image size
    if( bitmapInfo_t.imgWidth > MAX_IMAGE_SIZE || bitmapInfo_t.imgHeight > MAX_IMAGE_SIZE )
    {
        [self showAlertWindow:@"This image file is too huge." sub:[NSString stringWithFormat:@"Please use an image which is smaller than %dpixel width (or  hight)", MAX_IMAGE_SIZE]];
        
        [imageView_obj setImage:nil];
        return;
    }
    
    
    
    
    
    
    
    // bit per pixel ( from 28, 2byte )
    unsigned short* bpp = (unsigned short*)malloc(2);
    [tempData getBytes:bpp range:NSMakeRange(28, 2)];
    NSLog(@"bpp %d", *bpp );
    bitmapInfo_t.bpp = *bpp;
    
    if( *bpp == 8 )
    {
        if( mode == 2 ) // circuit pattern & cutout
        {
//            [self showAlertWindow:@"Invarid file format." sub:@"for 'both' mode, Please use an RGB color image which consist of Red, White, Black color"];
//            [imageView_obj setImage:nil];
//            free(bpp);
//            return;
        }
    }
    else if( *bpp == 24 )
    {
        NSLog(@"This image is 24 bpp");
        free(bpp);
    }
    else
    {
        [self showAlertWindow:@"Invarid file format." sub:@"This image may contain Alpha channel, Please use Grayscale or RGB bmp image"];
        [imageView_obj setImage:nil];
        free(bpp);
        return;
    }
    
    
    // image data size ( from 34, 4 )
    unsigned int* imageDataSize = (unsigned int*)malloc(4);
    [tempData getBytes:imageDataSize range:NSMakeRange(34, 4)];
    NSLog(@"image data size %d", *imageDataSize);
    bitmapInfo_t.imgDataSize = *imageDataSize;
    SIZE = *imageDataSize;
    free(imageDataSize);
    
    
    // dot/m width (from 38, 4)
    unsigned int* dpm_w = (unsigned int*)malloc(4);
    [tempData getBytes:dpm_w range:NSMakeRange(38, 4)];
    double dpi_w = (double)*dpm_w * 0.01 * 2.54;
    NSLog(@"DPI width %1.4f", dpi_w );
    bitmapInfo_t.W_DPI = dpi_w;
    free(dpm_w);
    
    
    // dot/m height (from 42, 4byte)
    unsigned int* dpm_h = (unsigned int*)malloc(4);
    [tempData getBytes:dpm_h range:NSMakeRange(42, 4)];
    double dpi_h = (double)*dpm_h * 0.01 * 2.54;
    NSLog(@"DPI height %1.4f", dpi_h );
    bitmapInfo_t.H_DPI = dpi_h;
    free( dpm_h );
    
    
    // check image DPI
    if( bitmapInfo_t.W_DPI < 300.0 || bitmapInfo_t.H_DPI < 300.0)
    {
        [self showAlertWindow:@"The image is too lough." sub:@"600dpi or higher BMP image is recommended."];
        [imageView_obj setImage:nil];
        return;
    }


    // access to image data
    NSData* imageData = [tempImage TIFFRepresentation];
    //NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:imageData];
    //unsigned char* imagePtr = [imageRep bitmapData];    
    //bitmapInfo_t.imgPtr = imagePtr;
    imageRep = [[NSBitmapImageRep alloc] initWithData:imageData];

    
    

    // enable generate
    generateButton_obj.enabled = YES;
    radioButton_obj.enabled = YES;
    
    if( mode == 0 )
    {
        Drill_Slider_obj.enabled = YES;
        Loop_Slider_obj.enabled = YES;
        milling_Slider_obj.enabled = YES;
        cutout_Slider_obj.enabled = NO;
        speed_Slider_obj.enabled = YES;
    }
    else if( mode == 1 )
    {
        Drill_Slider_obj.enabled = YES;
        Loop_Slider_obj.enabled = NO;
        milling_Slider_obj.enabled = NO;
        cutout_Slider_obj.enabled = YES;
        speed_Slider_obj.enabled = YES;
    }
    else if( mode == 2 )
    {
        Drill_Slider_obj.enabled = YES;
        Loop_Slider_obj.enabled = YES;
        milling_Slider_obj.enabled = YES;
        cutout_Slider_obj.enabled = YES;
        speed_Slider_obj.enabled = YES;
    }
    
    double mmW, mmH;
    mmW = bitmapInfo_t.imgWidth / (bitmapInfo_t.W_DPI / 25.4);
    mmH = bitmapInfo_t.imgHeight / (bitmapInfo_t.H_DPI / 25.4);
    Size_TexField_obj.stringValue = [NSString stringWithFormat:@"W%1.1fmm x H%1.1fmm", mmW, mmH];

    //[self checkBMP_andMakeRGBArray];
}


- (void)checkBMP_andMakeRGBArray
{
    NSLog(@"check BMP and make array");
    
    bitmapInfo_t.imgPtr = [imageRep bitmapData];
    
    unsigned int numBit = bitmapInfo_t.bpp;
    unsigned int W = bitmapInfo_t.imgWidth;
    unsigned int H = bitmapInfo_t.imgHeight;
    //unsigned char RGB[H][W][3];
    unsigned char* ptrCopy = bitmapInfo_t.imgPtr;
    double PERCENTAGE;
    
    
    int i, j;
    BOOL isHasRed = NO;
    BOOL isHasWhite = NO;
    
    [progressBar_obj setHidden:NO];
    [progressBar_obj setUsesThreadedAnimation:YES];
    [progressBar_obj startAnimation:nil];
    
    
    // init RGB array
    for( i = 0 ; i < MAX_IMAGE_SIZE ; i++ )
    {
        for( j = 0 ; j < MAX_IMAGE_SIZE ; j++ )
        {
            RGB[i][j][0] = 0;
            RGB[i][j][1] = 0;
            RGB[i][j][2] = 0;
        }
    }
    
    switch ( numBit ) {
        case 8:
            for( i = 0 ; i < H ; i++ )
            {
                PERCENTAGE = (double)i / (double)H;
                [progressBar_obj setDoubleValue:PERCENTAGE*100.0];
                
                for( j = 0 ; j < W ; j++ )
                {
                    RGB[i][j][0] = 0;
                    RGB[i][j][1] = 0;
                    RGB[i][j][2] = *ptrCopy;
                    // after inport Grayscale image, it's data become 3channel
                    unsigned char tempVal[3];
                    tempVal[0] = *ptrCopy;
                    ptrCopy++;
                    tempVal[1] = *ptrCopy;
                    ptrCopy++;
                    tempVal[2] = *ptrCopy;
                    ptrCopy++;
                    
                    
                    if( tempVal[0] > 200 && tempVal[1] > 200 && tempVal[2] > 200)
                    {
                        isHasWhite = YES;
                    }
                }
            }
             break;
        case 24:
            for( i = 0 ; i < H ; i++ )
            {
                PERCENTAGE = (double)i / (double)H;
                [progressBar_obj setDoubleValue:PERCENTAGE*100.0];
                
                
                for( j = 0 ; j < W ; j++ )
                {
                    RGB[i][j][0] = *ptrCopy; ptrCopy++;
                    RGB[i][j][1] = *ptrCopy; ptrCopy++;
                    RGB[i][j][2] = *ptrCopy; ptrCopy++;
                    
                    // check if it has red color
                    if( RGB[i][j][0] > 220 && RGB[i][j][1] < 20 && RGB[i][j][2] < 20  )
                    {
                        isHasRed = YES;
                    }
                    if( RGB[i][j][0] > 200 && RGB[i][j][1] > 220 && RGB[i][j][2] > 220 )
                    {
                        isHasWhite = YES;
                    }
                }
            }
             break;
        default:
            break;
    }// switch
    
    
    [progressBar_obj stopAnimation:nil];
    [progressBar_obj setHidden:YES];
    
    
    // if mode is both, and image doesn't have red color, error
    if( mode == 0 )// milling mode
    {
        if( isHasWhite == NO)
        {
            [self showAlertWindow:@"This image don't contain White color." sub:@"When you select 'Circuit milling' mode, The circuit pattern should be drawn in white color"];
            [imageView_obj setImage:nil];
            return;
        }
    }
    
    if( mode == 1 )// cutout mode
    {
        if( isHasRed == NO )
        {
            [self showAlertWindow:@"This image don't contain Red color." sub:@"When you select 'Cutout' mode, The cutout path should be drawn in red color."];
            [imageView_obj setImage:nil];
            return;
        }
    }
   
    
    if( mode == 2 )// both mode
    {
        if( isHasWhite == NO)
        {
            [self showAlertWindow:@"This image don't contain White color." sub:@"When you select 'both' mode, The circuit pattern should be drawn in white color."];
            [imageView_obj setImage:nil];
            return;
        }
        if( isHasRed == NO)
        {
            [self showAlertWindow:@"This image don't contain Red color." sub:@"When you select 'both' mode, The cutout path should be drawn in red color."];
            [imageView_obj setImage:nil];
            return;
        }
    }
    
    
    
//    if( isHasWhite == NO )
//    {
//        [self showAlertWindow:@"This image don't contain White colored area." sub:@"The circuit pattern should be drawn by white color."];
//        [imageView_obj setImage:nil];
//        return;
//    }
    
    
    
    
    // copy RGB to memory ( inverted )
    if( pixInv_RGB != NULL)
    {
        free( pixInv_RGB );
        pixInv_RGB = NULL;
    }
    
    pixInv_RGB = (unsigned char*)malloc( W*H*3 );
    
    unsigned char* newPtr_copy = pixInv_RGB;
    
    //bitmapInfo_t.imgPtr = pixInv_RGB;
    
    for( i = H-1 ; i >= 0 ; i-- )
    {
        for( j = 0 ; j < W ; j++ )
        {
            *newPtr_copy = RGB[i][j][0]; newPtr_copy++;
            *newPtr_copy = RGB[i][j][1]; newPtr_copy++;
            *newPtr_copy = RGB[i][j][2]; newPtr_copy++;
        }
    }
    
    
    [self makeBinaryArray];
    
}



- (void)makeBinaryArray
{
    unsigned int W = bitmapInfo_t.imgWidth;
    unsigned int H = bitmapInfo_t.imgHeight;
    
    
    int PO_WORD_SIZE = sizeof( potrace_word ) * 8;
    int PADDING_SIZE = PO_WORD_SIZE - ( bitmapInfo_t.imgWidth % PO_WORD_SIZE );
    NSLog(@"padding size %d imgWidth %d imgheight %d", PADDING_SIZE, W, H);
    
    
    if( pixBin_Red != NULL)
    {
        free( pixBin_Red );
        pixBin_Red = NULL;
    }
    if( pixBin_Blue != NULL )
    {
        free( pixBin_Blue );
        pixBin_Blue = NULL;
    }
    
    pixBin_Red = (unsigned char*)malloc( H * (W+PADDING_SIZE) );
    pixBin_Blue = (unsigned char*)malloc( H * (W+PADDING_SIZE) );
    memset(pixBin_Red, 0, H*(W+PADDING_SIZE));
    memset(pixBin_Blue, 0, H*(W+PADDING_SIZE));
    
    
    unsigned char* pixBin_Rcopy = pixBin_Red;
    unsigned char* pixBin_Bcopy = pixBin_Blue;

    //unsigned char* pixPtr = bitmapInfo_t.imgPtr;
    unsigned char* pixPtr = pixInv_RGB;
    unsigned char tempValue_R, tempValue_B;
    
    for( int i = 0 ; i < H ; i++ )
    {
        for( int j = 0 ; j < ( W + PADDING_SIZE ) ; j++ )
        {
            if( j < W )
            {
                tempValue_R = *pixPtr; pixPtr++; // R
                pixPtr++; // G
                tempValue_B = *pixPtr; pixPtr++;//B
                
                if( tempValue_R > 128 )
                {
                    *pixBin_Rcopy = 1;
                    pixBin_Rcopy++;
                }
                else
                {
                    *pixBin_Rcopy = 0;
                    pixBin_Rcopy++;
                }
                
                
                
                if( tempValue_B > 128 )
                {
                    *pixBin_Bcopy = 1;
                    pixBin_Bcopy++;
                }
                else
                {
                    *pixBin_Bcopy = 0;
                    pixBin_Bcopy++;
                }
                
            }
            else
            {
                *pixBin_Rcopy = 0;
                pixBin_Rcopy++;
                *pixBin_Bcopy = 0;
                pixBin_Bcopy++;
            }
            
        }// j
    }// i
    
    
    // restore pointer
    pixBin_Rcopy = pixBin_Red;
    pixBin_Bcopy = pixBin_Blue;
    
    
    // free bitmap info
    //free(bitmapInfo_t.imgPtr);
    
    [self makePotraceBitmap_W:(W + PADDING_SIZE) H:H];
 }



- (void)makePotraceBitmap_W:(int)padW H:(int)padH
{
    int PO_SIZE = sizeof(potrace_word)*8;
    
    // make mask array
    potrace_word maskBit[PO_SIZE];
    maskBit[PO_SIZE-1] = 1;
    
    for( int i = PO_SIZE-2 ; i >= 0 ; i-- )
    {
        maskBit[i] = maskBit[i+1] << 1;
    }
    
    
    
    int numByte = padW * padH / 8;
    
    
    if ( poBitmap_Red_Ptr != NULL)
    {
        free( poBitmap_Red_Ptr );
        poBitmap_Red_Ptr = NULL;
    }
    if( poBitmap_Blue_Ptr != NULL )
    {
        free( poBitmap_Blue_Ptr );
        poBitmap_Blue_Ptr = NULL;
    }
    
    poBitmap_Red_Ptr = (potrace_word*)malloc( numByte );
    poBitmap_Blue_Ptr = (potrace_word*)malloc( numByte );
    memset( poBitmap_Red_Ptr, 0, numByte);
    memset( poBitmap_Blue_Ptr, 0, numByte);

    
    poBitmap_Red_t.w = bitmapInfo_t.imgWidth;
    poBitmap_Red_t.h = bitmapInfo_t.imgHeight;
    poBitmap_Red_t.dy = padW / PO_SIZE;
    poBitmap_Red_t.map = poBitmap_Red_Ptr;
    
    poBitmap_Blue_t.w = bitmapInfo_t.imgWidth;
    poBitmap_Blue_t.h = bitmapInfo_t.imgHeight;
    poBitmap_Blue_t.dy = padW / PO_SIZE;
    poBitmap_Blue_t.map = poBitmap_Blue_Ptr;
    
    
    
    potrace_word* tempR = poBitmap_Red_Ptr;
    potrace_word* tempB = poBitmap_Blue_Ptr;
    
    unsigned char* pixBin_R_copy = pixBin_Red;
    unsigned char* pixBin_B_copy = pixBin_Blue;
    
    // create potrace_word data
    for( int i = 0 ; i < padH ; i++ )
    {
        for( int j = 0 ; j < padW ; j++ )
        {
            int INDEX = j % PO_SIZE;

            
            // Red (cutout)
            if( *pixBin_R_copy == 1 )
            {
                *tempR = *tempR | maskBit[INDEX];
            }
            else
            {
                // do nothing
            }
            pixBin_R_copy++;
            
            
            if( *pixBin_B_copy == 1 )
            {
                *tempB = *tempB | maskBit[INDEX];
            }
            else
            {
                // do nothing
            }
            pixBin_B_copy++;
            
            
            if( INDEX == (PO_SIZE-1) )
            {
                //printf("%lx \n", *tempR);

                tempR++;
                tempB++;
            }
        }
    }// i
    
    
    // free pixBin_red , and blue
    //free(pixBin_Blue);
    //free(pixBin_Red);
    
    
    
    // do tracing
    [self doTracing];
}



- (void)doTracing
{
    
    //progress
    potrace_progress_t progress_t;
    progress_t.min = 0.0;
    progress_t.max = 100.0;
    progress_t.epsilon = 1.0;
    progress_t.callback = callback;

    
    if( poParam_Red_t != NULL )
    {
        potrace_param_free( poParam_Red_t );
        poParam_Red_t = NULL;
    }
    
    if( poParam_Blue_t != NULL )
    {
        potrace_param_free( poParam_Blue_t );
        poParam_Blue_t = NULL;
    }
    
    poParam_Red_t = potrace_param_default();
    poParam_Blue_t = potrace_param_default();
    
    
    poParam_Red_t->turdsize = 10; // default 3 // remove small area
    poParam_Red_t->turnpolicy = POTRACE_TURNPOLICY_MINORITY; // default
    poParam_Red_t->alphamax = 1.0; // default
    poParam_Red_t->opticurve = 1; // default
    poParam_Red_t->opttolerance = 0.2; // default
    poParam_Red_t->progress = progress_t;
    
    poParam_Blue_t->turdsize = 10; // default
    poParam_Blue_t->turnpolicy = POTRACE_TURNPOLICY_MINORITY; // default
    poParam_Blue_t->alphamax = 1.0; // default
    poParam_Blue_t->opticurve = 1; // default
    poParam_Blue_t->opttolerance = 0.2; // default
    poParam_Blue_t->progress = progress_t;
    
    
    
    if( poState_Red_t != NULL )
    {
        potrace_state_free( poState_Red_t );
        poState_Red_t = NULL;
    }
    
    if( poState_Blue_t != NULL )
    {
        potrace_state_free( poState_Blue_t );
        poState_Blue_t = NULL;
    }
    
    
    
    
    
    
    // tracing
    
    if( mode == 0 )
    {
        poState_Blue_t = potrace_trace( poParam_Blue_t, &(poBitmap_Blue_t)); // trace white ( actually blue )
    }
    else if( mode == 1 )
    {
        poState_Red_t = potrace_trace( poParam_Red_t, &(poBitmap_Red_t) ); // trace red
    }
    else if( mode == 2 )
    {
        poState_Blue_t = potrace_trace( poParam_Blue_t, &(poBitmap_Blue_t));
        poState_Red_t = potrace_trace( poParam_Red_t, &(poBitmap_Red_t) );
    }
    
    //if( mode == 2)
    //{poState_Red_t = potrace_trace( poParam_Red_t, &(poBitmap_Red_t) );}
    //
    //poState_Blue_t = potrace_trace( poParam_Blue_t, &(poBitmap_Blue_t));
    
    
    // check status
    if( mode == 2 || mode == 1 )
    {
        if( poState_Red_t->status == POTRACE_STATUS_OK )
        {
            printf("tracing red SUCCESS!\n");
        }
        else
        {
            printf("tracing red Error...\n");
            [self showAlertWindow:@"Tracing error" sub:@"This image can't be traced."];
            [imageView_obj setImage:nil];
        }
    }// if mode 2
    
    
    if( mode == 0 || mode == 2)
    {
        if( poState_Blue_t->status == POTRACE_STATUS_OK )
        {
            printf("tracing blue SUCCESS\n");
        }
        else
        {
            printf("tracing blue Error...\n");
            [self showAlertWindow:@"Tracing error" sub:@"This image can't be traced."];
            [imageView_obj setImage:nil];
        }
    }
    
    
    
    
    
    
    // count path for alloc memory
    
    potrace_path_t* path_In_Red = 0x0;
    potrace_path_t* path_In_Blue = 0x0;
    
    if( mode == 0 )
    {
        path_In_Blue = poState_Blue_t->plist;
    }
    else if( mode == 1 )
    {
        path_In_Red = poState_Red_t->plist;
    }
    else if( mode == 2 )
    {
        path_In_Red = poState_Red_t->plist;
        path_In_Blue = poState_Blue_t->plist;
    }
//    if( mode == 2 )
//   {
//        path_In_Red = poState_Red_t->plist;
//    }
//    potrace_path_t* path_In_Blue = poState_Blue_t->plist;
    
    int numOf_path_Red = 0;
    int numOf_path_Blue = 0;
    int numOf_point_Red = 0;
    int numOf_point_Blue = 0;
    
    
    // count path
    if( mode == 2 || mode == 1 )// red
    {
        while(1)
        {
            if( path_In_Red != 0x0 )
            {
                potrace_curve_t tempCurve = path_In_Red->curve;
                
                for( int k = 0 ; k < tempCurve.n ; k++ )
                {
                    int tag = tempCurve.tag[k];
                    
                    if( tag == POTRACE_CURVETO )
                    {
                        numOf_point_Red += 10;
                    }
                    else if( tag == POTRACE_CORNER )
                    {
                        numOf_point_Red += 2;
                    }
                }
                
                path_In_Red = path_In_Red->next;
                numOf_path_Red++;
            }
            else
            {break;}
        }// while
    }// if mode == 2 || mode == 1
    
    
    if( mode == 0 || mode == 2)
    {
    while(1)
    {
        if( path_In_Blue != 0x0 )
        {
            potrace_curve_t tempCurve = path_In_Blue->curve;
            //int areaB = path_In_Blue->area;
            //char sign = (char)path_In_Blue->sign;
            //printf("areaBlue %d sign %d\n", areaB, sign);
            
            
            
            for( int k = 0 ; k < tempCurve.n ; k++ )
            {
                int tag = tempCurve.tag[k];
                
                if( tag == POTRACE_CURVETO )
                {
                    numOf_point_Blue += 10;
                }
                else if( tag == POTRACE_CORNER )
                {
                    numOf_point_Blue += 2;
                }
            }
            
            path_In_Blue = path_In_Blue->next;
            numOf_path_Blue++;
        }
        else
        {break;}
    }// while
    } // if mode == 0 || mode == 2
    
    NSLog(@"path Red %d, path Blue %d", numOf_path_Red, numOf_path_Blue);
    NSLog(@"point Red %d, point blue %d", numOf_point_Red, numOf_point_Blue );
    
    
    
    // reserve memory for point;
    // create pointStrip
    // num x XY x byte + kugiri + end
    if( pointStrip_Red_ptr != NULL )
    {
        free(pointStrip_Red_ptr);
        pointStrip_Red_ptr = NULL;
    }
    if( pointStrip_Blue_ptr != NULL )
    {
        free( pointStrip_Blue_ptr );
        pointStrip_Blue_ptr = NULL;
    }
    
    long memSize_Red = ((numOf_point_Red * 2 ) +
                       ( numOf_path_Red * 2 ) +
                       ( 2 ))*sizeof( double );
    long memSize_Blue = (( numOf_point_Blue * 2 ) +
                         (numOf_path_Blue *2 ) +
                         (2)) * sizeof(double);
    
    pointStrip_Red_ptr = (double*)malloc( memSize_Red );
    pointStrip_Blue_ptr = (double*)malloc( memSize_Blue );

    memset( pointStrip_Red_ptr, 0, memSize_Red);
    memset( pointStrip_Blue_ptr, 0, memSize_Blue);

    // pointer copy
    double* pStrip_Red_Copy = pointStrip_Red_ptr;
    double* pStrip_Blue_Copy = pointStrip_Blue_ptr;

    
    // write end code once, for no paths are found
    double* tempRP = pStrip_Red_Copy;
    *tempRP = -200.5;
    tempRP++;
    *tempRP = -200.5;
    // write end code once, for no paths are found
    double* tempBP = pStrip_Blue_Copy;
    *tempBP = -200.5;
    tempBP++;
    *tempBP = -200.5;

    
    
    // alloc memory and clear
    if( mode == 2 || mode == 1 )
    {
        
        // set Path
        path_In_Red = poState_Red_t->plist;
        
        // set point data ( red )***************************************
        while (1) {
            if( path_In_Red != 0x0 )
            {
                potrace_curve_t* tempCurvePtr = &path_In_Red->curve;
                int numPointInPath = 0;
                char sign = (char)path_In_Red->sign;
                //int areaR = path_In_Red->area;
                
                double kugiri_code;
                if( sign == 43)// +
                {
                    kugiri_code = -100.1;
                }
                else if( sign == 45 )//-
                {
                    kugiri_code = -150.1;
                }
                
                // set kugiri
                *pStrip_Red_Copy = kugiri_code;
                pStrip_Red_Copy++;
                double* numWrite_Ptr = pStrip_Red_Copy;
                pStrip_Red_Copy++;
                
                
                
                // sign
                //::::::::::
                
                
                for( int k = 0 ; k < tempCurvePtr->n ; k++ )
                {
                    
                    // get tag ( curve or corner )
                    int tag = tempCurvePtr->tag[k];
                    
                    
                    // get point
                    int pIndex;
                    if( k == 0 ){ pIndex = tempCurvePtr->n - 1; }
                    else{ pIndex = k-1;}
                    potrace_dpoint_t headPoint = tempCurvePtr->c[pIndex][2];
                    
                    
                    if( tag == POTRACE_CURVETO )
                    {
                        // add curve point
                        [self setCurvePointFrom:headPoint
                                        poCurve:tempCurvePtr
                                  pointStripPtr:&pStrip_Red_Copy
                                          index:k];
                        
                        numPointInPath += 10;
                        
                    }
                    else if( tag == POTRACE_CORNER )
                    {
                        // add corner point
                        [self setCornerPointFrom:headPoint
                                         poCurve:tempCurvePtr
                                   pointStripPtr:&pStrip_Red_Copy
                                           index:k];
                        
                        numPointInPath += 2;
                    }
                    
                }//k
                
                
                // go to next path
                path_In_Red = path_In_Red->next;
                
                // write num of Point in path
                *numWrite_Ptr = (double)numPointInPath + 0.5;
                
            }
            else
            {
                // write end code
                *pStrip_Red_Copy = -200.5;
                pStrip_Red_Copy++;
                *pStrip_Red_Copy = -200.5;
            
                break;
            }
        }// while
    }// if mode == 2 || mode == 1
    
    
    
    
    
    // set point data ( blue )********************************************
    // num x XY x byte + kugiri + end
    
    
    
    if( mode == 0 || mode == 2 )
    {
        
    // set Path
    path_In_Blue = poState_Blue_t->plist;
    
    
    
    // set points data (blue)
    while(1)
    {
        if( path_In_Blue != 0x0 )
        {
            potrace_curve_t* tempCurvePtr = &path_In_Blue->curve;
            int numPointInPath = 0;
            int sign = path_In_Blue->sign;
            
            double kugiri_code;
            if( sign == 43 )//+
            {
                kugiri_code = -100.1;
            }
            else if( sign == 45 )//-
            {
                kugiri_code = -150.1;
            }
            
            
            // set kugiri
            *pStrip_Blue_Copy = kugiri_code;
            pStrip_Blue_Copy++;
            double* numWrite_Ptr = pStrip_Blue_Copy;
            pStrip_Blue_Copy++;
            
            
            // sign
            //:::::::::::::
            
            
            for( int k = 0 ; k < tempCurvePtr->n ; k++ )
            {
                // get tag
                int tag = tempCurvePtr->tag[k];
                
                // get point
                int pIndex;
                if( k == 0 ){ pIndex = tempCurvePtr->n - 1; }
                else{ pIndex = k-1; }
                potrace_dpoint_t headPoint = tempCurvePtr->c[pIndex][2];
                
                
                if( tag == POTRACE_CURVETO )
                {
                    [self setCurvePointFrom:headPoint
                                    poCurve:tempCurvePtr
                              pointStripPtr:&pStrip_Blue_Copy
                                      index:k];
                    numPointInPath += 10;
                }
                else if( tag == POTRACE_CORNER )
                {
                    [self setCornerPointFrom:headPoint
                                     poCurve:tempCurvePtr
                               pointStripPtr:&pStrip_Blue_Copy
                                       index:k];
                    numPointInPath += 2;
                }
                
            }// for k
            
            // set next path
            path_In_Blue = path_In_Blue->next;
            
            // set num of point in path
            *numWrite_Ptr = (double)numPointInPath + 0.5;
            
        }// if path not null
        else
        {
            // write end code
            *pStrip_Blue_Copy = -200.5;
            pStrip_Blue_Copy++;
            *pStrip_Blue_Copy = -200.5;
            break;
        }
    }// while
    }// if mode == 0 || mode == 2

    
    // process complete
    isProcessed = YES;
    
}

@end
