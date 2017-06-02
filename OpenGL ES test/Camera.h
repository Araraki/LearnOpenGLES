#pragma once
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

const GLfloat YAW			= 0.0f;
const GLfloat ROLL			= 90.0f;
const GLfloat PITCH			= 0.0f;
const GLfloat ROLL_CORRECTION = 3.14159265 /2.0;


const GLfloat ZOOM			= 45.0f;

const GLKVector3 FRONT = {0.0f, 0.0f, -1.0f};
const GLKVector3 UP = {0.0f, 1.0f, 0.0f};
const GLKVector3 RIGHT = {0.0f, 0.0f, 1.0f};

class Camera
{
public:
	GLKVector3 Position;
    
    GLKVector3 Front;
    GLKVector3 Right;
    GLKVector3 Up;

	GLKVector3 WorldUp;
    
	GLfloat Yaw;
	GLfloat Roll;
    GLfloat Pitch;

	GLfloat Zoom;

    Camera(GLKVector3 pos = {0.0f, 0.0f, 0.0f}, GLKVector3 up = {0.0f, 1.0f, 0.0f},
		   GLfloat yaw = YAW, GLfloat roll = ROLL, GLfloat pitch = PITCH)
		: Front(FRONT), Up(UP), Zoom(ZOOM)
	{
		Position = pos;
		WorldUp = up;
        
		Yaw = yaw;
		Roll = roll;
        Pitch = pitch;
        
		updateCameraVectors();
	}

	GLKMatrix4 GetViewMatrix() const
	{
        GLKVector3 center = GLKVector3Add(Position, Front);
		return GLKMatrix4MakeLookAt(Position.x,   Position.y,   Position.z,
                                    center.x,     center.y,     center.z,
                                    Up.x,         Up.y,         Up.z        );
	}

	void SetYRP(GLfloat yaw, GLfloat roll , GLfloat pitch)
	{
        Yaw = -yaw;
        Roll = -roll;
        Pitch = pitch;
        
        updateCameraVectors();
	}

private:
    
	void updateCameraVectors()
	{
		GLKVector3 front;

		front.x = cos(Yaw) * cos(Roll);
		front.y = sin(Roll);
		front.z = sin(Yaw) * cos(Roll);

		Front = GLKVector3Normalize(front);
        Right = GLKVector3Normalize(GLKVector3CrossProduct(Front, WorldUp));
		Up = GLKVector3Normalize(GLKVector3CrossProduct(Right, Front));
	}
};

