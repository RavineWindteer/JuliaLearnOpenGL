using GLFW
using ModernGL

# for passing strings to OpenGL functions that expect pointers to GLchar
# ----------------------------------------------------------------------
glchar_ptr(source) =
    convert(Ptr{UInt8}, pointer([convert(Ptr{GLchar}, pointer(source))]))

# utility function for converting a Julia string to a C string
# ------------------------------------------------------------
function cstring(s::String)
    c_string = Vector{UInt8}(s)
    push!(c_string, 0)
end

# utility function to get the pointer of a c style string
# -------------------------------------------------------
c_str_ptr(s::Vector{UInt8}) = convert(Ptr{UInt8}, pointer(s))

# utility function for checking shader compilation/linking errors.
# ------------------------------------------------------------------------
function checkCompileErrors(shader::GLuint, type::String)
    success = GLint[0]
    infoLog = zeros(GLchar, 1024)
    sizei = GLsizei[0]
    if type != "PROGRAM"
        glGetShaderiv(shader, GL_COMPILE_STATUS, success)
        if success[] == GL_FALSE
            glGetShaderInfoLog(shader, 1024, sizei, infoLog)
            println("ERROR::SHADER_COMPILATION_ERROR of type: ",
                type, "\n", unsafe_string(pointer(infoLog), sizei[]),
                "\n -- --------------------------------------------------- -- ")
        end
    else
        glGetProgramiv(shader, GL_LINK_STATUS, success)
        if success[] == GL_FALSE
            glGetProgramInfoLog(shader, 1024, sizei, infoLog)
            println("ERROR::PROGRAM_LINKING_ERROR of type: ",
                type, "\n", unsafe_string(pointer(infoLog), sizei[]),
                "\n -- --------------------------------------------------- -- ")
        end
    end
end


struct Shader
    ID::GLuint
    # constructor generates the shader on the fly
    # ------------------------------------------------------------------------
    function Shader(vertexPath::String, fragmentPath::String)
        # 1. retrieve the vertex/fragment source code from filePath
        # open files
        vertexFile = open(vertexPath, "r")
        fragmentFile = open(fragmentPath, "r")

        # Check if files are open
        if !isopen(vertexFile)
            println("ERROR::SHADER::VERTEX::FILE_NOT_OPENED: ", vertexPath)
            return new(0)
        end
        if !isopen(fragmentFile)
            println("ERROR::SHADER::FRAGMENT::FILE_NOT_OPENED: ", fragmentPath)
            return new(0)
        end

        # read file's buffer contents into strings
        vertexCode = read(vertexFile, String)
        fragmentCode = read(fragmentFile, String)
        # close file handlers
        close(vertexFile)
        close(fragmentFile)

        # 2. compile shaders
        # vertex shader
        vertex = glCreateShader(GL_VERTEX_SHADER)
        glShaderSource(vertex, 1, glchar_ptr(vertexCode), C_NULL)
        glCompileShader(vertex)
        checkCompileErrors(vertex, "VERTEX")
        # fragment Shader
        fragment = glCreateShader(GL_FRAGMENT_SHADER)
        glShaderSource(fragment, 1, glchar_ptr(fragmentCode), C_NULL)
        glCompileShader(fragment)
        checkCompileErrors(fragment, "FRAGMENT")
        # shader Program
        ID = glCreateProgram()
        glAttachShader(ID, vertex)
        glAttachShader(ID, fragment)
        glLinkProgram(ID)
        checkCompileErrors(ID, "PROGRAM")
        # delete the shaders as they're linked into our program now and no longer necessary
        glDeleteShader(vertex)
        glDeleteShader(fragment)

        # 3. create Shader object with ID
        new(ID)
    end
end

use(shader::Shader) = glUseProgram(shader.ID)

function setBool(shader::Shader, name::String, value::Bool)
    c_name = cstring(name)
    ptr_c_name = c_str_ptr(c_name)
    glUniform1i(glGetUniformLocation(shader.ID, ptr_c_name), GLint(value))
end

function setInt(shader::Shader, name::String, value::GLint)
    c_name = cstring(name)
    ptr_c_name = c_str_ptr(c_name)
    glUniform1i(glGetUniformLocation(shader.ID, ptr_c_name), value)
end
setInt(shader::Shader, name::String, value::Real) =
    setInt(shader, name, GLint(value))

function setFloat(shader::Shader, name::String, value::GLfloat)
    c_name = cstring(name)
    ptr_c_name = c_str_ptr(c_name)
    glUniform1f(glGetUniformLocation(shader.ID, ptr_c_name), value)
end
setFloat(shader::Shader, name::String, value::Real) =
    setFloat(shader, name, GLfloat(value))

delete(shader::Shader) = glDeleteProgram(shader.ID)
