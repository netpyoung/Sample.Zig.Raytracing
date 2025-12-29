const std = @import("std");
const color = @import("vec3.zig").color;
const Interval = @import("Interval.zig");

pub fn write_color(writer: *std.Io.Writer, pixel_color: color) !void {
    const r = pixel_color.x();
    const g = pixel_color.y();
    const b = pixel_color.z();

    const intensity = Interval.init(0.000, 0.999);
    const rbyte: u8 = @intFromFloat(255.999 * intensity.clamp(r));
    const gbyte: u8 = @intFromFloat(255.999 * intensity.clamp(g));
    const bbyte: u8 = @intFromFloat(255.999 * intensity.clamp(b));

    try writer.print("{d} {d} {d}\n", .{ rbyte, gbyte, bbyte });
}