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
include("gl_algebra.jl")
include("image_loader.jl")
include("shader.jl")


# settings
const SCR_WIDTH = 800
const SCR_HEIGHT = 600

# camera
cameraPos = Vec3(0.0f0, 0.0f0,  3.0f0)
cameraFront = Vec3(0.0f0, 0.0f0, -1.0f0)
cameraUp = Vec3(0.0f0, 1.0f0,  0.0f0)

firstMouse = true
yaw = -90.0f0 # yaw is initialized to -90.0 degrees since a yaw of 0.0 results in a direction vector pointing to the right so we initially rotate a bit to the left.
pitch = 0.0f0
lastX = 800.0f0 / 2.0f0
lastY = 600.0f0 / 2.0f0
fov = 45.0f0

# timing
deltaTime = 0.0f0	# time between current frame and last frame
lastFrame = 0.0f0

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
    ourShader = Shader("./shaders/7.3.shader.vs", "./shaders/7.3.shader.fs") # you can name your shader files however you like

    # set up vertex data (and buffer(s)) and configure vertex attributes
    # ------------------------------------------------------------------
    vertecies = GLfloat[
        -0.5f0, -0.5f0, -0.5f0,  0.0f0, 0.0f0,
         0.5f0, -0.5f0, -0.5f0,  1.0f0, 0.0f0,
         0.5f0,  0.5f0, -0.5f0,  1.0f0, 1.0f0,
         0.5f0,  0.5f0, -0.5f0,  1.0f0, 1.0f0,
        -0.5f0,  0.5f0, -0.5f0,  0.0f0, 1.0f0,
        -0.5f0, -0.5f0, -0.5f0,  0.0f0, 0.0f0,

        -0.5f0, -0.5f0,  0.5f0,  0.0f0, 0.0f0,
         0.5f0, -0.5f0,  0.5f0,  1.0f0, 0.0f0,
         0.5f0,  0.5f0,  0.5f0,  1.0f0, 1.0f0,
         0.5f0,  0.5f0,  0.5f0,  1.0f0, 1.0f0,
        -0.5f0,  0.5f0,  0.5f0,  0.0f0, 1.0f0,
        -0.5f0, -0.5f0,  0.5f0,  0.0f0, 0.0f0,

        -0.5f0,  0.5f0,  0.5f0,  1.0f0, 0.0f0,
        -0.5f0,  0.5f0, -0.5f0,  1.0f0, 1.0f0,
        -0.5f0, -0.5f0, -0.5f0,  0.0f0, 1.0f0,
        -0.5f0, -0.5f0, -0.5f0,  0.0f0, 1.0f0,
        -0.5f0, -0.5f0,  0.5f0,  0.0f0, 0.0f0,
        -0.5f0,  0.5f0,  0.5f0,  1.0f0, 0.0f0,

         0.5f0,  0.5f0,  0.5f0,  1.0f0, 0.0f0,
         0.5f0,  0.5f0, -0.5f0,  1.0f0, 1.0f0,
         0.5f0, -0.5f0, -0.5f0,  0.0f0, 1.0f0,
         0.5f0, -0.5f0, -0.5f0,  0.0f0, 1.0f0,
         0.5f0, -0.5f0,  0.5f0,  0.0f0, 0.0f0,
         0.5f0,  0.5f0,  0.5f0,  1.0f0, 0.0f0,

        -0.5f0, -0.5f0, -0.5f0,  0.0f0, 1.0f0,
         0.5f0, -0.5f0, -0.5f0,  1.0f0, 1.0f0,
         0.5f0, -0.5f0,  0.5f0,  1.0f0, 0.0f0,
         0.5f0, -0.5f0,  0.5f0,  1.0f0, 0.0f0,
        -0.5f0, -0.5f0,  0.5f0,  0.0f0, 0.0f0,
        -0.5f0, -0.5f0, -0.5f0,  0.0f0, 1.0f0,

        -0.5f0,  0.5f0, -0.5f0,  0.0f0, 1.0f0,
         0.5f0,  0.5f0, -0.5f0,  1.0f0, 1.0f0,
         0.5f0,  0.5f0,  0.5f0,  1.0f0, 0.0f0,
         0.5f0,  0.5f0,  0.5f0,  1.0f0, 0.0f0,
        -0.5f0,  0.5f0,  0.5f0,  0.0f0, 0.0f0,
        -0.5f0,  0.5f0, -0.5f0,  0.0f0, 1.0f0]
    
    cubePositions = Vec3[
        Vec3( 0.0f0,  0.0f0,  0.0f0),
        Vec3( 2.0f0,  5.0f0, -15.0f0),
        Vec3(-1.5f0, -2.2f0, -2.5f0),
        Vec3(-3.8f0, -2.0f0, -12.3f0),
        Vec3( 2.4f0, -0.4f0, -3.5f0),
        Vec3(-1.7f0,  3.0f0, -7.5f0),
        Vec3( 1.3f0, -2.0f0, -2.5f0),
        Vec3( 1.5f0,  2.0f0, -2.5f0),
        Vec3( 1.5f0,  0.2f0, -1.5f0),
        Vec3(-1.3f0,  1.0f0, -1.5f0)]
    
    VBO = GLuint[0]
    VAO = GLuint[0]
    glGenVertexArrays(1, VAO)
    glGenBuffers(1, VBO)

    glBindVertexArray(VAO[])

    glBindBuffer(GL_ARRAY_BUFFER, VBO[])
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertecies), vertecies, GL_STATIC_DRAW)

    # position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), Ptr{Cvoid}(0))
    glEnableVertexAttribArray(0)
    # texture coord attribute
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), Ptr{Cvoid}(3 * sizeof(GLfloat)))
    glEnableVertexAttribArray(1)


    # load and create a texture
    # -------------------------
    texture1 = GLuint[0]
    texture2 = GLuint[0]
    # texture 1
    # ---------
    glGenTextures(1, texture1)
    glBindTexture(GL_TEXTURE_2D, texture1[])
    # set the texture wrapping parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)	# set texture wrapping to GL_REPEAT (default wrapping method)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
    # set texture filtering parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    # load image, create texture and generate mipmaps
    width = GLint[0]
    height = GLint[0]
    nrChannels = GLint[0]
    # load_img! is a custom function that loads the image in the right format
    data = load_img!("./textures/container.jpg", width, height, nrChannels)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width[], height[], 0, GL_RGB, GL_UNSIGNED_BYTE, pointer(data))
    glGenerateMipmap(GL_TEXTURE_2D)
    # texture 2
    # ---------
    glGenTextures(1, texture2)
    glBindTexture(GL_TEXTURE_2D, texture2[])
    # set the texture wrapping parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)	# set texture wrapping to GL_REPEAT (default wrapping method)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
    # set texture filtering parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    # load image, create texture and generate mipmaps
    data = load_img!("./textures/awesomeface.png", width, height, nrChannels)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width[], height[], 0, GL_RGBA, GL_UNSIGNED_BYTE, pointer(data))
    glGenerateMipmap(GL_TEXTURE_2D)

    # tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
    # -------------------------------------------------------------------------------------------
    use(ourShader)
    setInt(ourShader, "texture1", 0)
    setInt(ourShader, "texture2", 1)

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
        glClearColor(0.2f0, 0.3f0, 0.3f0, 1.0f0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        # bind textures on corresponding texture units
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, texture1[])
        glActiveTexture(GL_TEXTURE1)
        glBindTexture(GL_TEXTURE_2D, texture2[])

        # activate shader
        use(ourShader)

        # pass projection matrix to shader (note that in this case it could change every frame)
        projection = perspective(radians(fov), 
            Float32(SCR_WIDTH)/Float32(SCR_HEIGHT), 0.1f0, 100.0f0)
        setMat4(ourShader, "projection", projection)

        # camera/view transformation
        view = lookAt(cameraPos, cameraPos + cameraFront, cameraUp)
        setMat4(ourShader, "view", view)

        # render boxes
        glBindVertexArray(VAO[])
        for i in 1:10
            model = Mat4(1.0f0)
            model = translate(model, cubePositions[i])
            angle = Float32(20.0f0 * i)
            model = rotate(model, radians(angle), normalize(Vec3(1.0f0, 0.3f0, 0.5f0)))
            setMat4(ourShader, "model", model)

            glDrawArrays(GL_TRIANGLES, 0, 36)
        end

        # glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        # -------------------------------------------------------------------------------
        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    # optional: de-allocate all resources once they've outlived their purpose:
    # ------------------------------------------------------------------------
    glDeleteVertexArrays(1, VAO)
    glDeleteBuffers(1, VBO)
    delete(ourShader)

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
        global cameraPos += cameraSpeed * cameraFront
    end
    if GLFW.GetKey(window, GLFW.KEY_S)
        global cameraPos -= cameraSpeed * cameraFront
    end
    if GLFW.GetKey(window, GLFW.KEY_A)
        global cameraPos -= normalize(cross(cameraFront, cameraUp)) * cameraSpeed
    end
    if GLFW.GetKey(window, GLFW.KEY_D)
        global cameraPos += normalize(cross(cameraFront, cameraUp)) * cameraSpeed
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

    sensitivity = 0.1f0 # change this value to your liking
    xoffset *= sensitivity
    yoffset *= sensitivity

    global yaw += xoffset
    global pitch += yoffset

    # make sure that when pitch is out of bounds, screen doesn't get flipped
    if pitch > 89.0f0
        global pitch = 89.0f0
    end
    if pitch < -89.0f0
        global pitch = -89.0f0
    end

    front = Vec3(
        cos(radians(yaw)) * cos(radians(pitch)),
        sin(radians(pitch)),
        sin(radians(yaw)) * cos(radians(pitch)))
    global cameraFront = normalize(front)
end

function scroll_callback(window, xoffset, yoffset)
    global fov -= Float32(yoffset)
    if fov < 1.0f0
        global fov = 1.0f0
    end
    if fov > 45.0f0
        global fov = 45.0f0
    end
end


main()
