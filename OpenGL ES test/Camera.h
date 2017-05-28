#pragma once
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

const GLfloat YAW			= -90.0f;
const GLfloat PITCH			= 0.0f;
const GLfloat ROLL			= 0.0f;
const GLfloat SPEED			= 3.0f;
const GLfloat SENSITIVTY	= 0.05f;
const GLfloat ZOOM			= 45.0f;

class Camera
{
public:
	glm::vec3 Position;
	glm::vec3 Front;
	glm::vec3 Up;
	glm::vec3 Right;

	glm::vec3 WorldUp;
    glm::vec3 WorldFront;
    glm::vec3 WorldRight;

	GLfloat Yaw;
	GLfloat Pitch;
    GLfloat Roll;

	GLfloat MovementSpeed;
	GLfloat Zoom;

	Camera(glm::vec3 pos = glm::vec3(0.0f, 0.0f, 0.0f), glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f),
		   GLfloat yaw = YAW, GLfloat pitch = PITCH, GLfloat roll = ROLL)
		: Front(glm::vec3(0.0f, 0.0f, -1.0f)), Zoom(ZOOM)
	{
		this->Position = pos;
		this->WorldUp = up;
		this->Yaw = yaw;
		this->Pitch = pitch;
        this->Roll = roll;
		this->updateCameraVectors();
	}

	glm::mat4 GetViewMatrix() const
	{
		return glm::lookAt(this->Position, this->Position + this->Front, this->Up);
	}

	void ProcessGyroMovement(GLfloat eX, GLfloat eY, GLfloat eZ)
	{
        this->Yaw += eX;
        this->Pitch += eY;
        this->Roll += eZ;
        
        //this->WorldUp = glm::vec3(-gX, -gY, -gZ);

		this->updateCameraVectors();
	}

private:
	void updateCameraVectors()
	{
		glm::vec3 front;

		front.x = cos(glm::radians(this->Yaw)) * cos(glm::radians(this->Pitch));
		front.y = sin(glm::radians(this->Pitch));
		front.z = sin(glm::radians(this->Yaw)) * cos(glm::radians(this->Pitch));

		this->Front = glm::normalize(front);
		this->Right = glm::normalize(glm::cross(this->Front, this->WorldUp));
		this->Up = glm::normalize(glm::cross(this->Right, this->Front));
	}
};

