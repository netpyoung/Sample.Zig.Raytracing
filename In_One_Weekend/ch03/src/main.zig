const std = @import("std");

const color = @import("impl/vec3.zig").color;
const Color = @import("impl/Color.zig");

pub fn main() !void {
    const image_width = 256;
    const image_height = 256;
    var console = std.fs.File.stdout().writer(&.{});
    const stdout = &console.interface;

    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });

    for (0..image_height) |y| {
        std.log.info("\rScanlines remaining: {}", .{image_height - y});
        for (0..image_width) |x| {
            const pixel_color = color.init(
                @as(f64, @floatFromInt(x)) / (image_width - 1),
                @as(f64, @floatFromInt(y)) / (image_height - 1),
                0,
            );
            try Color.write_color(stdout, pixel_color);
        }
    }
    std.log.info("\rDone.                 ", .{});
}
