using JpegTurbo
using PNGFiles
using ColorTypes
using FixedPointNumbers


# Load an image from a file and convert it to a char array
# --------------------------------------------------------
function load_img!(path::String, width, height, nrChannels)
    # load image (can be jpg or png)
    if occursin(".jpg", path)
        img = JpegTurbo.jpeg_decode(path)
    elseif occursin(".png", path)
        img = PNGFiles.load(path)
    else
        error("Image format not supported")
    end

    # convert the image to a char array (and flip it vertically for OpenGL)
    img_char = convert_to_gl!(img, width, height, nrChannels)
    img_char
end

# Convert an RGB image to a char array
# ------------------------------------
function convert_to_gl!(img::Matrix{RGB{N0f8}}, width, height, nrChannels)
    println("RGB 8-bits")
    # Gets the image dimensions and number of channels
    width[] = GLint(size(img, 2))
    height[] = GLint(size(img, 1))
    nrChannels[] = GLint(3)

    # Convert the image to a char array (and flip it vertically for OpenGL)
    img_char = Array{UInt8}(undef, height[] * width[] * nrChannels[])
    @inbounds for i in 0:height[]-1, j in 0:width[]-1
        index = 1 + (j * nrChannels[]) + (i * nrChannels[] * width[])
        rgb = img[height[] - i, j + 1]
        img_char[index] = trunc(UInt8, rgb.r * 255f0)
        img_char[index + 1] = trunc(UInt8, rgb.g * 255f0)
        img_char[index + 2] = trunc(UInt8, rgb.b * 255f0)
    end
    img_char
end

# Convert an RGBA image to a char array
# -------------------------------------
function convert_to_gl!(img::Matrix{RGBA{N0f8}}, width, height, nrChannels)
    println("RGBA 8-bits")
    # Gets the image dimensions and number of channels
    width[] = GLint(size(img, 2))
    height[] = GLint(size(img, 1))
    nrChannels[] = GLint(4)

    # Convert the image to a char array (and flip it vertically for OpenGL)
    img_char = Array{UInt8}(undef, height[] * width[] * nrChannels[])
    @inbounds for i in 0:height[]-1, j in 0:width[]-1
        index = 1 + (j * nrChannels[]) + (i * nrChannels[] * width[])
        rgba = img[height[] - i, j + 1]
        img_char[index] = trunc(UInt8, rgba.r * 255f0)
        img_char[index + 1] = trunc(UInt8, rgba.g * 255f0)
        img_char[index + 2] = trunc(UInt8, rgba.b * 255f0)
        img_char[index + 3] = trunc(UInt8, alpha(rgba) * 255f0)
    end
    img_char
end

# Convert a Gray scale image to a char array
# ------------------------------------
function convert_to_gl!(img::Matrix{Gray{N0f8}}, width, height, nrChannels)
    println("Gray 8-bits")
    # Gets the image dimensions and number of channels
    width[] = GLint(size(img, 2))
    height[] = GLint(size(img, 1))
    nrChannels[] = GLint(1)

    # Convert the image to a char array (and flip it vertically for OpenGL)
    img_char = Array{UInt8}(undef, height[] * width[] * nrChannels[])
    @inbounds for i in 0:height[]-1, j in 0:width[]-1
        index = 1 + (j * nrChannels[]) + (i * nrChannels[] * width[])
        gray = img[height[] - i, j + 1]
        img_char[index] = trunc(UInt8, gray.val * 255f0)
    end
    img_char
end

# Convert a Gray sacle image with alpha channel to a char array
# -------------------------------------------------------------
function convert_to_gl!(img::Matrix{GrayA{N0f8}}, width, height, nrChannels)
    println("GrayA 8-bits")
    # Gets the image dimensions and number of channels
    width[] = GLint(size(img, 2))
    height[] = GLint(size(img, 1))
    nrChannels[] = GLint(2)

    # Convert the image to a char array (and flip it vertically for OpenGL)
    img_char = Array{UInt8}(undef, height[] * width[] * nrChannels[])
    @inbounds for i in 0:height[]-1, j in 0:width[]-1
        index = 1 + (j * nrChannels[]) + (i * nrChannels[] * width[])
        graya = img[height[] - i, j + 1]
        img_char[index] = trunc(UInt8, graya.val * 255f0)
        img_char[index + 1] = trunc(UInt8, alpha(graya) * 255f0)
    end
    img_char
end
