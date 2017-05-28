varying lowp vec2 TexCoords;
varying lowp vec2 pos;

uniform sampler2D diffuse;

void main()
{
    gl_FragColor = texture2D(diffuse, TexCoords);
    //gl_FragColor = vec4(pos+vec2(0.5,0.5), 0.0, 1.0);
}
