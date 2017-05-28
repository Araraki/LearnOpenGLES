//
//  Shader.h
//  OpenGL ES test
//
//  Created by Stanley Wang on 2017/5/25.
//  Copyright © 2017年 Stanley Wang. All rights reserved.
//

#ifndef Shader_h
#define Shader_h

#import <Foundation/Foundation.h>
#include <OpenGLES/ES3/gl.h>

@interface Shader : NSObject
{
@public
    GLuint program;
}
@end

@implementation Shader
- (void) use
{
    if(program != -1)
        glUseProgram(program);
}

- (void) loadShaders:(NSString *)vert frag:(NSString *)frag
{
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:vert ofType:@"vert"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:frag ofType:@"frag"];
    
    GLuint vertShader, fragShader;
    program = glCreateProgram();
    
    [self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertFile];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragFile];
    
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    
    glLinkProgram(program);
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE)
    {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        return ;
    }
    else
        NSLog(@"link ok");
    
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    
    return ;
}


- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    GLint success;
    GLchar infoLog[512];
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &success);
    if (!success)
    {
        glGetShaderInfoLog(*shader, 512, nullptr, infoLog);
        NSArray *array = [file componentsSeparatedByString:@"/"];
        NSLog(@"ERROR::SHADER::%@::COMPILATION_FAILED\n%s", array[array.count-1], infoLog);
    }
}

@end
#endif /* Shader_h */
