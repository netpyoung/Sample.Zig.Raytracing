const std = @import("std");

const point3 = @import("vec3.zig").point3;
const color = @import("vec3.zig").color;
const vec3 = @import("vec3.zig").vec3;
const Hittable = @import("Hittable.zig");
const Ray = @import("Ray.zig");
const HittableList = @import("HittableList.zig");
const HitRecord = @import("HitRecord.zig");
const Color = @import("Color.zig");
const Interval = @import("Interval.zig");
const Rtweekend = @import("Rtweekend.zig");
const Material = @import("Material.zig");

const Camera = @This();

aspect_ratio: f64, // Ratio of image width over height
image_width: usize, // Rendered image width in pixel count
image_height: usize, // Rendered image height

camera_center: point3, // Camera center
pixel_delta_u: vec3, // Offset to pixel to the right
pixel_delta_v: vec3, // Offset to pixel below
pixel00_loc: point3, // Location of pixel 0, 0

// ch08
pixel_samples_scale: f64, // Color scale factor for a sum of pixel samples
samples_per_pixel: usize, // Count of random samples for each pixel
// ch09_2
max_depth: usize = 10, // Maximum number of ray bounces into scene

// ch12_1
vfov: f64 = 90, // Vertical view angle (field of view)

// ch12_2
lookfrom: point3 = point3.zero, // Point camera is looking from
lookat: point3 = point3.init(0, 0, -1), // Point camera is looking at
vup: vec3 = vec3.init(0, 1, 0), // Camera-relative "up" direction
u: vec3,
v: vec3,
w: vec3, // Camera frame basis vectors

pub fn init(aspect_ratio: f64, image_width: usize) Camera {
    return .{
        .aspect_ratio = aspect_ratio,
        .image_width = image_width,
        .image_height = 0,
        .camera_center = point3.zero,
        .pixel_delta_u = vec3.zero,
        .pixel_delta_v = vec3.zero,
        .pixel00_loc = point3.zero,

        // ch08
        .pixel_samples_scale = undefined,
        .samples_per_pixel = 10,
        .u = undefined,
        .v = undefined,
        .w = undefined,
    };
}

fn initialize(camera: *Camera) void {
    // Image
    const aspect_ratio = camera.aspect_ratio;
    const image_width: usize = camera.image_width;
    const image_height: usize = @max(1, @as(usize, @intFromFloat(@as(f64, @floatFromInt(image_width)) / aspect_ratio)));

    // Camera
    const camera_center = camera.lookfrom;
    const focal_length = vec3.sub(camera.lookfrom, camera.lookat).length();
    // const viewport_height = 2.0;
    const theta = Rtweekend.degrees_to_radians(camera.vfov);
    const h = @tan(theta / 2);
    const viewport_height = 2 * h * focal_length;
    const viewport_width = viewport_height * (@as(f64, @floatFromInt(image_width)) / @as(f64, @floatFromInt(image_height)));

    // Calculate the u,v,w unit basis vectors for the camera coordinate frame.
    camera.w = vec3.unit(camera.lookfrom.sub(camera.lookat));
    camera.u = vec3.unit(vec3.cross(camera.vup, camera.w));
    camera.v = vec3.cross(camera.w, camera.u);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u = camera.u.mul(viewport_width);
    const viewport_v = camera.v.mul(-viewport_height);
    const pixel_delta_u = viewport_u.div(image_width);
    const pixel_delta_v = viewport_v.div(image_height);

    const viewport_upper_left = camera_center.sub(camera.w.mul(focal_length)).sub(viewport_u.div(2)).sub(viewport_v.div(2));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).mul(0.5));

    camera.image_height = image_height;
    camera.camera_center = camera_center;
    camera.pixel_delta_u = pixel_delta_u;
    camera.pixel_delta_v = pixel_delta_v;
    camera.pixel00_loc = pixel00_loc;

    // ch08
    camera.pixel00_loc = pixel00_loc;
    camera.pixel_samples_scale = 1.0 / @as(f64, @floatFromInt(camera.samples_per_pixel));
}

pub fn render(camera: *Camera, world: Hittable) !void {
    camera.initialize();

    var console = std.fs.File.stdout().writer(&.{});
    const stdout = &console.interface;

    try stdout.print("P3\n{} {}\n255\n", .{ camera.image_width, camera.image_height });

    for (0..camera.image_height) |y| {
        //std.log.info("\rScanlines remaining: {}", .{image_height - y});
        for (0..camera.image_width) |x| {
            var pixel_color = color.init(0, 0, 0);
            for (0..camera.samples_per_pixel) |_| {
                const r = camera.get_ray(x, y);
                // for gamma test
                // const perc: f64 = @ceil((@as(f64, @floatFromInt(x)) / @as(f64, @floatFromInt(camera.image_width)) * 5.0)) / 5.0;
                pixel_color = color.add(pixel_color, ray_color(r, camera.max_depth - 1, &world));
            }
            try Color.write_color(stdout, vec3.mul(pixel_color, camera.pixel_samples_scale));
        }
    }
    std.log.info("\rDone.                 ", .{});
}

fn ray_color(r: Ray, depth: usize, hittable: *const Hittable) color {
    if (depth <= 0) {
        return color.zero;
    }

    var rec: HitRecord = undefined;

    // ch09_3 => Interval.init(0, Rtweekend.INFINITY) => Interval.init(0.001, Rtweekend.INFINITY)
    if (hittable.hit(r, Interval.init(0.001, Rtweekend.INFINITY), &rec)) {
        // before: ch09_4
        // const direction = vec3.random_on_hemisphere(rec.normal);
        // after: ch09_4
        // const direction = vec3.add(rec.normal, vec3.random_unit_vector());
        // return vec3.mul(ray_color(Ray.init(rec.p, direction), depth - 1, hittable), 0.5);
        var scattered: Ray = undefined;
        var attenuation: color = undefined;
        if (rec.mat.scatter(r, rec, &attenuation, &scattered)) {
            return vec3.mul(attenuation, ray_color(scattered, depth - 1, hittable));
        }
        return color.zero;
    }

    const unit_direction = r.direction.unit();
    const alpha = 0.5 * (unit_direction.y() + 1.0);

    const s = color.init(1.0, 1.0, 1.0).mul(1.0 - alpha);
    const e = color.init(0.5, 0.7, 1.0).mul(alpha);

    const blendedValue = vec3.add(s, e);
    return blendedValue;
}

fn get_ray(camera: *Camera, x: usize, y: usize) Ray {
    // Construct a camera ray originating from the origin and directed at randomly sampled
    // point around the pixel location i, j.

    const offset = sample_square();
    const pixel_sample = vec3.add(
        camera.pixel00_loc,
        vec3.add(
            vec3.mul(camera.pixel_delta_u, @as(f64, @floatFromInt(x)) + offset.x()),
            vec3.mul(camera.pixel_delta_v, @as(f64, @floatFromInt(y)) + offset.y()),
        ),
    );

    const ray_origin = camera.camera_center;
    const ray_direction = vec3.sub(pixel_sample, ray_origin);

    return Ray.init(ray_origin, ray_direction);
}

fn sample_square() vec3 {
    // Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
    return vec3.init(Rtweekend.random_double() - 0.5, Rtweekend.random_double() - 0.5, 0);
}
