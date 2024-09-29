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
startTime = 0.0f0
currentTime = 0.0f0

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
    lightingShader = Shader("./shaders/4.1.materials.vs", "./shaders/4.1.materials.fs")
    lightCubeShader = Shader("./shaders/4.1.light_cube.vs", "./shaders/4.1.light_cube.fs")

    # set up vertex data (and buffer(s)) and configure vertex attributes
    # ------------------------------------------------------------------
    vertecies = GLfloat[
        # positions              # normals               # texture coords
        -0.5f0, -0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0,  0.0f0,  0.0f0,
         0.5f0, -0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0,  1.0f0,  0.0f0,
         0.5f0,  0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0,  1.0f0,  1.0f0,
         0.5f0,  0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0,  1.0f0,  1.0f0,
        -0.5f0,  0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0,  0.0f0,  1.0f0,
        -0.5f0, -0.5f0, -0.5f0,  0.0f0,  0.0f0, -1.0f0,  0.0f0,  0.0f0,

        -0.5f0, -0.5f0,  0.5f0,  0.0f0,  0.0f0,  1.0f0,  0.0f0,  0.0f0,
         0.5f0, -0.5f0,  0.5f0,  0.0f0,  0.0f0,  1.0f0,  1.0f0,  0.0f0,
         0.5f0,  0.5f0,  0.5f0,  0.0f0,  0.0f0,  1.0f0,  1.0f0,  1.0f0,
         0.5f0,  0.5f0,  0.5f0,  0.0f0,  0.0f0,  1.0f0,  1.0f0,  1.0f0,
        -0.5f0,  0.5f0,  0.5f0,  0.0f0,  0.0f0,  1.0f0,  0.0f0,  1.0f0,
        -0.5f0, -0.5f0,  0.5f0,  0.0f0,  0.0f0,  1.0f0,  0.0f0,  0.0f0,

        -0.5f0,  0.5f0,  0.5f0, -1.0f0,  0.0f0,  0.0f0,  1.0f0,  0.0f0,
        -0.5f0,  0.5f0, -0.5f0, -1.0f0,  0.0f0,  0.0f0,  1.0f0,  1.0f0,
        -0.5f0, -0.5f0, -0.5f0, -1.0f0,  0.0f0,  0.0f0,  0.0f0,  1.0f0,
        -0.5f0, -0.5f0, -0.5f0, -1.0f0,  0.0f0,  0.0f0,  0.0f0,  1.0f0,
        -0.5f0, -0.5f0,  0.5f0, -1.0f0,  0.0f0,  0.0f0,  0.0f0,  0.0f0,
        -0.5f0,  0.5f0,  0.5f0, -1.0f0,  0.0f0,  0.0f0,  1.0f0,  0.0f0,

         0.5f0,  0.5f0,  0.5f0,  1.0f0,  0.0f0,  0.0f0,  1.0f0,  0.0f0,
         0.5f0,  0.5f0, -0.5f0,  1.0f0,  0.0f0,  0.0f0,  1.0f0,  1.0f0,
         0.5f0, -0.5f0, -0.5f0,  1.0f0,  0.0f0,  0.0f0,  0.0f0,  1.0f0,
         0.5f0, -0.5f0, -0.5f0,  1.0f0,  0.0f0,  0.0f0,  0.0f0,  1.0f0,
         0.5f0, -0.5f0,  0.5f0,  1.0f0,  0.0f0,  0.0f0,  0.0f0,  0.0f0,
         0.5f0,  0.5f0,  0.5f0,  1.0f0,  0.0f0,  0.0f0,  1.0f0,  0.0f0,

        -0.5f0, -0.5f0, -0.5f0,  0.0f0, -1.0f0,  0.0f0,  0.0f0,  1.0f0,
         0.5f0, -0.5f0, -0.5f0,  0.0f0, -1.0f0,  0.0f0,  1.0f0,  1.0f0,
         0.5f0, -0.5f0,  0.5f0,  0.0f0, -1.0f0,  0.0f0,  1.0f0,  0.0f0,
         0.5f0, -0.5f0,  0.5f0,  0.0f0, -1.0f0,  0.0f0,  1.0f0,  0.0f0,
        -0.5f0, -0.5f0,  0.5f0,  0.0f0, -1.0f0,  0.0f0,  0.0f0,  0.0f0,
        -0.5f0, -0.5f0, -0.5f0,  0.0f0, -1.0f0,  0.0f0,  0.0f0,  1.0f0,

        -0.5f0,  0.5f0, -0.5f0,  0.0f0,  1.0f0,  0.0f0,  0.0f0,  1.0f0,
         0.5f0,  0.5f0, -0.5f0,  0.0f0,  1.0f0,  0.0f0,  1.0f0,  1.0f0,
         0.5f0,  0.5f0,  0.5f0,  0.0f0,  1.0f0,  0.0f0,  1.0f0,  0.0f0,
         0.5f0,  0.5f0,  0.5f0,  0.0f0,  1.0f0,  0.0f0,  1.0f0,  0.0f0,
        -0.5f0,  0.5f0,  0.5f0,  0.0f0,  1.0f0,  0.0f0,  0.0f0,  0.0f0,
        -0.5f0,  0.5f0, -0.5f0,  0.0f0,  1.0f0,  0.0f0,  0.0f0,  1.0f0]

    # first, configure the cube's VAO (and VBO)
    VBO = GLuint[0]
    cubeVAO = GLuint[0]
    glGenVertexArrays(1, cubeVAO)
    glGenBuffers(1, VBO)

    glBindBuffer(GL_ARRAY_BUFFER, VBO[])
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertecies), vertecies, GL_STATIC_DRAW)

    glBindVertexArray(cubeVAO[])
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), Ptr{Cvoid}(0))
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), Ptr{Cvoid}(3 * sizeof(GLfloat)))
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), Ptr{Cvoid}(6 * sizeof(GLfloat)))
    glEnableVertexAttribArray(2)

    # second, configure the light's VAO (VBO stays the same; the vertices are the same for the light object which is also a 3D cube)
    lightCubeVAO = GLuint[0]
    glGenVertexArrays(1, lightCubeVAO)
    glBindVertexArray(lightCubeVAO[])

    glBindBuffer(GL_ARRAY_BUFFER, VBO[])
    # // note that we update the lamp's position attribute's stride to reflect the updated buffer data
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), Ptr{Cvoid}(0))
    glEnableVertexAttribArray(0)

    # load textures (we now use a utility function to keep the code more organized)
    # -----------------------------------------------------------------------------
    diffuseMap = loadTexture("./textures/container2.png")

    # shader configuration
    # --------------------
    use(lightingShader)
    setInt(lightingShader, "material.diffuse", 0)


    # set initial time of the last frame
    # ----------------------------------
    global startTime = time()
    global lastFrame = 0.0

    # render loop
    # -----------
    while !GLFW.WindowShouldClose(window)
        # per-frame time logic
        # --------------------
        global currentTime = time() - startTime
        global deltaTime = currentTime - lastFrame
        global lastFrame = currentTime

        # input
        # -----
        processInput(window)

        # render
        # ------
        glClearColor(0.1f0, 0.1f0, 0.1f0, 1.0f0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        # be sure to activate shader when setting uniforms/drawing objects
        use(lightingShader)
        setVec3(lightingShader, "light.position", lightPos)
        setVec3(lightingShader, "viewPos", camera.Position)

        # light properties
        setVec3(lightingShader, "light.ambient",  0.2f0, 0.2f0, 0.2f0)
        setVec3(lightingShader, "light.diffuse",  0.5f0, 0.5f0, 0.5f0)
        setVec3(lightingShader, "light.specular", 1.0f0, 1.0f0, 1.0f0)

        # material properties
        setVec3(lightingShader, "material.specular", 0.5f0, 0.5f0, 0.5f0)
        setFloat(lightingShader, "material.shininess", 64.0f0)

        # view/projection transformations
        projection = perspective(radians(camera.Zoom), 
            Float32(SCR_WIDTH)/Float32(SCR_HEIGHT), 0.1f0, 100.0f0)
        view = getViewMatrix(camera)
        setMat4(lightingShader, "projection", projection)
        setMat4(lightingShader, "view", view)

        # world transformation
        model = Mat4(1.0f0)
        setMat4(lightingShader, "model", model)

        # bind diffuse map
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, diffuseMap[])

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

# utility function for loading a 2D texture from file
# ---------------------------------------------------
function loadTexture(path::String)
    textureID = GLuint[0]
    glGenTextures(1, textureID)
    
    width = GLint[0]
    height = GLint[0]
    nrChannels = GLint[0]
    data = load_img!(path, width, height, nrChannels)

    if nrChannels[] == 1
        format = GL_RED
    elseif nrChannels[] == 3
        format = GL_RGB
    elseif nrChannels[] == 4
        format = GL_RGBA
    end

    glBindTexture(GL_TEXTURE_2D, textureID[])
    glTexImage2D(GL_TEXTURE_2D, 0, format, width[], height[], 0, format, GL_UNSIGNED_BYTE, pointer(data))
    glGenerateMipmap(GL_TEXTURE_2D)

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

    textureID
end

main()
