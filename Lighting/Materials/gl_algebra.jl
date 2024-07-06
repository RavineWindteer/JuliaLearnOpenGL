# Vectors
# =======

# Vec2 type
# ---------
struct Vec2
    x::Float32
    y::Float32
    Vec2() = new(0f0, 0f0, 0f0)
    Vec2(x::Float32) = new(x, x, x)
    Vec2(x::Real) = Vec2(Float32(x))
    Vec2(x::Float32, y::Float32) = new(x, y)
    Vec2(x::Real, y::Real) = Vec2(Float32(x), Float32(y))
end

# Vec3 type
# ---------
struct Vec3
    x::Float32
    y::Float32
    z::Float32
    Vec3() = new(0f0, 0f0, 0f0)
    Vec3(x::Float32) = new(x, x, x)
    Vec3(x::Real) = Vec3(Float32(x))
    Vec3(x::Float32, y::Float32, z::Float32) = new(x, y, z)
    Vec3(x::Real, y::Real, z::Real) = Vec3(Float32(x), Float32(y), Float32(z))
    Vec3(v::Vec2, z::Float32) = new(v.x, v.y, z)
    Vec3(v::Vec2, z::Real) = Vec3(v, Float32(z))
    Vec3(x::Float32, v::Vec2) = new(x, v.x, v.y)
    Vec3(x::Real, v::Vec2) = Vec3(Float32(x), v)
end

# Vec4 type
# ---------
struct Vec4
    x::Float32
    y::Float32
    z::Float32
    w::Float32
    Vec4() = new(0f0, 0f0, 0f0, 0f0)
    Vec4(x::Float32) = new(x, x, x, x)
    Vec4(x::Real) = Vec4(Float32(x))
    Vec4(x::Float32, y::Float32, z::Float32, w::Float32) = new(x, y, z, w)
    Vec4(x::Real, y::Real, z::Real, w::Real) =
        Vec4(Float32(x), Float32(y), Float32(z), Float32(w))
    Vec4(v::Vec2, z::Float32, w::Float32) = new(v.x, v.y, z, w)
    Vec4(v::Vec2, z::Real, w::Real) = Vec4(v, Float32(z), Float32(w))
    Vec4(x::Float32, v::Vec2, w::Float32) = new(x, v.x, v.y, w)
    Vec4(x::Real, v::Vec2, w::Real) = Vec4(Float32(x), v, Float32(w))
    Vec4(x::Float32, y::Float32, v::Vec2) = new(x, y, v.x, v.y)
    Vec4(x::Real, y::Real, v::Vec2) = Vec4(Float32(x), Float32(y), v)
    Vec4(v1::Vec2, v2::Vec2) = new(v1.x, v1.y, v2.x, v2.y)
    Vec4(v1::Vec3, w::Float32) = new(v1.x, v1.y, v1.z, w)
    Vec4(v1::Vec3, w::Real) = Vec4(v1, Float32(w))
    Vec4(x::Float32, v::Vec3) = new(x, v.x, v.y, v.z)
    Vec4(x::Real, v::Vec3) = Vec4(Float32(x), v)
end

# Print overloads
# ---------------
Base.show(io::IO, v::Vec2) = print(io, "Vec2(", v.x, ", ", v.y, ")")
Base.show(io::IO, v::Vec3) = print(io, "Vec3(", v.x, ", ", v.y, ", ", v.z, ")")
Base.show(io::IO, v::Vec4) =
    print(io, "Vec4(", v.x, ", ", v.y, ", ", v.z, ", ", v.w, ")")

# Scalar vector operations
# ------------------------
Base.:+(v::Vec2,a::Real) = Vec2(v.x + a, v.y + a)
Base.:+(a::Real,v::Vec2) = v + a
Base.:-(v::Vec2,a::Real) = Vec2(v.x - a, v.y - a)
Base.:-(a::Real,v::Vec2) = Vec2(a - v.x, a - v.y)
Base.:*(v::Vec2,a::Real) = Vec2(v.x * a, v.y * a)
Base.:*(a::Real,v::Vec2) = v * a
Base.:/(v::Vec2,a::Real) = Vec2(v.x / a, v.y / a)

Base.:+(v::Vec3,a::Real) = Vec3(v.x + a, v.y + a, v.z + a)
Base.:+(a::Real,v::Vec3) = v + a
Base.:-(v::Vec3,a::Real) = Vec3(v.x - a, v.y - a, v.z - a)
Base.:-(a::Real,v::Vec3) = Vec3(a - v.x, a - v.y, a - v.z)
Base.:*(v::Vec3,a::Real) = Vec3(v.x * a, v.y * a, v.z * a)
Base.:*(a::Real,v::Vec3) = v * a
Base.:/(v::Vec3,a::Real) = Vec3(v.x / a, v.y / a, v.z / a)

Base.:+(v::Vec4,a::Real) = Vec4(v.x + a, v.y + a, v.z + a, v.w + a)
Base.:+(a::Real,v::Vec4) = v + a
Base.:-(v::Vec4,a::Real) = Vec4(v.x - a, v.y - a, v.z - a, v.w - a)
Base.:-(a::Real,v::Vec4) = Vec4(a - v.x, a - v.y, a - v.z, a - v.w)
Base.:*(v::Vec4,a::Real) = Vec4(v.x * a, v.y * a, v.z * a, v.w * a)
Base.:*(a::Real,v::Vec4) = v * a
Base.:/(v::Vec4,a::Real) = Vec4(v.x / a, v.y / a, v.z / a, v.w / a)

# Vector negation
# ---------------
Base.:-(v::Vec2) = Vec2(-v.x, -v.y)
Base.:-(v::Vec3) = Vec3(-v.x, -v.y, -v.z)
Base.:-(v::Vec4) = Vec4(-v.x, -v.y, -v.z, -v.w)

# Addition and subtraction
# ------------------------
Base.:+(v1::Vec2,v2::Vec2) = Vec2(v1.x + v2.x, v1.y + v2.y)
Base.:-(v1::Vec2,v2::Vec2) = Vec2(v1.x - v2.x, v1.y - v2.y)
Base.:+(v1::Vec3,v2::Vec3) = Vec3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
Base.:-(v1::Vec3,v2::Vec3) = Vec3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
Base.:+(v1::Vec4,v2::Vec4) =
    Vec4(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z, v1.w + v2.w)
Base.:-(v1::Vec4,v2::Vec4) =
    Vec4(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z, v1.w - v2.w)

# Length
# ------
length_squared(v::Vec2) = v.x * v.x + v.y * v.y
length(v::Vec2) = sqrt(length_squared(v))
length_squared(v::Vec3) = v.x * v.x + v.y * v.y + v.z * v.z
length(v::Vec3) = sqrt(length_squared(v))
length_squared(v::Vec4) = v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w
length(v::Vec4) = sqrt(length_squared(v))

# Normalize
# ---------
normalize(v::Vec2) = v / length(v)
normalize(v::Vec3) = v / length(v)
normalize(v::Vec4) = v / length(v)

# Dot product
# -----------
dot(v1::Vec2,v2::Vec2) = v1.x * v2.x + v1.y * v2.y
dot(v1::Vec3,v2::Vec3) = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
dot(v1::Vec4,v2::Vec4) = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z + v1.w * v2.w

# Cross product
# -------------
cross(v1::Vec3,v2::Vec3) =
    Vec3(
        v1.y * v2.z - v1.z * v2.y,
        v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x)


# Matrices
# ========

# Attention! 
# -> The matrices are stored in column-major order;
# -> Creating a matrix from an array will not perform any assertions on the
# array's size for efficiency. Prefer using the tuple constructors for safety.

# Mat2 type
# ---------
struct Mat2
    mat::Array{Float32}
    Mat2() = new([
        0f0, 0f0,
        0f0, 0f0])
    Mat2(a::Float32) = new([
        a, 0f0,
        0f0, a])
    Mat2(a::Real) = Mat2(Float32(a))
    Mat2(m::Array{Float32}) = new(m)
    Mat2(m::NTuple{4, Float32}) = new(collect(m))
    Mat2(v1::Vec2, v2::Vec2) = 
        new([
            v1.x, v1.y,
            v2.x, v2.y])
end

# Mat3 type
# ---------
struct Mat3
    mat::Array{Float32}
    Mat3() = new([
        0f0, 0f0, 0f0,
        0f0, 0f0, 0f0,
        0f0, 0f0, 0f0])
    Mat3(a::Float32) = new([
        a, 0f0, 0f0,
        0f0, a, 0f0,
        0f0, 0f0, a])
    Mat3(a::Real) = Mat3(Float32(a))
    Mat3(m::Array{Float32}) = new(m)
    Mat3(m::NTuple{9, Float32}) = new(collect(m))
    Mat3(v1::Vec3, v2::Vec3, v3::Vec3) =
        new([
            v1.x, v1.y, v1.z,
            v2.x, v2.y, v2.z,
            v3.x, v3.y, v3.z])
end

# Mat4 type
# ---------
struct Mat4
    mat::Array{Float32}
    Mat4() = new([
        0f0, 0f0, 0f0, 0f0,
        0f0, 0f0, 0f0, 0f0,
        0f0, 0f0, 0f0, 0f0,
        0f0, 0f0, 0f0, 0f0])
    Mat4(a::Float32) = new([
        a, 0f0, 0f0, 0f0,
        0f0, a, 0f0, 0f0,
        0f0, 0f0, a, 0f0,
        0f0, 0f0, 0f0, a])
    Mat4(a::Real) = Mat4(Float32(a))
    Mat4(m::Array{Float32}) = new(m)
    Mat4(m::NTuple{16, Float32}) = new(collect(m))
    Mat4(v1::Vec4, v2::Vec4, v3::Vec4, v4::Vec4) =
        new([
            v1.x, v1.y, v1.z, v1.w,
            v2.x, v2.y, v2.z, v2.w,
            v3.x, v3.y, v3.z, v3.w,
            v4.x, v4.y, v4.z, v4.w])
end

# Print overloads
# ---------------
Base.show(io::IO, m::Mat2) =
    @inbounds print(io,
    "Mat2(\n[", m.mat[1], ", ", m.mat[3],
    "]\n[", m.mat[2], ", ", m.mat[4], "])\n")

Base.show(io::IO, m::Mat3) =
    @inbounds print(io,
    "Mat3(\n[", m.mat[1], ", ", m.mat[4], ", ", m.mat[7],
    "]\n[", m.mat[2], ", ", m.mat[5], ", ", m.mat[8],
    "]\n[", m.mat[3], ", ", m.mat[6], ", ", m.mat[9], "])\n")

Base.show(io::IO, m::Mat4) =
    @inbounds print(io,
    "Mat4(\n[", m.mat[1], ", ", m.mat[5], ", ", m.mat[9], ", ", m.mat[13],
    "]\n[", m.mat[2], ", ", m.mat[6], ", ", m.mat[10], ", ", m.mat[14],
    "]\n[", m.mat[3], ", ", m.mat[7], ", ", m.mat[11], ", ", m.mat[15],
    "]\n[", m.mat[4], ", ", m.mat[8], ", ", m.mat[12], ", ", m.mat[16], "])\n")

# Adition and subtraction
# -----------------------
Base.:+(m1::Mat2, m2::Mat2) = Mat2(m1.mat .+ m2.mat)
Base.:-(m1::Mat2, m2::Mat2) = Mat2(m1.mat .- m2.mat)
Base.:+(m1::Mat3, m2::Mat3) = Mat3(m1.mat .+ m2.mat)
Base.:-(m1::Mat3, m2::Mat3) = Mat3(m1.mat .- m2.mat)
Base.:+(m1::Mat4, m2::Mat4) = Mat4(m1.mat .+ m2.mat)
Base.:-(m1::Mat4, m2::Mat4) = Mat4(m1.mat .- m2.mat)

# Matrix-scalar products
# ----------------------
Base.:*(m::Mat2, a::Float32) = Mat2(m.mat .* a)
Base.:*(m::Mat2, a::Real) = m * Float32(a)
Base.:*(a::Real, m::Mat2) = m * a
Base.:*(m::Mat3, a::Float32) = Mat3(m.mat .* a)
Base.:*(m::Mat3, a::Real) = m * Float32(a)
Base.:*(a::Real, m::Mat3) = m * a
Base.:*(m::Mat4, a::Float32) = Mat4(m.mat .* a)
Base.:*(m::Mat4, a::Real) = m * Float32(a)
Base.:*(a::Real, m::Mat4) = m * a

# Matrix-matrix multiplication
# ----------------------------
Base.:*(m1::Mat2, m2::Mat2) = @inbounds Mat2([
    m1.mat[1] * m2.mat[1] + m1.mat[3] * m2.mat[2],
    m1.mat[2] * m2.mat[1] + m1.mat[4] * m2.mat[2],
    m1.mat[1] * m2.mat[3] + m1.mat[3] * m2.mat[4],
    m1.mat[2] * m2.mat[3] + m1.mat[4] * m2.mat[4]])

Base.:*(m1::Mat3, m2::Mat3) = @inbounds Mat3([
    m1.mat[1] * m2.mat[1] + m1.mat[4] * m2.mat[2] + m1.mat[7] * m2.mat[3],
    m1.mat[2] * m2.mat[1] + m1.mat[5] * m2.mat[2] + m1.mat[8] * m2.mat[3],
    m1.mat[3] * m2.mat[1] + m1.mat[6] * m2.mat[2] + m1.mat[9] * m2.mat[3],
    m1.mat[1] * m2.mat[4] + m1.mat[4] * m2.mat[5] + m1.mat[7] * m2.mat[6],
    m1.mat[2] * m2.mat[4] + m1.mat[5] * m2.mat[5] + m1.mat[8] * m2.mat[6],
    m1.mat[3] * m2.mat[4] + m1.mat[6] * m2.mat[5] + m1.mat[9] * m2.mat[6],
    m1.mat[1] * m2.mat[7] + m1.mat[4] * m2.mat[8] + m1.mat[7] * m2.mat[9],
    m1.mat[2] * m2.mat[7] + m1.mat[5] * m2.mat[8] + m1.mat[8] * m2.mat[9],
    m1.mat[3] * m2.mat[7] + m1.mat[6] * m2.mat[8] + m1.mat[9] * m2.mat[9]])

Base.:*(m1::Mat4, m2::Mat4) = @inbounds Mat4([
    m1.mat[1] * m2.mat[1] + m1.mat[5] * m2.mat[2] + m1.mat[9] * m2.mat[3] + m1.mat[13] * m2.mat[4],
    m1.mat[2] * m2.mat[1] + m1.mat[6] * m2.mat[2] + m1.mat[10] * m2.mat[3] + m1.mat[14] * m2.mat[4],
    m1.mat[3] * m2.mat[1] + m1.mat[7] * m2.mat[2] + m1.mat[11] * m2.mat[3] + m1.mat[15] * m2.mat[4],
    m1.mat[4] * m2.mat[1] + m1.mat[8] * m2.mat[2] + m1.mat[12] * m2.mat[3] + m1.mat[16] * m2.mat[4],
    m1.mat[1] * m2.mat[5] + m1.mat[5] * m2.mat[6] + m1.mat[9] * m2.mat[7] + m1.mat[13] * m2.mat[8],
    m1.mat[2] * m2.mat[5] + m1.mat[6] * m2.mat[6] + m1.mat[10] * m2.mat[7] + m1.mat[14] * m2.mat[8],
    m1.mat[3] * m2.mat[5] + m1.mat[7] * m2.mat[6] + m1.mat[11] * m2.mat[7] + m1.mat[15] * m2.mat[8],
    m1.mat[4] * m2.mat[5] + m1.mat[8] * m2.mat[6] + m1.mat[12] * m2.mat[7] + m1.mat[16] * m2.mat[8],
    m1.mat[1] * m2.mat[9] + m1.mat[5] * m2.mat[10] + m1.mat[9] * m2.mat[11] + m1.mat[13] * m2.mat[12],
    m1.mat[2] * m2.mat[9] + m1.mat[6] * m2.mat[10] + m1.mat[10] * m2.mat[11] + m1.mat[14] * m2.mat[12],
    m1.mat[3] * m2.mat[9] + m1.mat[7] * m2.mat[10] + m1.mat[11] * m2.mat[11] + m1.mat[15] * m2.mat[12],
    m1.mat[4] * m2.mat[9] + m1.mat[8] * m2.mat[10] + m1.mat[12] * m2.mat[11] + m1.mat[16] * m2.mat[12],
    m1.mat[1] * m2.mat[13] + m1.mat[5] * m2.mat[14] + m1.mat[9] * m2.mat[15] + m1.mat[13] * m2.mat[16],
    m1.mat[2] * m2.mat[13] + m1.mat[6] * m2.mat[14] + m1.mat[10] * m2.mat[15] + m1.mat[14] * m2.mat[16],
    m1.mat[3] * m2.mat[13] + m1.mat[7] * m2.mat[14] + m1.mat[11] * m2.mat[15] + m1.mat[15] * m2.mat[16],
    m1.mat[4] * m2.mat[13] + m1.mat[8] * m2.mat[14] + m1.mat[12] * m2.mat[15] + m1.mat[16] * m2.mat[16]])

m1::Mat2 ⊙ m2::Mat2 = Mat2(m1.mat .* m2.mat)
m1::Mat3 ⊙ m2::Mat3 = Mat3(m1.mat .* m2.mat)
m1::Mat4 ⊙ m2::Mat4 = Mat4(m1.mat .* m2.mat)

# Matrix-Vector multiplication
# ----------------------------
Base.:*(m::Mat2, v::Vec2) = @inbounds Vec2(
    m.mat[1] * v.x + m.mat[3] * v.y,
    m.mat[2] * v.x + m.mat[4] * v.y)

Base.:*(m::Mat3, v::Vec3) = @inbounds Vec3(
    m.mat[1] * v.x + m.mat[4] * v.y + m.mat[7] * v.z,
    m.mat[2] * v.x + m.mat[5] * v.y + m.mat[8] * v.z,
    m.mat[3] * v.x + m.mat[6] * v.y + m.mat[9] * v.z)

Base.:*(m::Mat4, v::Vec4) = @inbounds Vec4(
    m.mat[1] * v.x + m.mat[5] * v.y + m.mat[9] * v.z + m.mat[13] * v.w,
    m.mat[2] * v.x + m.mat[6] * v.y + m.mat[10] * v.z + m.mat[14] * v.w,
    m.mat[3] * v.x + m.mat[7] * v.y + m.mat[11] * v.z + m.mat[15] * v.w,
    m.mat[4] * v.x + m.mat[8] * v.y + m.mat[12] * v.z + m.mat[16] * v.w)

# Scaling
# -------
scale(m::Mat3, v::Vec2) =
    @inbounds Mat3([
        m.mat[1] * v.x, m.mat[2], m.mat[3],
        m.mat[4], m.mat[5] * v.y, m.mat[6],
        m.mat[7], m.mat[8], m.mat[9]])

scale(m::Mat4, v::Vec3) =
    @inbounds Mat4([
        m.mat[1] * v.x, m.mat[2], m.mat[3], m.mat[4],
        m.mat[5], m.mat[6] * v.y, m.mat[7], m.mat[8],
        m.mat[9], m.mat[10], m.mat[11] * v.z, m.mat[12],
        m.mat[13], m.mat[14], m.mat[15], m.mat[16]])

# Translation
# -----------
translate(m::Mat3, v::Vec2) =
    @inbounds Mat3([
        m.mat[1], m.mat[2], m.mat[3],
        m.mat[4], m.mat[5], m.mat[6],
        m.mat[7] + v.x, m.mat[8] + v.y, m.mat[9]])

translate(m::Mat4, v::Vec3) =
    @inbounds Mat4([
        m.mat[1], m.mat[2], m.mat[3], m.mat[4],
        m.mat[5], m.mat[6], m.mat[7], m.mat[8],
        m.mat[9], m.mat[10], m.mat[11], m.mat[12],
        m.mat[13] + v.x, m.mat[14] + v.y, m.mat[15] + v.z, m.mat[16]])

# Rotation
# --------
radians(θ::Float32) = deg2rad(θ)
radians(θ::Real) = radians(Float32(θ))
degrees(θ::Float32) = rad2deg(θ)
degrees(θ::Real) = degrees(Float32(θ))

rotate(m::Mat3, angle::Float32) =
    @inbounds m * Mat3([
        cos(angle), sin(angle), 0f0,
        -sin(angle), cos(angle), 0f0,
        0f0, 0f0, 1f0])

rotate(m::Mat3, angle::Real) = rotate(m, Float32(angle))

function rotate(m::Mat4, θ::Float32, v::Vec3)
    s = sin(θ)
    c = cos(θ)
    @inbounds m * Mat4([
        c + v.x*v.x*(1-c), v.y*v.x*(1-c) + v.z*s, v.z*v.x*(1-c) - v.y*s, 0f0,
        v.x*v.y*(1-c) - v.z*s, c + v.y*v.y*(1-c), v.z*v.y*(1-c) + v.x*s, 0f0,
        v.x*v.z*(1-c) + v.y*s, v.y*v.z*(1-c) - v.x*s, c + v.z*v.z*(1-c), 0f0,
        0f0, 0f0, 0f0, 1f0])
end

rotate(m::Mat4, θ::Real, v::Vec3) = rotate(m, Float32(θ), v)

# Prespective projection
# ----------------------
function perspective(fov::Float32, aspect::Float32, near::Float32, far::Float32)
    t = Float32(tan(fov / 2f0) * near)
    r = t * aspect
    @inbounds Mat4([
        near / r, 0f0, 0f0, 0f0,
        0f0, near / t, 0f0, 0f0,
        0f0, 0f0, (far + near) / (near - far), -1f0,
        0f0, 0f0, (2f0 * far * near) / (near - far), 0f0])
end

perspective(fov::Real, aspect::Real, near::Real, far::Real) =
    perspective(Float32(fov), Float32(aspect), Float32(near), Float32(far))

# Orthographic projection
# -----------------------
function ortho(left::Float32, right::Float32, bottom::Float32, top::Float32, near::Float32, far::Float32)
    @inbounds Mat4([
        2f0 / (right - left), 0f0, 0f0, 0f0,
        0f0, 2f0 / (top - bottom), 0f0, 0f0,
        0f0, 0f0, -2f0 / (far - near), 0f0,
        (right + left) / (left - right), (top + bottom) / (bottom - top), (far + near) / (near - far), 1f0])
end

ortho(left::Real, right::Real, bottom::Real, top::Real, near::Real, far::Real) =
    ortho(Float32(left), Float32(right), Float32(bottom), Float32(top),
        Float32(near), Float32(far))

# LookAt
# ------
function lookAt(position::Vec3, target::Vec3, up::Vec3)
    d = normalize(position - target)
    r = normalize(cross(up, d))
    u = cross(d, r)
    @inbounds Mat4([
        r.x, u.x, d.x, 0f0,
        r.y, u.y, d.y, 0f0,
        r.z, u.z, d.z, 0f0,
        -dot(r, position), -dot(u, position), -dot(d, position), 1f0])
end
