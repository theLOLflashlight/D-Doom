#pragma once

#include "GL/glew.h"

#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/matrix_access.hpp"

template< typename T >
constexpr GLenum gl_type_constant( T = {} );

#include "GLHandle.h"
#include "GLProgram.h"
#include "GLShader.h"
#include "GLTexture.h"
#include "GLVertexBuffer.h"

template<>
constexpr GLenum gl_type_constant< GLbyte >( GLbyte )
{
    return GL_BYTE;
}

template<>
constexpr GLenum gl_type_constant< GLubyte >( GLubyte )
{
    return GL_UNSIGNED_BYTE;
}

template<>
constexpr GLenum gl_type_constant< GLshort >( GLshort )
{
    return GL_SHORT;
}

template<>
constexpr GLenum gl_type_constant< GLushort >( GLushort )
{
    return GL_UNSIGNED_SHORT;
}

template<>
constexpr GLenum gl_type_constant< GLint >( GLint )
{
    return GL_INT;
}

template<>
constexpr GLenum gl_type_constant< GLuint >( GLuint )
{
    return GL_UNSIGNED_INT;
}

template<>
constexpr GLenum gl_type_constant< GLfloat >( GLfloat )
{
    return GL_FLOAT;
}

template<>
constexpr GLenum gl_type_constant< GLdouble >( GLdouble )
{
    return GL_DOUBLE;
}