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

function getUniformLocation(shader::Shader, name::String)
    c_name = cstring(name)
    ptr_c_name = c_str_ptr(c_name)
    glGetUniformLocation(shader.ID, ptr_c_name)
end

setBool(shader::Shader, name::String, value::Bool) =
    glUniform1i(getUniformLocation(shader, name), GLint(value))

setInt(shader::Shader, name::String, value::GLint) =
    glUniform1i(getUniformLocation(shader, name), value)
setInt(shader::Shader, name::String, value::Real) =
    setInt(shader, name, GLint(value))

setFloat(shader::Shader, name::String, value::GLfloat) =
    glUniform1f(getUniformLocation(shader, name), value)
setFloat(shader::Shader, name::String, value::Real) =
    setFloat(shader, name, GLfloat(value))

setVec2(shader::Shader, name::String, value::Vec2) =
    glUniform2f(getUniformLocation(shader, name), value.x, value.y)

setVec2(shader::Shader, name::String, x::GLfloat, y::GLfloat) =
    glUniform2f(getUniformLocation(shader, name), x, y)

setVec2(shader::Shader, name::String, value::Real, y::Real) =
    setVec2(shader, name, GLfloat(value), GLfloat(y))

setVec3(shader::Shader, name::String, value::Vec3) =
    glUniform3f(getUniformLocation(shader, name), value.x, value.y, value.z)

setVec3(shader::Shader, name::String, x::GLfloat, y::GLfloat, z::GLfloat) =
    glUniform3f(getUniformLocation(shader, name), x, y, z)

setVec3(shader::Shader, name::String, x::Real, y::Real, z::Real) =
    setVec3(shader, name, GLfloat(x), GLfloat(y), GLfloat(z))

setVec4(shader::Shader, name::String, value::Vec4) =
    glUniform4f(getUniformLocation(shader, name),
        value.x, value.y, value.z, value.w)

setVec4(shader::Shader, name::String, x::GLfloat,
    y::GLfloat, z::GLfloat, w::GLfloat) =
    glUniform4f(getUniformLocation(shader, name), x, y, z, w)

setVec4(shader::Shader, name::String, x::Real, y::Real, z::Real, w::Real) =
    setVec4(shader, name, GLfloat(x), GLfloat(y), GLfloat(z), GLfloat(w))

setMat2(shader::Shader, name::String, value::Mat2) =
    glUniformMatrix2fv(getUniformLocation(shader, name),
        1, GL_FALSE, collect(value.mat))

setMat3(shader::Shader, name::String, value::Mat3) =
    glUniformMatrix3fv(getUniformLocation(shader, name),
        1, GL_FALSE, collect(value.mat))

setMat4(shader::Shader, name::String, value::Mat4) =
    glUniformMatrix4fv(getUniformLocation(shader, name),
        1, GL_FALSE, collect(value.mat))

delete(shader::Shader) = glDeleteProgram(shader.ID)
