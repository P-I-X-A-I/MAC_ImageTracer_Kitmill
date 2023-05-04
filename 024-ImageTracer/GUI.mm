#import "mainController.h"

@implementation mainController (GUI)

- (IBAction)pathMode:(NSMatrix*)sender
{
    int radioIndex = (int)sender.selectedRow;
    mode = radioIndex;
    pathView_obj.mode = mode;
    
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
}

- (IBAction)Slider_Diameter:(id)sender
{
    dDiameter = [sender intValue];
    Drill_TexField_obj.stringValue = [NSString stringWithFormat:@"Drill diameter : %1.1fmm", (float)dDiameter * 0.1];
}


- (IBAction)Slider_Loops:(id)sender
{
    millLoop = [sender intValue];
    Loop_TexField_obj.stringValue = [NSString stringWithFormat:@"Loops for milling : %d", millLoop];
}

- (IBAction)Slider_Mill:(id)sender
{
    millDepth = [sender intValue];
    float temp = (millUnit+1) * 0.05;
    milling_TexField_obj.stringValue = [NSString stringWithFormat:@"Milling depth : %1.2fmm", (millDepth+1)*temp ];
}
- (IBAction)Slider_Cut:(id)sender
{
    cutDepth = [sender intValue];
    float temp = (cutUnit+1)*0.05;
    cutout_TextField_obj.stringValue = [NSString stringWithFormat:@"Cutout depth : %1.2fmm", (cutDepth+1)*temp];
}


- (IBAction)Slider_millUnit:(id)sender
{
    millUnit = [sender intValue];
    float temp = (millUnit+1) * 0.05;
    mill_unit_TexField_obj.stringValue = [NSString stringWithFormat:@"%1.2fmm", temp];
    [milling_Slider_obj performClick:nil];
}
- (IBAction)Slider_cutUnit:(id)sender
{
    cutUnit = [sender intValue];
    float temp = (cutUnit+1)*0.05;
    cut_unit_TexField_obj.stringValue = [NSString stringWithFormat:@"%1.2fmm", temp];
    [cutout_Slider_obj performClick:nil];
}



- (IBAction)Slider_Speed:(id)sender
{
    speed = [sender intValue];
    speed_TexField_obj.stringValue = [NSString stringWithFormat:@"Speed : %dmm/s", speed*2 + 2];
}


- (IBAction)SaveButton:(id)sender
{
    double FEEDRATE = ((double)speed * 2 + 2)*10.0; // 40 ~ 200
    
    
    double* redPoint_ptr = offset_Red_Ptr;
    double* bluePoint_ptr = offset_Blue_Ptr;
    
    double val[2];
    BOOL isFirstPoint = YES;
    long LINE_NUMBER = 0;
    
    double p_to_mm = (25.4 / bitmapInfo_t.W_DPI);
    printf("p to mm %f", p_to_mm);
    
    
    // erase all string
    G_CODE_string.erase( G_CODE_string.begin(), G_CODE_string.end() );
    G_CODE_string.reserve(50000000); // 20MB
    
    
    // add First G-CODE Line
    char head[] = "G64 P0.1\nF500.0\nG0 Z3.0\nM3 S10000.0\n";
    //int csNum = [self calcurateChecksum:head];
    
    G_CODE_string.append( head );
    //G_CODE_string.append( std::to_string(csNum) );
    //G_CODE_string.append( "\n" );
    
    
    double* target_ptr = bluePoint_ptr;
    
    // mill depth & cut depth
    int iter;
    double unitDepth;
    
    // bounding box to eliminate outer path
    double box_W = (double)bitmapInfo_t.imgWidth;
    double box_H = (double)bitmapInfo_t.imgHeight;
    printf("box wh %f %f\n", box_W, box_H);
    
    // Generate g-code from white path******************************
    if( mode == 0 || mode == 2 )
    {
        // set loops and unitDepth
        iter = millDepth+1;
        unitDepth = (millUnit+1)*0.05;
        
        for( int N = 0 ; N < iter ; N++ )
        {
            target_ptr = bluePoint_ptr;
        
            while (1) {
        
                // unit is pixel
                val[0] = *target_ptr; target_ptr++;
                val[1] = *target_ptr; target_ptr++;
        
                
                if( val[0] < -199.0 )// it means end code
                {
            
                    // end
                    break;
                }
                else if( val[0] < -99.0 && val[0] > -101.0) // means kugiri
                {
            
                    isFirstPoint = YES;
                    // lift up z
                    [self setFeedRate:1450.0 Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                    [self liftUp_Z:&LINE_NUMBER toCPPString:&G_CODE_string];
                }
                else
                {
                    
                    // eliminate outer loop
                    if( (val[0] >= -10.0 && val[0] <= 20.0 ) ||
                        (val[0] >= box_W-20.0 && val[0] <= box_W+20.0 ) ||
                        (val[1] >= -10.0 && val[1] <= 20.0 ) ||
                        (val[1] >= box_H-20.0 && val[1] <= box_H+20.0 )
                       )
                    { printf("outer %f %f\n", val[0], val[1]); }
                    else
                    {
                        if( isFirstPoint == YES ) // first point after -100 code
                        {
                            // move to first point
                            [self setFeedRate:1450.0 Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                            [self moveToPoint:val scale:&p_to_mm Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                            // lift down z
                            [self setFeedRate:100.0 Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                            [self liftDown_Zto:-unitDepth*(N+1) Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                            [self setFeedRate:FEEDRATE Line:&LINE_NUMBER toCPPString:&G_CODE_string];

                            isFirstPoint = NO;
                        }
                        else // normal process
                        {
                            [self moveToPoint:val scale:&p_to_mm Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                        }
                    }// eliminate outer loop
            // move to next point
                }
            }// while
    
        }// for N
    
    } // if mode == 0 || mode == 2
    
    
    
    
    
    // Generate g-code from red path
    
    // both mode
    if( mode == 2 || mode == 1)
    {
        iter = cutDepth+1;
        unitDepth = (cutUnit+1)*0.05;
        
        for( int N = 0 ; N < iter ; N++ )
        {
            target_ptr = redPoint_ptr;
            
            while (1) {
                
                val[0] = *target_ptr; target_ptr++;
                val[1] = *target_ptr; target_ptr++;
                
                if( val[0] < -199.0 )// it means end code
                {
                    
                    // end
                    break;
                }
                else if( val[0] < -99.0 && val[0] > -101.0) // means kugiri
                {
                    
                    isFirstPoint = YES;
                    // lift up z
                    [self setFeedRate:1450.0 Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                    [self liftUp_Z:&LINE_NUMBER toCPPString:&G_CODE_string];
                }
                else
                {
                    if( (val[0] >= -10.0 && val[0] <= 20.0 ) ||
                       (val[0] >= box_W-20.0 && val[0] <= box_W+20.0 ) ||
                       (val[1] >= -10.0 && val[1] <= 20.0 ) ||
                       (val[1] >= box_H-20.0 && val[1] <= box_H+20.0 )
                       )
                    { printf("outer %f %f\n", val[0], val[1]); }
                    else
                    {
                        if( isFirstPoint == YES ) // first point after -100 code
                        {
                            // move to first point
                            [self setFeedRate:1450.0 Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                            [self moveToPoint:val scale:&p_to_mm Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                            // lift down z
                            [self setFeedRate:100.0 Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                            [self liftDown_Zto:-unitDepth*(N+1) Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                            [self setFeedRate:FEEDRATE Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                       
                            isFirstPoint = NO;
                        }
                        else // normal process
                        {
                            [self moveToPoint:val scale:&p_to_mm Line:&LINE_NUMBER toCPPString:&G_CODE_string];
                        }
                    }// eliminate outer loop
                    
                    // move to next point
                }
            }// while
            
        }// for N

    }// if mode 2
    
    
    // Add End Code *****************
    
    // lift up z
    [self setFeedRate:1000.0 Line:&LINE_NUMBER toCPPString:&G_CODE_string];
    [self liftUp_Z:&LINE_NUMBER toCPPString:&G_CODE_string];
    
    
    
    // return to home
    G_CODE_string.append( "G1 Z30\n");
    G_CODE_string.append( "G1 X0 Y0\n" ); // go to origin point
    G_CODE_string.append( "M5\n" ); // stop drill

    //printf("%s", G_CODE_string.c_str());
    
    
    
    // save file
    NSSavePanel* tempSavePanel = [NSSavePanel savePanel];
    NSArray* fileType = [NSArray arrayWithObjects:@"nc", @"ncd", @"gcode",  nil];
    [tempSavePanel setAllowedFileTypes:fileType];
    
    [tempSavePanel beginWithCompletionHandler:^(NSInteger result)
     {
         if( result == NSOKButton )
         {
             NSURL* saveURL = [tempSavePanel URL];
             const char* savePath = [[saveURL path] cStringUsingEncoding:NSUTF8StringEncoding];
             
             std::ofstream ofs;
             ofs.open( savePath );
             ofs << G_CODE_string.c_str() << std::endl;
             ofs.close();
         }
         else if( result == NSCancelButton )
         {
             // do nothing
             G_CODE_string.erase( G_CODE_string.begin(), G_CODE_string.end() );
             NSLog(@"save cancel %s", G_CODE_string.c_str());
         }
     }
     ];
    
}










- (int)calcurateChecksum:(char*)cPtr
{
    int cs = 0;
    char* cPtr_copy = cPtr;
    
    while (1) {
        
        // get one character
        char tempChar = *cPtr_copy;
        cPtr_copy++;
        
        // check if it's end null or *
        if( tempChar == '\0' || tempChar == '*')
        {break;}
        
        cs = cs ^ tempChar;
    }// while
    
    return cs;
}


- (void)liftUp_Z:(long*)LineNum toCPPString:(std::string*)cppString
{
    char* tempChar_ptr = (char*)malloc( MEM_SIZE );
    memset( tempChar_ptr, '\n', MEM_SIZE);
    //sprintf( tempChar_ptr, "N%ld G1 Z10.0*", *LineNum);
    sprintf( tempChar_ptr, "G1 Z2.0\n");
    
    // get checksum
//    int cs = [self calcurateChecksum:tempChar_ptr];
    cppString->append(tempChar_ptr);
//    cppString->append( std::to_string(cs));
//    cppString->append( "\n" );
    
    // free
    free( tempChar_ptr );
    
    // increment line number
    *LineNum += 1;
}


- (void)moveToPoint:(double*)point_ptr scale:(double*)scalePtr Line:(long*)LineNum toCPPString:(std::string*)cppString
{
    double* ptr_copy = point_ptr;
    double pX = *ptr_copy; ptr_copy++;
    double pY = *ptr_copy;
    
    pX *= (*scalePtr);
    pY *= (*scalePtr);
    
    char* tempChar_ptr = (char*)malloc( MEM_SIZE );
    memset( tempChar_ptr, '\n', MEM_SIZE );
//    sprintf( tempChar_ptr, "N%ld G1 X%1.5f Y%1.5f*", *LineNum, pX, pY);
    sprintf( tempChar_ptr, "G1 X%1.5f Y%1.5f\n", pX, pY );

    // get checksum
//    int cs = [self calcurateChecksum:tempChar_ptr];
    cppString->append( tempChar_ptr );
//    cppString->append( std::to_string( cs ) );
//    cppString->append( "\n" );
    
    // free memory
    free( tempChar_ptr );
    
    *LineNum += 1;
}


- (void)liftDown_Zto:(double)depth Line:(long*)LineNum toCPPString:(std::string*)cppString
{
    char* tempChar_ptr = (char*)malloc( MEM_SIZE );
    memset( tempChar_ptr, '\n', MEM_SIZE );
    //sprintf( tempChar_ptr, "N%ld G1 Z%1.4f*", *LineNum, depth );
    sprintf( tempChar_ptr, "G1 Z%1.4f\n", depth);
    
    // get checksum
//    int cs = [self calcurateChecksum:tempChar_ptr];
    cppString->append( tempChar_ptr );
//    cppString->append( std::to_string(cs) );
//    cppString->append( "\n" );
    
    // free memory
    free( tempChar_ptr );
    
    *LineNum += 1;
}



- (void)setFeedRate:(double)feedRate Line:(long*)LineNum toCPPString:(std::string*)cppString
{
    char* tempChar_ptr = (char*)malloc( MEM_SIZE );
    memset( tempChar_ptr, '\n', MEM_SIZE );
    //sprintf( tempChar_ptr, "N%ld G1 F%1.4f*", *LineNum, feedRate );
    sprintf( tempChar_ptr, "G1 F%1.4f\n", feedRate);
    
    // get checksum
    //int cs = [self calcurateChecksum:tempChar_ptr];
    cppString->append( tempChar_ptr );
    //cppString->append( std::to_string( cs) );
    //cppString->append( "\n" );
    
    // free memory
    free( tempChar_ptr );
    
    *LineNum += 1;
}
@end

