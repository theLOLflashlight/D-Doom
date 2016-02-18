//
//  Shader.fsh
//  TestGameSwift
//
//  Created by Andrew Meckling on 2016-02-17.
//  Copyright © 2016 Andrew Meckling. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
