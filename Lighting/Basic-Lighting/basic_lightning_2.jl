cd(@__DIR__)
using Pkg
Pkg.activate("./OPEN_GL/")

using GLFW
using ModernGL

# There isn't yet a wraper for either glm or stb_image in julia:
# gl_algebra.jl implements linear algebra types and functions ready for OpenGL
# with an API similar to glm;
# image_loader.jl defines a custom function load_img! that works similar to
# stbi_load, and that loads the image in the right format for OpenGL.
include("camera.jl")
include("gl_algebra.jl")
include("image_loader.jl")
include("shader.jl")


# settings
const SCR_WIDTH = 800
const SCR_HEIGHT = 600

# camera
camera = Camera(Vec3(0.0f0, 0.0f0,  3.0f0))
lastX = Float32(SCR_WIDTH) / 2.0f0
lastY = Float32(SCR_HEIGHT) / 2.0f0
firstMouse = true

# timing
deltaTime = 0.0f0
lastFrame = 0.0f0

# lighting
lightPos = Vec3(1.2f0, 1.0f0, 2.0f0)

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
    GLFW.SetCursorPosCallback(window, mouse_callback)
    GLFW.SetScrollCallback(window, scroll_callback)

    # tell GLFW to capture our mouse
    GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_DISABLED)

    # configure global opengl state
    # -----------------------------
    glEnable(GL_DEPTH_TEST)

    # build and compile our shader program
    # ------------------------------------
    lightingShader = Shader("./shaders/2.2.colors.vs", "./shaders/2.2.colors.fs")
    lightCubeShader = Shader("./shaders/2.2.light_cube.vs", "./shaders/2.2.light_cube.fs")

    # set up vertex data (and buffer(s)) and configure vertex attributes
    # ------------------------------------------------------------------
    vertecies = GLfloat[
        -0.5f0, -0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0,
        0.5f0, -0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0, 
        0.5f0,  0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0, 
        0.5f0,  0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0, 
        -0.5f0,  0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0, 
        -0.5f0, -0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0, 

        -0.5f0, -0.5f0,  0.5f0,  0.0f0,  0.0f0, 1.0f0,
        0.5f0, -0.5f0,  0.5f0,  0.0f0,  0.0f0, 1.0f0,
        0.5f0,  0.5f0,  0.5f0,  0.0f0,  0.0f0, 1.0f0,
        0.5f0,  0.5f0,  0.5f0,  0.0f0,  0.0f0, 1.0f0,
        -0.5f0,  0.5f0,  0.5f0,  0.0f0,  0.0f0, 1.0f0,
        -0.5f0, -0.5f0,  0.5f0,  0.0f0,  0.0f0, 1.0f0,

        -0.5f0,  0.5f0,  0.5f0, -1.0f0,  0.0f0,  0.0f0,
        -0.5f0,  0.5f0, -0.5f0, -1.0f0,  0.0f0,  0.0f0,
        -0.5f0, -0.5f0, -0.5f0, -1.0f0,  0.0f0,  0.0f0,
        -0.5f0, -0.5f0, -0.5f0, -1.0f0,  0.0f0,  0.0f0,
        -0.5f0, -0.5f0,  0.5f0, -1.0f0,  0.0f0,  0.0f0,
        -0.5f0,  0.5f0,  0.5f0, -1.0f0,  0.0f0,  0.0f0,

        0.5f0,  0.5f0,  0.5f0,  1.0f0,  0.0f0,  0.0f0,
        0.5f0,  0.5f0, -0.5f0,  1.0f0,  0.0f0,  0.0f0,
        0.5f0, -0.5f0, -0.5f0,  1.0f0,  0.0f0,  0.0f0,
        0.5f0, -0.5f0, -0.5f0,  1.0f0,  0.0f0,  0.0f0,
        0.5f0, -0.5f0,  0.5f0,  1.0f0,  0.0f0,  0.0f0,
        0.5f0,  0.5f0,  0.5f0,  1.0f0,  0.0f0,  0.0f0,

        -0.5f0, -0.5f0, -0.5f0,  0.0f0, -1.0f0,  0.0f0,
        0.5f0, -0.5f0, -0.5f0,  0.0f0, -1.0f0,  0.0f0,
        0.5f0, -0.5f0,  0.5f0,  0.0f0, -1.0f0,  0.0f0,
        0.5f0, -0.5f0,  0.5f0,  0.0f0, -1.0f0,  0.0f0,
        -0.5f0, -0.5f0,  0.5f0,  0.0f0, -1.0f0,  0.0f0,
        -0.5f0, -0.5f0, -0.5f0,  0.0f0, -1.0f0,  0.0f0,

        -0.5f0,  0.5f0, -0.5f0,  0.0f0,  1.0f0,  0.0f0,
        0.5f0,  0.5f0, -0.5f0,  0.0f0,  1.0f0,  0.0f0,
        0.5f0,  0.5f0,  0.5f0,  0.0f0,  1.0f0,  0.0f0,
        0.5f0,  0.5f0,  0.5f0,  0.0f0,  1.0f0,  0.0f0,
        -0.5f0,  0.5f0,  0.5f0,  0.0f0,  1.0f0,  0.0f0,
        -0.5f0,  0.5f0, -0.5f0,  0.0f0,  1.0f0,  0.0f0]
    
    VBO = GLuint[0]
    cubeVAO = GLuint[0]
    glGenVertexArrays(1, cubeVAO)
    glGenBuffers(1, VBO)

    glBindBuffer(GL_ARRAY_BUFFER, VBO[])
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertecies), vertecies, GL_STATIC_DRAW)

    glBindVertexArray(cubeVAO[])

    # position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), Ptr{Cvoid}(0))
    glEnableVertexAttribArray(0)

    # normal attribute
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), Ptr{Cvoid}(3 * sizeof(GLfloat)))
    glEnableVertexAttribArray(1)


    # second, configure the light's VAO (VBO stays the same; the vertices are the same for the light object which is also a 3D cube)
    lightCubeVAO = GLuint[0]
    glGenVertexArrays(1, lightCubeVAO)
    glBindVertexArray(lightCubeVAO[])

    # we only need to bind to the VBO (to link it with glVertexAttribPointer), no need to fill it; the VBO's data already contains all we need (it's already bound, but we do it again for educational purposes)
    glBindBuffer(GL_ARRAY_BUFFER, VBO[])

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), Ptr{Cvoid}(0))
    glEnableVertexAttribArray(0)


    # set initial time of the last frame
    # ----------------------------------
    lastFrame = time()

    # render loop
    # -----------
    while !GLFW.WindowShouldClose(window)
        # per-frame time logic
        # --------------------
        currentFrame = time()
        global deltaTime = currentFrame - lastFrame
        global lastFrame = currentFrame

        # input
        # -----
        processInput(window)

        # render
        # ------
        glClearColor(0.1f0, 0.1f0, 0.1f0, 1.0f0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        # be sure to activate shader when setting uniforms/drawing objects
        use(lightingShader)
        setVec3(lightingShader, "objectColor", Vec3(1.0f0, 0.5f0, 0.31f0))
        setVec3(lightingShader, "lightColor", Vec3(1.0f0, 1.0f0, 1.0f0))
        setVec3(lightingShader, "lightPos", lightPos)
        setVec3(lightingShader, "viewPos", camera.Position)

        # view/projection transformations
        projection = perspective(radians(camera.Zoom), 
            Float32(SCR_WIDTH)/Float32(SCR_HEIGHT), 0.1f0, 100.0f0)
        view = getViewMatrix(camera)
        setMat4(lightingShader, "projection", projection)
        setMat4(lightingShader, "view", view)

        # world transformation
        model = Mat4(1.0f0)
        setMat4(lightingShader, "model", model)

        # render the cube
        glBindVertexArray(cubeVAO[])
        glDrawArrays(GL_TRIANGLES, 0, 36)

        # also draw the lamp object
        use(lightCubeShader)
        setMat4(lightCubeShader, "projection", projection)
        setMat4(lightCubeShader, "view", view)
        model = Mat4(1.0f0)
        model = translate(model, lightPos)
        model = scale(model, Vec3(0.2f0)) # a smaller cube
        setMat4(lightCubeShader, "model", model)

        glBindVertexArray(lightCubeVAO[])
        glDrawArrays(GL_TRIANGLES, 0, 36)


        # glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        # -------------------------------------------------------------------------------
        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    # optional: de-allocate all resources once they've outlived their purpose:
    # ------------------------------------------------------------------------
    glDeleteVertexArrays(1, cubeVAO)
    glDeleteVertexArrays(1, lightCubeVAO)
    glDeleteBuffers(1, VBO)
    delete(lightingShader)
    delete(lightCubeShader)

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

    cameraSpeed = 2.5f0 * deltaTime
    if GLFW.GetKey(window, GLFW.KEY_W)
        processKeyboard(camera, FORWARD, deltaTime)
    end
    if GLFW.GetKey(window, GLFW.KEY_S)
        processKeyboard(camera, BACKWARD, deltaTime)
    end
    if GLFW.GetKey(window, GLFW.KEY_A)
        processKeyboard(camera, LEFT, deltaTime)
    end
    if GLFW.GetKey(window, GLFW.KEY_D)
        processKeyboard(camera, RIGHT, deltaTime)
    end
end

# glfw: whenever the window size changed (by OS or user resize) this callback function executes
# ---------------------------------------------------------------------------------------------
function framebuffer_size_callback(window, width, height)
    # make sure the viewport matches the new window dimensions; note that width and
    # height will be significantly larger than specified on retina displays.
    glViewport(0, 0, width, height)
end

# glfw: whenever the mouse moves, this callback is called
# -------------------------------------------------------
function mouse_callback(window, xposIn, yposIn)
    xpos = Float32(xposIn)
    ypos = Float32(yposIn)

    if firstMouse
        global lastX = xpos
        global lastY = ypos
        global firstMouse = false
    end

    xoffset = xpos - lastX
    yoffset = lastY - ypos # reversed since y-coordinates go from bottom to top

    global lastX = xpos
    global lastY = ypos

    processMouseMovement(camera, xoffset, yoffset)
    nothing
end

# glfw: whenever the mouse scroll wheel scrolls, this callback is called
# ----------------------------------------------------------------------
function scroll_callback(window, xoffset, yoffset)
    processMouseScroll(camera, yoffset)
end


main()
