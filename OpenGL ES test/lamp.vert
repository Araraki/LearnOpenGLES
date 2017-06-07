//attribute vec3 position;
//attribute vec3 normal;
//attribute vec2 texCoords;

uniform mat4 proj;
uniform mat4 view;
uniform mat4 model;

void main()
{
    gl_Position = proj * view * model * vec4(position, 1.0);
}
