attribute vec3 position;
attribute vec3 normal;
attribute vec2 texCoords;

varying lowp vec3 fragPosition;
varying lowp vec3 Normal;
varying lowp vec2 TexCoords;

uniform mat4 proj;
uniform mat4 view;
uniform mat4 model;
uniform mat4 TRmodel;

void main()
{
    gl_Position = proj * view * model * vec4(position, 1.0);
    fragPosition = vec3(model * vec4(position, 1.0));
    Normal = mat3(TRmodel) * normal;
    TexCoords = texCoords;
}
