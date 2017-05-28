//
//  ViewController.m
//  OpenGL ES test
//
//  Created by Stanley Wang on 2017/5/25.
//  Copyright © 2017年 Stanley Wang. All rights reserved.
//
#include <iostream>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>

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
    CMAccelerometerData *newestAccel;
}
@end

@implementation glesViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self useGyroPush];
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
    motionManager = [[CMMotionManager alloc] init];
    
    if ([motionManager isDeviceMotionAvailable])
    {
        motionManager.deviceMotionUpdateInterval = 0.005f;
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                           withHandler:^(CMDeviceMotion * _Nullable motion,NSError * _Nullable error)
        {
            // Gravity 获取手机的重力值在各个方向上的分量，根据这个就可以获得手机的空间位置，倾斜角度等
            double gravityX = motion.gravity.x;
            double gravityY = motion.gravity.y;
            double gravityZ = motion.gravity.z;
            
            // 获取手机的倾斜角度(zTheta是手机与水平面的夹角， xyTheta是手机绕自身旋转的角度)：
            double zTheta = atan2(gravityZ,sqrtf(gravityX * gravityX + gravityY * gravityY)) / M_PI * 180.0;
            double xyTheta = atan2(gravityX, gravityY) / M_PI * 180.0;
            NSLog(@"verctorG:(%.4f,     %.4f,       %.4f)\n手机与水平面的夹角 --- %.4f, 手机绕自身旋转的角度为 --- %.4f",gravityX,gravityY,gravityZ, zTheta, xyTheta);
            
            
        }];
    }
}

#pragma region GL ES3
glm::vec3 pointLightPositions[] =
{
    glm::vec3(2.3f, -1.6f, -3.0f),
    glm::vec3(-1.7f, 0.9f, 1.0f)
};

GLuint boxTexture;

Camera camera;

int SCR_WIDTH , SCR_HEIGHT ;

glm::mat4 projMat, viewMat, modelMat;

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
    glViewport(0, 0, SCR_WIDTH, SCR_HEIGHT); //设置视口大小
    glClearColor(0.3, 0.3, 0.3, 1.0);
    
    glEnable(GL_DEPTH_TEST); //开启深度测试
    
    camera = Camera(glm::vec3(0.0f, 0.0f, 3.0f));
    
    //    baseShader = [Shader alloc];
    //    [baseShader loadShaders:@"base" frag:@"base"];
    
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
    
    [baseLightShader use];
    
    projMat = glm::perspective(camera.Zoom, float(SCR_WIDTH) / float(SCR_HEIGHT), 0.1f, 100.0f);
    glUniformMatrix4fv(glGetUniformLocation(baseLightShader->program, "proj"), 1, GL_FALSE, glm::value_ptr(projMat));
    
    viewMat = camera.GetViewMatrix();
    glUniformMatrix4fv(glGetUniformLocation(baseLightShader->program, "view"), 1, GL_FALSE, glm::value_ptr(viewMat));
    
    modelMat = glm::mat4();
    modelMat = glm::translate(modelMat, glm::vec3(0.0f, 0.0f, 0.0f));
    modelMat = glm::rotate(modelMat, glm::radians(currentTime), glm::vec3(1.0f, 0.2f, 0.5f));
    glUniformMatrix4fv(glGetUniformLocation(baseLightShader->program, "model"), 1, GL_FALSE, glm::value_ptr(modelMat));
    glUniformMatrix4fv(glGetUniformLocation(baseLightShader->program, "TRmodel"), 1, GL_FALSE, glm::value_ptr(glm::transpose(glm::inverse(modelMat))));
    
    glUniform3fv(glGetUniformLocation(baseLightShader->program, "viewPos"), 1, &camera.Position[0]);
    glUniform1f(glGetUniformLocation(baseLightShader->program, "constant"), 1.0f);
    glUniform1f(glGetUniformLocation(baseLightShader->program, "linear"), 0.009);
    glUniform1f(glGetUniformLocation(baseLightShader->program, "quadratic"), 0.0032);
    
    for (int i = 0; i < 2; i++)
        glUniform3fv(glGetUniformLocation(baseLightShader->program, ("position[" + std::to_string(i) + "]").c_str()), 1, &pointLightPositions[i][0]);

    RenderCube(baseLightShader, boxTexture);
    
    
    [lampShader use];
    glUniformMatrix4fv(glGetUniformLocation(lampShader->program, "proj"), 1, GL_FALSE, glm::value_ptr(projMat));
    glUniformMatrix4fv(glGetUniformLocation(lampShader->program, "view"), 1, GL_FALSE, glm::value_ptr(viewMat));
    glUniform3f(glGetUniformLocation(lampShader->program, "lampColor"), 1.0f, 1.0f, 1.0f);
    for(int i = 0; i < 2; ++i)
    {
        modelMat = glm::mat4();
        modelMat = glm::translate(modelMat, glm::vec3(0.0f, 0.0f, 0.0f));
        modelMat = glm::scale(modelMat, glm::vec3(0.2f));
        glUniformMatrix4fv(glGetUniformLocation(lampShader->program, "model"), 1, GL_FALSE, glm::value_ptr(modelMat));
    
        RenderCube(lampShader);
    }
    
    // RenderQuad(baseShader, boxTexture);
}
#pragma endregion
@end
