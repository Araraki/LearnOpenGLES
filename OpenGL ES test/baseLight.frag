#define NR_POINT_LIGHT 2
varying lowp vec3 fragPosition;
varying lowp vec3 Normal;
varying lowp vec2 TexCoords;

uniform sampler2D diffuseTex;
uniform lowp vec3 viewPos;

uniform lowp vec3 position[NR_POINT_LIGHT];
uniform lowp float constant;
uniform lowp float linear;
uniform lowp float quadratic;

lowp vec3 CalcPointLight(int i, lowp vec3 normal, lowp vec3 fragPos, lowp vec3 viewDir);
void main()
{
	lowp vec3 norm = normalize(Normal);
	lowp vec3 viewDir = normalize(viewPos - fragPosition);
	lowp vec3 result = vec3(0.0, 0.0, 0.0);

    result = vec3(0.12) * texture2D(diffuseTex, TexCoords).rgb;

	for(int i = 0; i < NR_POINT_LIGHT; ++i)
		result += CalcPointLight(i, norm, fragPosition, viewDir);
    
	gl_FragColor = vec4(result, 1.0);
}

lowp vec3 CalcPointLight(int i, lowp vec3 normal, lowp vec3 fragPos, lowp vec3 viewDir)
{
	lowp vec3 lightDir = normalize(position[i] - fragPos);
	lowp float diff = max(dot(normal, lightDir), 0.0);

    lowp float dist    = length(position[i] - fragPos);
    lowp float attenuation = 1.0 / (constant + linear * dist + quadratic * (dist * dist));

    lowp vec3 result  = texture2D(diffuseTex, TexCoords).rgb * diff * attenuation;

    return result;
}
