varying     vec3        vEyePosition;
varying     vec3        vEyeNormal;
varying     vec2        vTexCoord;
varying     vec4        vSpecColor;

uniform     sampler2D   uTexture;
uniform     vec4        uColor;
uniform     vec3        uSunPosition;
//uniform     vec3        uLightPosition;

uniform     vec4        uAmbientColor;
uniform     vec4        uDiffuseColor;
uniform     vec4        uSpecularColor;
uniform     float       uShininess;

void main()
{
    vec4 Ka = uAmbientColor;

    vec3 N = normalize( vEyeNormal );
    vec4 Kd = uDiffuseColor * max( 0.0, dot( N, normalize( uSunPosition ) ) );

    vec3 E = normalize( -vEyePosition );
    vec3 L = normalize( uSunPosition - vEyePosition );
    vec3 H = normalize( L + E );

    float Ns = pow( max( dot( N, H ), 0.0 ), uShininess );
    vec4 Ks = Ns * uSpecularColor;
    if ( dot( L, N ) < 0.0 )
    {
        Ks = vec4( 0, 0, 0, 1 );
    }

    gl_FragColor = (Ka + Kd + Ks) * texture2D( uTexture, vTexCoord );
    gl_FragColor = mix( gl_FragColor, vec4( uColor.rgb, 1 ), uColor.a );
    //gl_FragColor = mix( vColor, gl_FragColor, 0.9 );
    gl_FragColor.a = 1.0;
    //gl_FragColor = uColor;
}