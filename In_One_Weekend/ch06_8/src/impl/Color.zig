const std = @import("std");
const color = @import("vec3.zig").color;

pub fn write_color(writer: *std.Io.Writer, pixel_color: color) !void {
    const r = pixel_color.x();
    const g = pixel_color.y();
    const b = pixel_color.z();

    const rbyte: u8 = @intFromFloat(255.999 * r);
    const gbyte: u8 = @intFromFloat(255.999 * g);
    const bbyte: u8 = @intFromFloat(255.999 * b);

    try writer.print("{d} {d} {d}\n", .{ rbyte, gbyte, bbyte });
}