#pragma once
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <CoreMotion/CoreMotion.h>

const GLfloat YAW			= 0.0f;
const GLfloat ROLL			= 90.0f;
const GLfloat PITCH			= 0.0f;

const GLfloat ZOOM			= 45.0f;

const GLKVector3 FRONT = {0.0f, 0.0f, -1.0f};
const GLKVector3 UP = {-1.0f, 0.0f, 0.0f};
//const GLKVector3 RIGHT = {0.0f, 0.0f, 1.0f};

const GLKMatrix4 baseRotation = GLKMatrix4MakeRotation(-M_PI_2, 0.0f, 0.0f, 1.0f);

class Camera
{
public:
	GLKVector3 Position;
    
//    GLKVector3 Front;
//    GLKVector3 Right;
//    GLKVector3 Up;

	GLKVector3 WorldUp;
    
	GLfloat Yaw;
	GLfloat Roll;
    GLfloat Pitch;

	GLfloat Zoom;
    
    CMMotionManager *motionManager;

    Camera(GLKVector3 pos = {0.0f, 0.0f, 0.0f}, GLKVector3 worldup = {-1.0f, 0.0f, 0.0f},
		   GLfloat yaw = YAW, GLfloat roll = ROLL, GLfloat pitch = PITCH) : Zoom(ZOOM)
	{
		Position = pos;
		WorldUp = worldup;
        
		Yaw = yaw;
		Roll = roll;
        Pitch = pitch;
	}

    void InitCameraCtrl()
    {
        motionManager = [[CMMotionManager alloc] init];
        motionManager.deviceMotionUpdateInterval = 0.005f;
        [motionManager startDeviceMotionUpdates];
    }
    
	GLKMatrix4 GetViewMatrix() const
	{
        CMRotationMatrix a = motionManager.deviceMotion.attitude.rotationMatrix;
        GLKMatrix4 rotateMat4 = GLKMatrix4Make(a.m11,   a.m21,  a.m31,  0.0f,
                                               a.m12,   a.m22,  a.m32,  0.0f,
                                               a.m13,   a.m23,  a.m33,  0.0f,
                                               0.0f,    0.0f,   0.0f,   1.0f);
        NSLog(@"\n%.4f, %.4f, %.4f\n%.4f, %.4f, %.4f\n%.4f, %.4f, %.4f", a.m11, a.m21, a.m31, a.m12, a.m22, a.m32, a.m13, a.m23,  a.m33);
        //GLKMatrix4 transMat4 = GLKMatrix4MakeTranslation(-Position.x, -Position.y, -Position.z);
        GLKMatrix4 transMat4 = GLKMatrix4Make(1.0, 0.0, 0.0, -Position.x,
                                              0.0, 1.0, 0.0, -Position.y,
                                              0.0, 0.0, 1.0, -Position.z,
                                              0.0, 0.0, 0.0, 1.0);
        GLKMatrix4 transMat42 = GLKMatrix4Make(1.0, 0.0, 0.0, 0.0,
                                              0.0, 1.0, 0.0, 0.0,
                                              0.0, 0.0, 1.0, 0.0,
                                              -Position.x, -Position.y, -Position.z, 1.0);
        //GLKVector3 Front = GLKQuaternionRotateVector3(GLKQuaternionMakeWithMatrix4(viewMat4), FRONT);
        //GLKVector3 Up = GLKQuaternionRotateVector3(GLKQuaternionMakeWithMatrix4(viewMat4), UP);

        //GLKMatrix4 viewMat4 = GLKMatrix4Multiply(baseRotation, rotateMat4);
        //viewMat4 = GLKMatrix4Multiply(transMat4, viewMat4);
        //GLKMatrix4 viewMat4 = GLKMatrix4Multiply(GLKMatrix4Multiply(GLKMatrix4Identity, baseRotation), rotateMat4);
        GLKMatrix4 viewMat4 = GLKMatrix4Multiply(GLKMatrix4Multiply(GLKMatrix4Multiply(GLKMatrix4Identity, baseRotation), rotateMat4), transMat42);
//        viewMat4= GLKMatrix4MakeLookAt(Position.x, Position.y, Position.z,
//                                       Position.x + Front.x, Position.y + Front.y, Position.z + Front.z,
//                                       Up.x, Up.y, Up.z);
        return viewMat4;
	}
};

/*
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
 
 //        float cRoll = attitude.roll;
 //        float cPitch = attitude.pitch;
 //
 //        ViewMatrix = GLKMatrix4RotateX(ViewMatrix, -cRoll);
 //        ViewMatrix = GLKMatrix4RotateY(ViewMatrix, cPitch*3);
 
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
 */


/*
 motionManager = [[CMMotionManager alloc] init];
 
 motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
 motionManager.gyroUpdateInterval = 1.0f / 60.0;
 motionManager.showsDeviceMovementDisplay = YES;
 
 [motionManager startDeviceMotionUpdates];
 [motionManager startGyroUpdates];
 [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
 */
