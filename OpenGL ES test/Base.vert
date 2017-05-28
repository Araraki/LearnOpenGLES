attribute vec3 position;
attribute vec2 texCoords;

varying lowp vec2 TexCoords;
varying lowp vec2 pos;

void main()
{
    gl_Position = vec4(position, 1.0);
    TexCoords = texCoords;
    pos = position.xy;
}
