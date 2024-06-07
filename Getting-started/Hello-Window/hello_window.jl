cd(@__DIR__)
using Pkg
Pkg.activate("./OPEN_GL/")

using GLFW
using ModernGL

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

        # glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

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
