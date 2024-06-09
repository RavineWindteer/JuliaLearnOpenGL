cd(@__DIR__)
using Pkg
Pkg.activate("./OPEN_GL/")

using GLFW
using ModernGL
using JpegTurbo

include("shader.jl")

function load_img!(path::String, width, height, nrChannels)
    img = JpegTurbo.jpeg_decode(path)
    img_char = Array{UInt8}(undef, size(img, 1) * size(img, 2) * 3)
    @inbounds for i in 0:size(img, 1)-1, j in 0:size(img, 2)-1
        index = 1 + (j * 3) + (i * 3 * size(img, 2))
        rgb = img[i + 1, j + 1]
        img_char[index] = trunc(UInt8, rgb.r * 255f0)
        img_char[index + 1] = trunc(UInt8, rgb.g * 255f0)
        img_char[index + 2] = trunc(UInt8, rgb.b * 255f0)
    end
    width[] = GLint(size(img, 2))
    height[] = GLint(size(img, 1))
    nrChannels[] = GLint(3)
    img_char
end


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
    ourShader = Shader("3.3.shader.vs", "3.3.shader.fs") # you can name your shader files however you like

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
    texture = GLuint[0]
    glGenTextures(1, texture)
    glBindTexture(GL_TEXTURE_2D, texture[]) # all upcoming GL_TEXTURE_2D operations now have effect on this texture object
    # set the texture wrapping parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)	# set texture wrapping to GL_REPEAT (default wrapping method)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
    # set texture filtering parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    # load image, create texture and generate mipmaps
    width = GLint[0]
    height = GLint[0]
    nrChannels = GLint[0]
    # There isn't yet a wraper for stbi_load, load_img! is a custom function that uses JpegTurbo.jl to load the image in the right format
    data = load_img!("container.jpg", width, height, nrChannels)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width[], height[], 0, GL_RGB, GL_UNSIGNED_BYTE, pointer(data))
    glGenerateMipmap(GL_TEXTURE_2D)


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

        # bind Texture
        glBindTexture(GL_TEXTURE_2D, texture[])

        # render the triangle
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
