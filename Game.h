#pragma once
#include "glhelp.h"

#include "Entity.h"

#include "GL/glew.h"

#include <memory>
#include <vector>
#include <chrono>

class Game
{
public:

    Game( int width, int height );
    ~Game();

    void render();
    void update();

private:

    void draw_scene( glm::mat4 view, glm::mat4 proj );

    GLfloat _width;
    GLfloat _height;
    double _startTime;
    double _currTime;
    GLProgram::ptr_t _program;
    Model _model;
    std::vector< Entity > _entities;

    GLHandle        _skybox_texture;
    GLProgram       _skybox_program;
    GLVertexBuffer  _skybox_buffer;

    GLTexture       _water_dudv;
    GLTexture       _water_normal;
    GLHandles< 2 >  _water_fbo;
    GLHandles< 3 >  _water_textures;
    //GLHandles< 2 >  _water_depths;
    GLHandle        _water_render_buffer;
    GLProgram       _water_program;
    GLVertexBuffer  _water_quad;
    //Model            _water_quad;

};

