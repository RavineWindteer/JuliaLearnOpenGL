cd(@__DIR__)
using Pkg
Pkg.activate("./OPEN_GL/")

using GLFW
using ModernGL

# for passing strings to OpenGL functions that expect pointers to GLchar
# ----------------------------------------------------------------------
glchar_ptr(source) =
    convert(Ptr{UInt8}, pointer([convert(Ptr{GLchar}, pointer(source))]))


# settings
const SCR_WIDTH = 800
const SCR_HEIGHT = 600

const vertexShaderSource = """
    #version 330 core
    layout (location = 0) in vec3 aPos; // the position variable has attribute position 0

    void main()
    {
        gl_Position = vec4(aPos, 1.0); // see how we directly give a vec3 to vec4's constructor
    }
    """

const fragmentShaderSource = """
    #version 330 core
    out vec4 FragColor;
    
    uniform vec4 ourColor; // we set this variable in the OpenGL code.

    void main()
    {
        FragColor = ourColor;
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
    glShaderSource(vertexShader, 1, glchar_ptr(vertexShaderSource), C_NULL)
    glCompileShader(vertexShader)
    # check for shader compile errors
    success = GLint[0]
    infoLog = zeros(GLchar, 512)
    sizei = GLsizei[0]
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, success)
    if success[] == GL_FALSE
        glGetShaderInfoLog(vertexShader, 512, sizei, infoLog)
        println("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n", unsafe_string(pointer(infoLog), sizei[]))
    end
    # fragment shader
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
    glShaderSource(fragmentShader, 1, glchar_ptr(fragmentShaderSource), C_NULL)
    glCompileShader(fragmentShader)
    # check for shader compile errors
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, success)
    if success[] == GL_FALSE
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
    if success[] == GL_FALSE
        glGetProgramInfoLog(shaderProgram, 512, sizei, infoLog)
        println("ERROR::SHADER::PROGRAM::LINKING_FAILED\n", unsafe_string(pointer(infoLog), sizei[]))
    end
    glDeleteShader(vertexShader)
    glDeleteShader(fragmentShader)

    # set up vertex data (and buffer(s)) and configure vertex attributes
    # ------------------------------------------------------------------
    vertecies = GLfloat[
        -0.5f0, -0.5f0, 0.0f0, # left
        0.5f0, -0.5f0, 0.0f0, # right
        0.0f0, 0.5f0, 0.0f0] # top
    
    VBO = GLuint[0]
    VAO = GLuint[0]
    glGenVertexArrays(1, VAO)
    glGenBuffers(1, VBO)
    # bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    glBindVertexArray(VAO[])

    glBindBuffer(GL_ARRAY_BUFFER, VBO[])
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertecies), vertecies, GL_STATIC_DRAW)

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), Ptr{Cvoid}(0))
    glEnableVertexAttribArray(0)

    # note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
    glBindBuffer(GL_ARRAY_BUFFER, 0)

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

        # be sure to activate the shader before any calls to glUniform
        glUseProgram(shaderProgram)

        # update shader uniform
        timeValue = time()
        greenValue = (sin(timeValue) / 2.0f0) + 0.5f0
        vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor")
        glUniform4f(vertexColorLocation, 0.0f0, greenValue, 0.0f0, 1.0f0)

        # render the triangle
        glBindVertexArray(VAO[])
        glDrawArrays(GL_TRIANGLES, 0, 3)

        # glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        # -------------------------------------------------------------------------------
        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    # optional: de-allocate all resources once they've outlived their purpose:
    # ------------------------------------------------------------------------
    glDeleteVertexArrays(1, VAO)
    glDeleteBuffers(1, VBO)
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
