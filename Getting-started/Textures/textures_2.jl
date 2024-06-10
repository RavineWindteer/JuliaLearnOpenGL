cd(@__DIR__)
using Pkg
Pkg.activate("./OPEN_GL/")

using GLFW
using ModernGL

# There isn't yet a wraper for stbi_load in julia; image_loader.jl defines a
# custom function load_img! that loads the image in the right format
include("image_loader.jl")
include("shader.jl")


# settings
const SCR_WIDTH = 800
const SCR_HEIGHT = 600

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
    ourShader = Shader("4.2.shader.vs", "4.2.shader.fs") # you can name your shader files however you like

    # set up vertex data (and buffer(s)) and configure vertex attributes
    # ------------------------------------------------------------------
    vertecies = GLfloat[
        # positions            # colors             # texture coords
        0.5f0, 0.5f0, 0.0f0,   1.0f0, 0.0f0, 0.0f0, 1.0f0, 1.0f0, # top right
        0.5f0, -0.5f0, 0.0f0,  0.0f0, 1.0f0, 0.0f0, 1.0f0, 0.0f0, # bottom right
        -0.5f0, -0.5f0, 0.0f0, 0.0f0, 0.0f0, 1.0f0, 0.0f0, 0.0f0, # bottom left
        -0.5f0, 0.5f0, 0.0f0,  1.0f0, 1.0f0, 0.0f0, 0.0f0, 1.0f0] # top left
    
    indices = GLuint[ # note that we start from 0!
        0, 1, 3, # first triangle
        1, 2, 3] # second triangle
    
    VBO = GLuint[0]
    VAO = GLuint[0]
    EBO = GLuint[0]
    glGenVertexArrays(1, VAO)
    glGenBuffers(1, VBO)
    glGenBuffers(1, EBO)

    glBindVertexArray(VAO[])

    glBindBuffer(GL_ARRAY_BUFFER, VBO[])
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertecies), vertecies, GL_STATIC_DRAW)

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO[])
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW)

    # position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), Ptr{Cvoid}(0))
    glEnableVertexAttribArray(0)
    # color attribute
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), Ptr{Cvoid}(3 * sizeof(GLfloat)))
    glEnableVertexAttribArray(1)
    # texture coord attribute
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), Ptr{Cvoid}(6 * sizeof(GLfloat)))
    glEnableVertexAttribArray(2)


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
    data = load_img!("container.jpg", width, height, nrChannels)
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
    data = load_img!("awesomeface.png", width, height, nrChannels)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width[], height[], 0, GL_RGBA, GL_UNSIGNED_BYTE, pointer(data))
    glGenerateMipmap(GL_TEXTURE_2D)

    # tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
    # -------------------------------------------------------------------------------------------
    use(ourShader)
    # either set it manually like so:
    c_name = cstring("texture1") # create null terminated c style string
    ptr_c_name = c_str_ptr(c_name) # get the pointer to the c style string
    glUniform1i(glGetUniformLocation(ourShader.ID, ptr_c_name), 0)
    # or set it via the texture struct
    setInt(ourShader, "texture2", 1)


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

        # bind textures on corresponding texture units
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, texture1[])
        glActiveTexture(GL_TEXTURE1)
        glBindTexture(GL_TEXTURE_2D, texture2[])

        # render container
        use(ourShader)
        glBindVertexArray(VAO[])
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, Ptr{Cvoid}(0))

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
end

# glfw: whenever the window size changed (by OS or user resize) this callback function executes
# ---------------------------------------------------------------------------------------------
function framebuffer_size_callback(window, width, height)
    # make sure the viewport matches the new window dimensions; note that width and
    # height will be significantly larger than specified on retina displays.
    glViewport(0, 0, width, height)
end


main()
