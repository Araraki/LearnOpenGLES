//
//  ViewController.m
//  OpenGL ES test
//
//  Created by Stanley Wang on 2017/5/25.
//  Copyright © 2017 Stanley Wang. All rights reserved.
//
#include <iostream>

#import <CoreMotion/CoreMotion.h>
#import "glesViewController.h"

#import "RenderFigure.h"
#import "Shader.h"
#import "Texture.h"
#import "Camera.h"

@interface glesViewController ()<GLKViewDelegate>
{
    EAGLContext *context;
//    Shader *baseShader;
    Shader *baseLightShader;
    Shader *lampShader;
    CMMotionManager *motionManager;
//    CMAttitude *attitude;
//    CMAcceleration grivaty;
//    CMAccelerometerData *newestAccel;
    
    CMAttitude* referenceAttitude;
    GLKMatrix4 ViewMatrix;
}
@end

@implementation glesViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self useGyroPush];
    [self startMotionManager];
    [self glesInit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)useGyroPush
{
/*
    motionManager = [[CMMotionManager alloc] init];
    
    if ([motionManager isDeviceMotionAvailable])
    {
        motionManager.deviceMotionUpdateInterval = 0.005f;
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                           withHandler:^(CMDeviceMotion * _Nullable motion,NSError * _Nullable error)
        {
            // Gravity
            double gravityX = motion.gravity.x;
            double gravityY = motion.gravity.y;
            double gravityZ = motion.gravity.z;
     
            double zTheta = atan2(gravityZ,sqrtf(gravityX * gravityX + gravityY * gravityY)) / M_PI * 180.0;
            double xyTheta = atan2(gravityX, gravityY) / M_PI * 180.0;
            double xzTheta = atan2(gravityX, gravityZ) / M_PI * 180.0;
//            double zTheta = atan2(gravityZ,sqrtf(gravityX * gravityX + gravityY * gravityY)) / M_PI * 180.0;
            NSLog(@"verctorG:(%.4f,     %.4f,       %.4f)\nhorizontal --- %.4f, aroundself --- %.4f，？？？ --- %.4f",gravityX,gravityY,gravityZ, zTheta, xyTheta, xzTheta);
        }];
    }
*/
//    
//
//    motionManager = [[CMMotionManager alloc] init];
//    
//    motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
//    motionManager.gyroUpdateInterval = 1.0f / 60.0;
//    motionManager.showsDeviceMovementDisplay = YES;
//    
//    [motionManager startDeviceMotionUpdates];
//    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
}

-(void)startMotionManager
{
    motionManager = [[CMMotionManager alloc]init];
    motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    motionManager.gyroUpdateInterval = 1.0f / 60;
    motionManager.showsDeviceMovementDisplay = YES;
    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
    referenceAttitude = nil;
    [motionManager startGyroUpdatesToQueue: [[NSOperationQueue alloc]init]
                               withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error)
    {
        [self calculateModelViewProjectMatrixWithDeviceMotion:motionManager.deviceMotion];
    }];
    referenceAttitude = motionManager.deviceMotion.attitude;
}

-(void)calculateModelViewProjectMatrixWithDeviceMotion:(CMDeviceMotion*)deviceMotion
{
    float scale = 1.0f;
    
    ViewMatrix = GLKMatrix4Identity;
    ViewMatrix = GLKMatrix4Scale(ViewMatrix, scale, scale, scale);
    
    if (deviceMotion != nil)
    {
        CMAttitude *attitude = deviceMotion.attitude;
        
        if (referenceAttitude != nil)
            [attitude multiplyByInverseOfAttitude:referenceAttitude];
        else
            referenceAttitude = deviceMotion.attitude;
// 1.
/*
        float cRoll = attitude.roll;
        float cPitch = attitude.pitch;
        
        ViewMatrix = GLKMatrix4RotateX(ViewMatrix, -cRoll);
        ViewMatrix = GLKMatrix4RotateY(ViewMatrix, cPitch*3);
*/
// 2.
        float cRoll = -fabs(attitude.roll); // Up/Down landscape
        float cYaw = attitude.yaw;  // Left/ Right landscape
        float cPitch = attitude.pitch; // Depth landscape
        
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        if (orientation == UIDeviceOrientationLandscapeRight )
            cPitch = cPitch*-1; // correct depth when in landscape right
        
        ViewMatrix = GLKMatrix4RotateX(ViewMatrix, cRoll); // Up/Down axis
        ViewMatrix = GLKMatrix4RotateY(ViewMatrix, cPitch);
        ViewMatrix = GLKMatrix4RotateZ(ViewMatrix, cYaw);
        ViewMatrix = GLKMatrix4RotateX(ViewMatrix, ROLL_CORRECTION);
    }
}

#pragma region GL ES3
GLKVector3 pointLightPositions[] =
{
    { 2.3f, -1.6f, -3.0f},
    {-1.7f,  0.9f,  1.0f}
};

GLuint boxTexture;

Camera camera;
GLKVector3 originRotate;

int SCR_WIDTH , SCR_HEIGHT ;

GLKMatrix4 projMat, viewMat, modelMat;

GLfloat currentTime, deltaTime, lastFrame;

- (void)glesInit
{
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!context)
        NSLog(@"Failed to create ES context");
    
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    
    [EAGLContext setCurrentContext:context];
    CGFloat scale = [[UIScreen mainScreen] scale];
    SCR_WIDTH = view.frame.size.width * scale;
    SCR_HEIGHT = view.frame.size.height * scale;
    glViewport(0, 0, SCR_WIDTH, SCR_HEIGHT); //reset viewport
    glClearColor(0.3, 0.3, 0.3, 1.0);
    
    glEnable(GL_DEPTH_TEST); //depth test
    
    camera = Camera(GLKVector3{0.0f, 0.0f, 3.0f});
    
    baseLightShader = [Shader alloc];
    [baseLightShader loadShaders:@"baseLight" frag:@"baseLight"];
    
    lampShader = [Shader alloc];
    [lampShader loadShaders:@"lamp" frag:@"lamp"];
    
    boxTexture = [Texture setupTexture:@"box.png"];
    glGenerateMipmap(GL_TEXTURE_2D);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    currentTime += 1.0f;
    
// get device motion
//    attitude = motionManager.deviceMotion.attitude;
//    float currentYaw = attitude.yaw;  // Left/ Right landscape
//    float currentPitch = attitude.pitch; // Depth landscape
//    float currentRoll  =  attitude.roll; // Up/Down landscape
//    NSLog(@"yaw %.4f,      roll %.4f,       pitch %.4f",
//          currentYaw / M_PI * 180.0, currentRoll / M_PI * 180.0, currentPitch / M_PI * 180.0);
    
//    grivaty = motionManager.deviceMotion.gravity;
    // update camera
//    camera.WorldUp = {static_cast<float>(-grivaty.x), static_cast<float>(-grivaty.y), static_cast<float>(-grivaty.z)};
//    camera.SetYRP(currentRoll, currentYaw, 0);
    
    [baseLightShader use];
    
    projMat = GLKMatrix4MakePerspective(camera.Zoom, float(SCR_WIDTH) / float(SCR_HEIGHT), 0.1f, 100.0f);
    glUniformMatrix4fv(glGetUniformLocation(baseLightShader->program, "proj"), 1, GL_FALSE, projMat.m);
    
    viewMat = camera.GetViewMatrix();
    //glUniformMatrix4fv(glGetUniformLocation(baseLightShader->program, "view"), 1, GL_FALSE, viewMat.m);
    glUniformMatrix4fv(glGetUniformLocation(baseLightShader->program, "view"), 1, GL_FALSE, ViewMatrix.m);
    
    modelMat = GLKMatrix4Identity;
    modelMat = GLKMatrix4Translate(modelMat, 0.0, 0.0, 0.0);
    //modelMat = GLKMatrix4Rotate(modelMat, GLKMathDegreesToRadians(currentTime), 1.0f, 0.2f, 0.5f);
    bool invAndTrans = true;
    glUniformMatrix4fv(glGetUniformLocation(baseLightShader->program, "model"), 1, GL_FALSE, modelMat.m);
    glUniformMatrix4fv(glGetUniformLocation(baseLightShader->program, "TRmodel"), 1, GL_FALSE, GLKMatrix4InvertAndTranspose(modelMat, &invAndTrans).m);
    
    glUniform3fv(glGetUniformLocation(baseLightShader->program, "viewPos"), 1, &camera.Position.v[0]);
    glUniform1f(glGetUniformLocation(baseLightShader->program, "constant"), 1.0f);
    glUniform1f(glGetUniformLocation(baseLightShader->program, "linear"), 0.009);
    glUniform1f(glGetUniformLocation(baseLightShader->program, "quadratic"), 0.0032);
    
    for (int i = 0; i < 2; i++)
        glUniform3fv(glGetUniformLocation(baseLightShader->program, ("position[" + std::to_string(i) + "]").c_str()), 1, &pointLightPositions[i].v[0]);

    RenderCube(baseLightShader, boxTexture);
    
    [lampShader use];
    glUniformMatrix4fv(glGetUniformLocation(lampShader->program, "proj"), 1, GL_FALSE, projMat.m);
    glUniformMatrix4fv(glGetUniformLocation(lampShader->program, "view"), 1, GL_FALSE, viewMat.m);
    glUniform3f(glGetUniformLocation(lampShader->program, "lampColor"), 1.0f, 1.0f, 1.0f);
    for(int i = 0; i < 2; ++i)
    {
        modelMat = GLKMatrix4Identity;
        modelMat = GLKMatrix4Translate(modelMat, 0.0f, 0.0f, 0.0f);
        modelMat = GLKMatrix4Scale(modelMat, 0.2f, 0.2f, 0.2f);
        glUniformMatrix4fv(glGetUniformLocation(lampShader->program, "model"), 1, GL_FALSE, modelMat.m);
    
        RenderCube(lampShader);
    }
    
    // RenderQuad(baseShader, boxTexture);
}
#pragma endregion
@end
