attribute vec4 Position;
attribute vec3 Normal;
attribute vec2 TexCoordIn;

varying vec4 ColorVarying;
varying vec3 EyeNormal;
varying vec4 EyePosition;
varying vec2 TexCoordOut;

uniform mat4 Transform;
uniform mat3 NormalTransform;

void main()
{
    EyeNormal = normalize( NormalTransform * Normal );
    vec3 lightPosition = vec3( 0, 0, 1 );
    vec4 diffuseColor = vec4( 0.4, 0.4, 1.0, 1.0 );

    float nDotVP = max( 0.0, dot( EyeNormal, normalize( lightPosition ) ) );

    ColorVarying = diffuseColor * nDotVP;

    TexCoordOut = TexCoordIn;

    gl_Position = Transform * Position;
}