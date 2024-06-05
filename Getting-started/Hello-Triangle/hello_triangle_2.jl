cd(@__DIR__)
using Pkg
Pkg.activate("./OPEN_GL/")

import GLFW
using ModernGL

# for passing strings to OpenGL functions that expect pointers to GLchar
# ----------------------------------------------------------------------
macro glchar_ptr(source)
    :(convert(Ptr{UInt8}, pointer([convert(Ptr{GLchar}, pointer($source))])))
end


# settings
const SCR_WIDTH = 800
const SCR_HEIGHT = 600

const vertexShaderSource = """
    #version 330 core
    layout (location = 0) in vec3 aPos;

    void main()
    {
        gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    }
    """

const fragmentShaderSource = """
    #version 330 core
    out vec4 FragColor;

    void main()
    {
        FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
    }
    """

function main()
    # glfw: initialize and configure
    # ------------------------------
    GLFW.Init()
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 3)
    GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)

    @static if Sys.isapple()
        GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, GL_TRUE)
    end

    # glfw window creation
    # --------------------
    window = GLFW.CreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL")
    if window == C_NULL
        GLFW.Terminate()
        error("Failed to create GLFW window")
    end
    GLFW.MakeContextCurrent(window)
    GLFW.SetFramebufferSizeCallback(window, framebuffer_size_callback)


    # build and compile our shader program
    # ------------------------------------
    # vertex shader
    vertexShader = glCreateShader(GL_VERTEX_SHADER)
    glShaderSource(vertexShader, 1, @glchar_ptr(vertexShaderSource), C_NULL)
    glCompileShader(vertexShader)
    # check for shader compile errors
    success = GLint[0]
    infoLog = zeros(GLchar, 512)
    sizei = GLsizei[0]
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, success)
    if success[] == 0
        glGetShaderInfoLog(vertexShader, 512, sizei, infoLog)
        println("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n", unsafe_string(pointer(infoLog), sizei[]))
    end
    # fragment shader
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
    glShaderSource(fragmentShader, 1, @glchar_ptr(fragmentShaderSource), C_NULL)
    glCompileShader(fragmentShader)
    # check for shader compile errors
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, success)
    if success[] == 0
        glGetShaderInfoLog(fragmentShader, 512, sizei, infoLog)
        println("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n", unsafe_string(pointer(infoLog), sizei[]))
    end
    # link shaders
    shaderProgram = glCreateProgram()
    glAttachShader(shaderProgram, vertexShader)
    glAttachShader(shaderProgram, fragmentShader)
    glLinkProgram(shaderProgram)
    # check for linking errors
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, success)
    if success[] == 0
        glGetProgramInfoLog(shaderProgram, 512, sizei, infoLog)
        println("ERROR::SHADER::PROGRAM::LINKING_FAILED\n", unsafe_string(pointer(infoLog), sizei[]))
    end
    glDeleteShader(vertexShader)
    glDeleteShader(fragmentShader)

    # set up vertex data (and buffer(s)) and configure vertex attributes
    # ------------------------------------------------------------------
    vertecies = GLfloat[
        0.5f0, 0.5f0, 0.0f0, # top right
        0.5f0, -0.5f0, 0.0f0, # bottom right
        -0.5f0, -0.5f0, 0.0f0, # bottom left
        -0.5f0, 0.5f0, 0.0f0] # top left
    
    indices = GLuint[ # note that we start from 0!
        0, 1, 3, # first triangle
        1, 2, 3] # second triangle
    
    VBO = GLuint[0]
    VAO = GLuint[0]
    EBO = GLuint[0]
    glGenVertexArrays(1, VAO)
    glGenBuffers(1, VBO)
    glGenBuffers(1, EBO)
    # bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    glBindVertexArray(VAO[])

    glBindBuffer(GL_ARRAY_BUFFER, VBO[])
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertecies), vertecies, GL_STATIC_DRAW)

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO[])
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW)

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), Ptr{Cvoid}(0))
    glEnableVertexAttribArray(0)

    # note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
    glBindBuffer(GL_ARRAY_BUFFER, 0)

    # remember: do NOT unbind the EBO while a VAO is active as the bound element buffer object IS stored in the VAO; keep the EBO bound.
    #glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)

    # You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    # VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    glBindVertexArray(0)

    # uncomment this call to draw in wireframe polygons.
    #glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

    # render loop
    # -----------
    while !GLFW.WindowShouldClose(window)
        # input
        # -----
        processInput(window)

        # render
        # ------
        glClearColor(0.2f0, 0.3f0, 0.3f0, 1.0f0)
        glClear(GL_COLOR_BUFFER_BIT)

        # draw our first triangle
        glUseProgram(shaderProgram)
        glBindVertexArray(VAO[]) # seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
        #glDrawArrays(GL_TRIANGLES, 0, 3)
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, Ptr{Cvoid}(0))
        #glBindVertexArray(0) # no need to unbind it every time

        # glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        # -------------------------------------------------------------------------------
        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    # optional: de-allocate all resources once they've outlived their purpose:
    # ------------------------------------------------------------------------
    glDeleteVertexArrays(1, VAO)
    glDeleteBuffers(1, VBO)
    glDeleteBuffers(1, EBO)
    glDeleteProgram(shaderProgram)

    # glfw: terminate, clearing all previously allocated GLFW resources.
    # ------------------------------------------------------------------
    GLFW.Terminate()
end

# process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
# ---------------------------------------------------------------------------------------------------------
function processInput(window)
    if GLFW.GetKey(window, GLFW.KEY_ESCAPE)
        GLFW.SetWindowShouldClose(window, true)
    end
end

# glfw: whenever the window size changed (by OS or user resize) this callback function executes
# ---------------------------------------------------------------------------------------------
function framebuffer_size_callback(window, width, height)
    # make sure the viewport matches the new window dimensions; note that width and
    # height will be significantly larger than specified on retina displays.
    glViewport(0, 0, width, height)
end


main()
