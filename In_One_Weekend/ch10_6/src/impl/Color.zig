const std = @import("std");
const color = @import("vec3.zig").color;
const Interval = @import("Interval.zig");

pub fn write_color(writer: *std.Io.Writer, pixel_color: color) !void {
    var r = pixel_color.x();
    var g = pixel_color.y();
    var b = pixel_color.z();

    r = linear_to_gamma(r);
    g = linear_to_gamma(g);
    b = linear_to_gamma(b);

    const intensity = Interval.init(0.000, 0.999);
    const rbyte: u8 = @intFromFloat(255.999 * intensity.clamp(r));
    const gbyte: u8 = @intFromFloat(255.999 * intensity.clamp(g));
    const bbyte: u8 = @intFromFloat(255.999 * intensity.clamp(b));

    try writer.print("{d} {d} {d}\n", .{ rbyte, gbyte, bbyte });
}

fn linear_to_gamma(linear_component: f64) f64 {
    if (linear_component > 0) {
        return @sqrt(linear_component);
    }

    return 0;
}