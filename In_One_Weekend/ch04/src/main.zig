const std = @import("std");

const Ray = @import("impl/Ray.zig");
const point3 = @import("impl/vec3.zig").point3;
const color = @import("impl/vec3.zig").color;
const vec3 = @import("impl/vec3.zig").vec3;
const Color = @import("impl/Color.zig");

fn ray_color(r: Ray) color {
    const unit_direction = r.direction.unit();
    const alpha = 0.5 * (unit_direction.y() + 1.0);

    const s = color.init(1.0, 1.0, 1.0).mul(1.0 - alpha);
    const e = color.init(0.5, 0.7, 1.0).mul(alpha);

    const blendedValue = vec3.add(s, e);
    return blendedValue;
}

pub fn main() !void {
    var console = std.fs.File.stdout().writer(&.{});
    const stdout = &console.interface;

    // Image
    const aspect_ratio = 16.0 / 9.0;
    const image_width: usize = 400;
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

    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });

    for (0..image_height) |y| {
        //std.log.info("\rScanlines remaining: {}", .{image_height - y});
        for (0..image_width) |x| {
            const pixel_center = pixel00_loc.add(pixel_delta_u.mul(x)).add(pixel_delta_v.mul(y));
            const ray_direction = pixel_center.sub(camera_center);
            const r = Ray.init(camera_center, ray_direction);

            const pixel_color = ray_color(r);
            try Color.write_color(stdout, pixel_color);
        }
    }
    std.log.info("\rDone.                 ", .{});
}
