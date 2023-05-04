#import "mainController.h"

@implementation mainController ( OPENGL )

- (void)initOpenGL
{
    GLenum error;
    
    // pix format attribute
    NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFASampleBuffers, 1,
        NSOpenGLPFASamples, 4,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFADepthSize, 16,
        NSOpenGLPFAScreenMask, CGDisplayIDToOpenGLDisplayMask( kCGDirectMainDisplay ),
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAMultisample,
        0
    };
    
    NSOpenGLPixelFormat* pixFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    
    if( pixFormat == nil )
    {
        NSLog(@"pix format creation error...");
        return;
    }

    // create context
    glContext_obj = [[NSOpenGLContext alloc] initWithFormat:pixFormat shareContext:nil];
    
    GLint swapInterval = 1;
    [glContext_obj setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
    [glContext_obj setView:openGLView_obj];
    [glContext_obj makeCurrentContext];
    
    // test clear
    glClearColor(1.0, 0.0, 0.0, 1.0 );
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    [glContext_obj flushBuffer];
    

    //**************************
    error = glGetError();
    NSLog(@"error %x", error );
    //**************************
}

@end