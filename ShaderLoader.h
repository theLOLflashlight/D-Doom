#pragma once

#include "GLHandle.h"

#include "GL/glew.h"

#include <iostream>

class ShaderLoader
{
public:

    GLname program;
    
    ShaderLoader( const char* srcVert, const char* srcFrag );
    ~ShaderLoader();
};

