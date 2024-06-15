include("gl_algebra.jl")


if !isdefined(Main, :_gl_algebra_jl)
    const _gl_algebra_jl = true

    const YAW = Float32(-90.0f0)
    const PITCH = Float32(0.0f0)
    const SPEED = Float32(2.5f0)
    const SENSITIVITY = Float32(0.1f0)
    const ZOOM = Float32(45.0f0)
end

@enum Camera_Movement begin 
    FORWARD = 1
    BACKWARD = 2
    LEFT = 3
    RIGHT = 4
end

mutable struct Camera
    # euler Angles
    Yaw::Float32
    Pitch::Float32
    # camera options
    MovementSpeed::Float32
    MouseSensitivity::Float32
    Zoom::Float32
    # camera Attributes
    Position::Vec3
    Front::Vec3
    Up::Vec3
    Right::Vec3
    WorldUp::Vec3

    # constructor with vectors
    function Camera(position::Vec3 = Vec3(0.0f0, 0.0f0, 0.0f0),
            up::Vec3 = Vec3(0.0f0, 1.0f0, 0.0f0),
            yaw::Float32 = YAW, pitch::Float32 = PITCH)
        worldUp = up
        front = normalize(Vec3(
            cos(radians(yaw)) * cos(radians(pitch)),
            sin(radians(pitch)),
            sin(radians(yaw)) * cos(radians(pitch))))
        right = normalize(cross(front, up))
        up = normalize(cross(right, front))
        new(yaw, pitch, SPEED, SENSITIVITY, ZOOM, position, front, up, right,
            worldUp)
    end
    # constructor with scalar values
    Camera(posX::Real, posY::Real, posZ::Real, upX::Real, upY::Real, upZ::Real,
        yaw::Real, pitch::Real) =
        Camera(Vec3(posX, posY, posZ), Vec3(upX, upY, upZ), Float32(yaw),
            Float32(pitch))
end

# returns the view matrix calculated using Euler Angles and the LookAt Matrix
getViewMatrix(camera::Camera) =
    lookAt(camera.Position, camera.Position + camera.Front, camera.Up)

# processes input received from any keyboard-like input system. Accepts input parameter in the form of camera defined ENUM (to abstract it from windowing systems)
function processKeyboard(camera::Camera, direction::Camera_Movement,
    deltaTime::Float32)

    velocity = camera.MovementSpeed * deltaTime
    if direction == FORWARD
        camera.Position += camera.Front * velocity
    end
    if direction == BACKWARD
        camera.Position -= camera.Front * velocity
    end
    if direction == LEFT
        camera.Position -= camera.Right * velocity
    end
    if direction == RIGHT
        camera.Position += camera.Right * velocity
    end
    nothing
end
processKeyboard(camera::Camera, direction::Camera_Movement, deltaTime::Real) =
    processKeyboard(camera, direction, Float32(deltaTime))

# processes input received from any keyboard-like input system. Expects the offset value in both the x and y direction.
function processMouseMovement(camera::Camera, xoffset::Float32,
    yoffset::Float32, constrainPitch::Bool = true)

    xoffset *= camera.MouseSensitivity
    yoffset *= camera.MouseSensitivity

    camera.Yaw += xoffset
    camera.Pitch += yoffset

    # make sure that when pitch is out of bounds, screen doesn't get flipped
    if constrainPitch
        if camera.Pitch > 89.0f0
            camera.Pitch = 89.0f0
        end
        if camera.Pitch < -89.0f0
            camera.Pitch = -89.0f0
        end
    end

    camera.Front = normalize(Vec3(
        cos(radians(camera.Yaw)) * cos(radians(camera.Pitch)),
        sin(radians(camera.Pitch)),
        sin(radians(camera.Yaw)) * cos(radians(camera.Pitch))))
    camera.Right = normalize(cross(camera.Front, camera.WorldUp))
    camera.Up = normalize(cross(camera.Right, camera.Front))
    nothing
end
processMouseMovement(camera::Camera, xoffset::Real, yoffset::Real,
    constrainPitch::Bool) =
    processMouseMovement(camera, Float32(xoffset), Float32(yoffset),
        constrainPitch)

function processMouseScroll(camera::Camera, yoffset::Float32)
    camera.Zoom -= yoffset
    if camera.Zoom < 1.0f0
        camera.Zoom = 1.0f0
    end
    if camera.Zoom > 45.0f0
        camera.Zoom = 45.0f0
    end
end
processMouseScroll(camera::Camera, yoffset::Real) =
    processMouseScroll(camera, Float32(yoffset))
