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

const Camera = @This();

aspect_ratio: f64, // Ratio of image width over height
image_width: usize, // Rendered image width in pixel count
image_height: usize, // Rendered image height

camera_center: point3, // Camera center
pixel_delta_u: vec3, // Offset to pixel to the right
pixel_delta_v: vec3, // Offset to pixel below
pixel00_loc: point3, // Location of pixel 0, 0

pub fn init(aspect_ratio: f64, image_width: usize) Camera {
    return .{
        .aspect_ratio = aspect_ratio,
        .image_width = image_width,
        .image_height = 0,
        .camera_center = point3.zero,
        .pixel_delta_u = vec3.zero,
        .pixel_delta_v = vec3.zero,
        .pixel00_loc = point3.zero,
    };
}

fn initialize(camera: *Camera) void {
    // Image
    const aspect_ratio = camera.aspect_ratio;
    const image_width: usize = camera.image_width;
    const image_height: usize = @max(1, @as(usize, @intFromFloat(@as(f64, @floatFromInt(image_width)) / aspect_ratio)));

    // Camera
    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (@as(f64, @floatFromInt(image_width)) / @as(f64, @floatFromInt(image_height)));
    const camera_center = point3.zero;

    const viewport_u = vec3.init(viewport_width, 0, 0);
    const viewport_v = vec3.init(0, -viewport_height, 0);
    const pixel_delta_u = viewport_u.div(image_width);
    const pixel_delta_v = viewport_v.div(image_height);

    const viewport_upper_left = camera_center.sub(vec3.init(0, 0, focal_length)).sub(viewport_u.div(2)).sub(viewport_v.div(2));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).mul(0.5));

    camera.image_height = image_height;
    camera.camera_center = camera_center;
    camera.pixel_delta_u = pixel_delta_u;
    camera.pixel_delta_v = pixel_delta_v;
    camera.pixel00_loc = pixel00_loc;
}

pub fn render(camera: *Camera, world: Hittable) !void {
    camera.initialize();

    var console = std.fs.File.stdout().writer(&.{});
    const stdout = &console.interface;

    try stdout.print("P3\n{} {}\n255\n", .{ camera.image_width, camera.image_height });

    for (0..camera.image_height) |y| {
        //std.log.info("\rScanlines remaining: {}", .{image_height - y});
        for (0..camera.image_width) |x| {
            const pixel_center = camera.pixel00_loc.add(camera.pixel_delta_u.mul(x)).add(camera.pixel_delta_v.mul(y));
            const ray_direction = pixel_center.sub(camera.camera_center);
            const r = Ray.init(camera.camera_center, ray_direction);

            const pixel_color = ray_color(r, &world);
            try Color.write_color(stdout, pixel_color);
        }
    }
    std.log.info("\rDone.                 ", .{});
}

fn ray_color(r: Ray, hittable: *const Hittable) color {
    var rec: HitRecord = undefined;

    if (hittable.hit(r, Interval.init(0, Rtweekend.INFINITY), &rec)) {
        return rec.normal.add(1).mul(0.5);
    }

    const unit_direction = r.direction.unit();
    const alpha = 0.5 * (unit_direction.y() + 1.0);

    const s = color.init(1.0, 1.0, 1.0).mul(1.0 - alpha);
    const e = color.init(0.5, 0.7, 1.0).mul(alpha);

    const blendedValue = vec3.add(s, e);
    return blendedValue;
}
