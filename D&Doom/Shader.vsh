//
//  Shader.vsh
//  TestGameSwift
//
//  Created by Andrew Meckling on 2016-02-17.
//  Copyright © 2016 Andrew Meckling. All rights reserved.
//

attribute vec4 Position;
attribute vec3 Normal;
attribute vec2 TexCoordIn;

varying lowp vec4 ColorVarying;
varying vec3 EyeNormal;
varying vec4 EyePos;
varying vec2 TexCoordOut;

uniform mat4 ModelViewProjectionMatrix;
uniform mat3 NormalMatrix;

void main()
{
    EyeNormal = normalize( NormalMatrix * Normal );
    vec3 lightPosition = vec3( 0.0, 0.0, 1.0 );
    vec4 diffuseColor = vec4( 0.4, 0.4, 1.0, 1.0 );
    
    float nDotVP = max( 0.0, dot( EyeNormal, normalize( lightPosition) ) );
                 
    ColorVarying = diffuseColor * nDotVP;
    
    TexCoordOut = TexCoordIn;
    
    gl_Position = ModelViewProjectionMatrix * Position;
}
