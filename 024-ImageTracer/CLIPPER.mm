#import "mainController.h"

@implementation mainController ( GENERATE_BUTTON )


- (IBAction)generateOffsetPath:(id)sender
{
    printf("generate offset path\n");
    
    isProcessed = NO;
    
    // create path from image
    [self checkBMP_andMakeRGBArray];
    
    
    
    // generate offset from points.
    if( isProcessed )
    {
        isProcessed = [self doOffset];
    }
    
    
    
    
    // set pathView
    double viewW = pathView_obj.frame.size.width;
    double viewH = pathView_obj.frame.size.height;
    double imgW = bitmapInfo_t.imgWidth;
    double imgH = bitmapInfo_t.imgHeight;
    
    double scaleF[2];
    double SF;
    
    if( isProcessed )
    {
        scaleF[0] = viewW / imgW;
        scaleF[1] = viewH / imgH;
    
        if ( scaleF[0] < scaleF[1])
        {
            SF = scaleF[0];
        }
        else
        {
            SF = scaleF[1];
        }
    
        pathView_obj.pStrip_Red_ptr = offset_Red_Ptr;
        pathView_obj.pStrip_Blue_ptr = offset_Blue_Ptr;
        //pathView_obj.pStrip_Red_ptr = pointStrip_Red_ptr;
        //pathView_obj.pStrip_Blue_ptr = pointStrip_Blue_ptr;
        pathView_obj.scaleFactor = SF;
        pathView_obj.isDrawable = YES;

        [pathView_obj setNeedsDisplay:YES];
    }
    
    saveButton_obj.enabled = YES;
}







- (BOOL)doOffset
{
    
    // Clipper variables
    ClipperLib::Path subj;
    ClipperLib::Paths subj_Paths;
    ClipperLib::Paths solution;
    std::vector<ClipperLib::Paths> Paths_Vector;
    ClipperLib::ClipperOffset offset_obj;
    
    
    // offset value
    double actDiameter = dDiameter * 0.1;
    double offsetDelta = (bitmapInfo_t.W_DPI / 25.4) * actDiameter;
    
    
    // path for drawing view
    // uint is "Pixel"
    double* redPtr_Copy = pointStrip_Red_ptr;
    double* bluePtr_Copy = pointStrip_Blue_ptr;
    long tempVal[2];
    
    BOOL isFirst_Kugiri = YES;
    
    
    
    // red point
    // remove "outer 10 pixel" ///////////////////////
    while ( 1 ){
        tempVal[0] = (long)(*redPtr_Copy);  redPtr_Copy++;
        tempVal[1] = (long)(*redPtr_Copy);  redPtr_Copy++;
        
        
        if(tempVal[0] == -200 || tempVal[1] == -200) // end code*****************
        {
            if( isFirst_Kugiri == NO )
            {
                // add subj to subj_path
                subj_Paths.push_back( subj );
                
                // add Paths to offset object
                offset_obj.AddPaths(subj_Paths, ClipperLib::jtRound, ClipperLib::etClosedPolygon);
                
                // do offset
                offset_obj.Execute( solution, offsetDelta*0.5);
                
                
                // push result to vector
                Paths_Vector.push_back(solution);
                
                
                // clear
                offset_obj.Clear();
                subj_Paths.clear();
                subj.clear();
                solution.clear();
            }
            break;
        }
        else if( tempVal[0] == -100 || tempVal[0] == -150) // kugiri code *****************************
        {
            if( isFirst_Kugiri )
            {
                isFirst_Kugiri = NO;
            }
            else
            {
                subj_Paths.push_back( subj );
                subj.clear();
            }
        }
        else // add point *********************************************
        {
            /*
            // remove outer 10 pixel
            if( (tempVal[0] >= bitmapInfo_t.imgWidth-10 && tempVal[0] <= bitmapInfo_t.imgWidth) ||
               ( tempVal[0] >= 0 && tempVal[0] <= 10 ) ||
               ( tempVal[1] >= bitmapInfo_t.imgHeight-10 && tempVal[1] <= bitmapInfo_t.imgHeight) ||
               ( tempVal[1] >= 0 && tempVal[1] <= 10)
            )
            {
                // skip "outer 10 pix"
            }
            else
            {
                subj << ClipperLib::IntPoint((long)tempVal[0], (long)tempVal[1]);
            }
            */
            subj << ClipperLib::IntPoint((long)tempVal[0], (long)tempVal[1]);
        }
    }// while red
    

    
    
    // access to point
    
    
    long numSolution = Paths_Vector.size();
    
    // clear point and add kugiri
    offset_Red_Vector.clear();
    offset_Red_Vector.push_back( ClipperLib::IntPoint( -100, -100 ) );
    
    
    for( int i = 0 ; i < numSolution ; i++ )
    {
        
        ClipperLib::Paths tempPaths = Paths_Vector[i];
        long numPath = tempPaths.size(); // this value is usually 1,
        
        
        for( int j = 0 ; j < numPath ; j++ )
        {
            ClipperLib::Path eachPath = tempPaths[j];
            long numOf_PathPoint = eachPath.size();
            //printf("oritentation red %d\n", ClipperLib::Orientation( eachPath ));

            
            // get each point
            for( int k = 0 ; k < numOf_PathPoint ; k++ )
            {
                // add Point

                offset_Red_Vector.push_back( eachPath[k] );
            }// k

            
            // add first point of closed path
            offset_Red_Vector.push_back( eachPath[0] );
            
            // add kugiri point
            offset_Red_Vector.push_back( ClipperLib::IntPoint(-100, -100) );
        }// j
    }// i
    
    
    // add End code
    offset_Red_Vector.push_back( ClipperLib::IntPoint(-200, -200) );
    
 
    
    
    
    
    
    
    // blue *************************************************************************
    subj_Paths.clear();
    subj.clear();
    solution.clear();
    Paths_Vector.clear();
    offset_obj.Clear();
    
    
    
        // reset pointer for loop
        bluePtr_Copy = pointStrip_Blue_ptr;
        isFirst_Kugiri = YES;
    
    while( 1 )
    {
        tempVal[0] = (long)(*bluePtr_Copy); bluePtr_Copy++;
        tempVal[1] = (long)(*bluePtr_Copy); bluePtr_Copy++;
        
        if( tempVal[0] == -200 || tempVal[1] == -200 )// end code*****************
        {
            if( isFirst_Kugiri == NO )
            {
                
                // add subj to subj_path
                subj_Paths.push_back( subj );
                
                // add path to offset object
                offset_obj.AddPaths( subj_Paths, ClipperLib::jtRound, ClipperLib::etClosedPolygon);
                
                // do offset
                offset_obj.Execute( solution, offsetDelta*0.5 );
                
                // add path to vector
                Paths_Vector.push_back( solution );
                
                // clear path
                offset_obj.Clear();
                subj.clear();
                solution.clear();
            }
            break;
        }// if -200
        else if( tempVal[0] == -100 || tempVal[0] == -150 ) // kugiri code*******************************
        {
            if( isFirst_Kugiri )
            {
                isFirst_Kugiri = NO;
            }
            else
            {
                subj_Paths.push_back( subj );
                subj.clear();
            }
        }
        else
        {
            /*
            // remove outer 10 pixel
            if( (tempVal[0] >= bitmapInfo_t.imgWidth-10 && tempVal[0] <= bitmapInfo_t.imgWidth) ||
               ( tempVal[0] >= 0 && tempVal[0] <= 10 ) ||
               ( tempVal[1] >= bitmapInfo_t.imgHeight-10 && tempVal[1] <= bitmapInfo_t.imgHeight) ||
               ( tempVal[1] >= 0 && tempVal[1] <= 10)
               )
            {
                // skip "outer 10 pix"
            }
            else
            {
                 subj << ClipperLib::IntPoint( (long)tempVal[0], (long)tempVal[1] );
            }
            */
            subj << ClipperLib::IntPoint( (long)tempVal[0], (long)tempVal[1] );

        }
    }// while blue

    
    
    
    
    // Loops
    
    ClipperLib::Paths finalPaths;
    ClipperLib::Paths tempPaths;
    ClipperLib::Paths tempSolution;
    
    // copy Paths_Vector to tempPaths
    for( int i = 0 ; i < Paths_Vector.size() ; i++ )
    {
        ClipperLib::Paths eachPaths = Paths_Vector[i];
        for( int j = 0 ; j < eachPaths.size() ; j++ )
        {
            ClipperLib::Path temp = eachPaths[j];

            tempPaths.push_back( temp );
            finalPaths.push_back( temp );
        }
    }
    
    
    // do loop
    
    int LOOPCOUNT;
    if( mode == 0 || mode == 2)
    {
        LOOPCOUNT = millLoop;
    }
    else
    {
        LOOPCOUNT = 0;
    }
    
    for( int i = 1 ; i < LOOPCOUNT ; i++ )
    {
        offset_obj.Clear();
        offset_obj.AddPaths(tempPaths, ClipperLib::jtRound, ClipperLib::etClosedPolygon );
        offset_obj.Execute( tempSolution, offsetDelta*0.8 );
        
        
        // add Path to finalPaths
        tempPaths.clear();
        for( int j = 0 ; j < tempSolution.size() ; j++ )
        {
            finalPaths.push_back( tempSolution[j] );
            tempPaths.push_back( tempSolution[j] );
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // access to point
    
    
    // clear point and add kugiri
    offset_Blue_Vector.clear();
    offset_Blue_Vector.push_back( ClipperLib::IntPoint( -100, -100 ) );
    
     long numOfBluePath = finalPaths.size();
     
     for( int i = 0 ; i < numOfBluePath ; i++ )
     {
         ClipperLib::Path eachPath = finalPaths[i];
         //printf("orientation blue %d\n", ClipperLib::Orientation( eachPath ));
         
         for( int j = 0 ; j < eachPath.size() ; j++ )
         {
             offset_Blue_Vector.push_back( eachPath[j] );
         }
         
         // add first point of closed path
         offset_Blue_Vector.push_back( eachPath[0] );
         
         // add kugiri
         offset_Blue_Vector.push_back( ClipperLib::IntPoint(-100, -100) );
     }
     
    
    // add End code
    offset_Blue_Vector.push_back( ClipperLib::IntPoint(-200, -200));
   
    
    
    
    
    // make offset pointer strip to memory
    if( offset_Red_Ptr != NULL )
    {
        free( offset_Red_Ptr );
        offset_Red_Ptr = NULL;
    }
    if( offset_Blue_Ptr != NULL )
    {
        free( offset_Blue_Ptr );
        offset_Blue_Ptr = NULL;
    }
    
    long numByte_RedVector = offset_Red_Vector.size() * 2 * sizeof(double) + 1;
    long numByte_BlueVector = offset_Blue_Vector.size() * 2 * sizeof(double) + 1;
    offset_Red_Ptr = (double*)malloc( numByte_RedVector );
    offset_Blue_Ptr = (double*)malloc( numByte_BlueVector );
    memset( offset_Red_Ptr, 0, numByte_RedVector );
    memset( offset_Blue_Ptr, 0, numByte_BlueVector );

    double* offRed_Copy = offset_Red_Ptr;
    double* offBlue_Copy = offset_Blue_Ptr;
    
    for( int i = 0 ; i < offset_Red_Vector.size() ; i++ )
    {
        *offRed_Copy = (double)offset_Red_Vector[i].X;  offRed_Copy++;
        *offRed_Copy = (double)offset_Red_Vector[i].Y;  offRed_Copy++;
    }
    
    for( int i = 0 ; i < offset_Blue_Vector.size() ; i++ )
    {
        *offBlue_Copy = (double)offset_Blue_Vector[i].X; offBlue_Copy++;
        *offBlue_Copy = (double)offset_Blue_Vector[i].Y; offBlue_Copy++;
    }
    
    
    
    
    // test
//    for( int i = 0 ; i < offset_Red_Vector.size() ; i++ )
//    {
//        long V[2];
//        V[0] = offset_Red_Vector[i].X;
//        V[1] = offset_Red_Vector[i].Y;
//        printf("red %ld %ld\n",V[0], V[1] );
//        
//        if( V[0] == -100 )
//        {
//            printf("***************\n");
//        }
//    }
//    
    
    // test
//    for( int i = 0 ; i < offset_Blue_Vector.size() ; i++ )
//    {
//        long V[2];
//        V[0] = offset_Blue_Vector[i].X;
//        V[1] = offset_Blue_Vector[i].Y;
//        printf("Blue %ld %ld\n",V[0], V[1] );
//        
//        if( V[0] == -100 )
//        {
//            printf("***************\n");
//        }
//    }

    
    return YES;
}



@end
