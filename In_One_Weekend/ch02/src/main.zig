const std = @import("std");

pub fn main() !void {
    const image_width = 256;
    const image_height = 256;
    var console = std.fs.File.stdout().writer(&.{});
    const stdout = &console.interface;

    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });
    for (0..image_height) |y| {
        std.log.info("\rScanlines remaining: {}", .{image_height - y});
        for (0..image_width) |x| {
            const r = @as(f64, @floatFromInt(x)) / @as(f64, @floatFromInt(image_width - 1));
            const g = @as(f64, @floatFromInt(y)) / @as(f64, @floatFromInt(image_height - 1));
            const b = 0.0;

            const ir = @as(u8, @intFromFloat(255.999 * r));
            const ig = @as(u8, @intFromFloat(255.999 * g));
            const ib = @as(u8, @intFromFloat(255.999 * b));

            try stdout.print("{} {} {}\n", .{ ir, ig, ib });
        }
    }
    std.log.info("\rDone.                 ", .{});
}
