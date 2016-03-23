//
//  Shader.fsh
//
//  Created by Borna Noureddin.
//  Copyright (c) 2015 BCIT. All rights reserved.
//
precision mediump float;

varying vec3 EyeNormal;
varying vec4 EyePos;
varying vec2 TexCoordOut;
/* set up a uniform sampler2D to get texture */
uniform sampler2D Texture;

/* set up uniforms for lighting parameters */
uniform vec3 FlashlightPosition;
uniform vec3 DiffuseLightPosition;
uniform vec4 DiffuseComponent;
uniform float Shininess;
uniform vec4 SpecularComponent;
uniform vec4 AmbientComponent;

void main()
{
    /*
    vec4 ambient = AmbientComponent;
    
    
    vec3 N = normalize( EyeNormal );
    float nDotVP = max( 0.0, dot( N, normalize( DiffuseLightPosition ) ) );
    vec4 diffuse = DiffuseComponent * nDotVP;
    
    vec3 E = normalize( -EyePos.xyz );
    vec3 L = normalize( FlashlightPosition - EyePos.xyz );
    vec3 H = normalize( L + E );
    
    float Ks = pow( max( dot( N, H ), 0.0 ), Shininess );
    vec4 specular = Ks * SpecularComponent;
    
    if ( dot( L, N ) < 0.0 )
    {
        specular = vec4( 0.0, 0.0, 0.0, 1.0 );
    }
    
    // add ambient and specular components here as in:
    //gl_FragColor = (ambient + diffuse + specular) * texture2D(texture, texCoordOut);
     
    gl_FragColor = (ambient + diffuse + specular) * texture2D( Texture, TexCoordOut );
    gl_FragColor.a = 1.0;
    */
    
        vec3 eyeNormal = normalize(normalMatrix * normal);
        vec3 lightPosition = vec3(0.0, 0.0, 1.0);
        vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
    
        float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
        colorVarying = diffuseColor * nDotVP;
    
        gl_Position = modelViewProjectionMatrix * position;
}
