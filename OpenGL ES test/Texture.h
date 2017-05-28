//
//  Texture.h
//  OpenGL ES test
//
//  Created by Stanley Wang on 2017/5/25.
//  Copyright © 2017年 Stanley Wang. All rights reserved.
//

#ifndef Texture_h
#define Texture_h

#import <Foundation/Foundation.h>
#include <OpenGLES/ES3/gl.h>

@interface Texture : NSObject 

@end

@implementation Texture
+ (GLuint)setupTexture:(NSString *)fileName
{
    CGImageRef image = [UIImage imageNamed:fileName].CGImage;
    if (!image) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    GLubyte *bits = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(bits, width, height, 8, width*4,CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), image);
    CGContextRelease(spriteContext);
    
    if((bits == 0) || (width == 0) || (height == 0))
    {
        NSLog(@"Image %@ data error", fileName);
        return -1;
    }
    
    GLuint texID = -1;
    glGenTextures(1, &texID);
    
    glBindTexture(GL_TEXTURE_2D, texID);
    //glTexImage2D(GL_TEXTURE_2D, level, internal_format, width, height, border, image_format, GL_UNSIGNED_BYTE, bits);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, float(width), float(height), 0, GL_RGBA, GL_UNSIGNED_BYTE, bits);
    
    free(bits);
    
    return texID;
}
/*
 
 CGImageRef image = [UIImage imageNamed:fileName].CGImage;
 if (!image) {
 NSLog(@"Failed to load image %@", fileName);
 exit(1);
 }
 
 size_t width = CGImageGetWidth(image);
 size_t height = CGImageGetHeight(image);
 
 GLubyte *bits = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
 
 CGContextRef spriteContext = CGBitmapContextCreate(bits, width, height, 8, width*4,CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
 CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), image);
 CGContextRelease(spriteContext);
 
 if((bits == 0) || (width == 0) || (height == 0))
 {
 NSLog(@"Image %@ data error", fileName);
 return -1;
 }
 
 
 GLuint texID = -1;
 glGenTextures(1, &texID);
 
 glBindTexture(GL_TEXTURE_2D, texID);
 //glTexImage2D(GL_TEXTURE_2D, level, internal_format, width, height, border, image_format, GL_UNSIGNED_BYTE, bits);
 glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, float(width), float(height), 0, GL_RGBA, GL_UNSIGNED_BYTE, bits);
 
 free(bits);
 
 return texID;
 
 */

/*
 void *temp = malloc(width * height * 2);
 uint32_t *inPixel32  = (uint32_t *)data;
 uint16_t *outPixel16 = (uint16_t *)temp;
 uint32_t pixelCount = width * height;
 
 #ifdef __ARM_NEON__
 for(uint32_t i=0; i<pixelCount; i+=8, inPixel32+=8, outPixel16+=8)
 {
 uint8x8x4_t rgba  = vld4_u8((const uint8_t *)inPixel32);
 
 uint8x8_t r = vshr_n_u8(rgba.val[0], 3);
 uint8x8_t g = vshr_n_u8(rgba.val[1], 2);
 uint8x8_t b = vshr_n_u8(rgba.val[2], 3);
 
 uint16x8_t r16 = vmovl_u8(r);
 uint16x8_t g16 = vmovl_u8(g);
 uint16x8_t b16 = vmovl_u8(b);
 
 r16 = vshlq_n_u16(r16, 11);
 g16 = vshlq_n_u16(g16, 5);
 
 uint16x8_t rg16 = vorrq_u16(r16, g16);
 uint16x8_t result = vorrq_u16(rg16, b16);
 
 vst1q_u16(outPixel16, result);
 }
 #else
 for(uint32_t i=0; i<pixelCount; i++, inPixel32++)
 {
 uint32_t r = (((*inPixel32 >> 0)  & 0xFF) >> 3);
 uint32_t g = (((*inPixel32 >> 8)  & 0xFF) >> 2);
 uint32_t b = (((*inPixel32 >> 16) & 0xFF) >> 3);
 
 *outPixel16++ = (r << 11) | (g << 5) | (b << 0);
 }
 #endif
 
 free(data);
 data = temp;
 
 */
@end

#endif /* Texture_h */
