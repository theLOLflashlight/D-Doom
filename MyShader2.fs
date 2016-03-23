varying vec3 EyeNormal;
varying vec4 EyePosition;
varying vec2 TexCoordOut;

uniform sampler2D Texture;

uniform vec3 FlashlightPosition;
uniform vec3 DiffuseLightPosition;
uniform vec4 DiffuseComponent;
uniform float Shininess;
uniform vec4 SpecularComponent;
uniform vec4 AmbientComponent;

void main()
{
    vec4 ambient = AmbientComponent;

    vec3 N = normalize( EyeNormal );
    float nDotVP = max( 0.0, dot( N, normalize( DiffuseLightPosition ) ) );
    vec4 diffuse = DiffuseComponent * nDotVP;

    vec3 E = normalize( -EyePosition.xyz );
    vec3 L = normalize( FlashlightPosition - EyePosition.xyz );
    vec3 H = normalize( L + E );

    float Ks = pow( max( dot( N, H ), 0.0 ), Shininess );
    vec4 specular = Ks * SpecularComponent;

    if ( dot( L, N ) < 0.0 )
    {
        specular = vec4( 0, 0, 0, 1 );
    }

    gl_FragColor = (ambient + diffuse + specular) * texture2D( Texture, TexCoordOut );
    gl_FragColor.a = 1.0;
}