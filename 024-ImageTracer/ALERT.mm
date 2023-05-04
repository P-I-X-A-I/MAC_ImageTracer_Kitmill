#import "mainController.h"

@implementation mainController (ALERT)

- (void)showAlertWindow:(NSString *)message sub:(NSString *)subtext
{
    Size_TexField_obj.stringValue = @"W0mm x H0mm";
    
    generateButton_obj.enabled = NO;
    saveButton_obj.enabled = NO;
    radioButton_obj.enabled = NO;
    
    Drill_Slider_obj.enabled = NO;
    Drill_TexField_obj.enabled = NO;
    Loop_Slider_obj.enabled = NO;
    Loop_TexField_obj.enabled = NO;
    milling_Slider_obj.enabled = NO;
    milling_TexField_obj.enabled = NO;
    cutout_Slider_obj.enabled = NO;
    cutout_TextField_obj.enabled = NO;
    speed_Slider_obj.enabled = NO;
    speed_TexField_obj.enabled = NO;
    
    pathView_obj.isDrawable = NO;
    pathView_obj.pStrip_Blue_ptr = nil;
    pathView_obj.pStrip_Red_ptr = nil;
    pathView_obj.scaleFactor = 0.0;
    [pathView_obj setNeedsDisplay:YES];
    
    NSAlert* tempAlert = [[NSAlert alloc] init];
    [tempAlert addButtonWithTitle:@"OK"];
    tempAlert.messageText = message;
    tempAlert.informativeText = subtext;
    tempAlert.alertStyle = NSWarningAlertStyle;
    
    [tempAlert runModal];
    
    
    
    return;
}
@end