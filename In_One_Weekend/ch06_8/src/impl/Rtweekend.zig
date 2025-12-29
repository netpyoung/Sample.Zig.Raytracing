const std = @import("std");

pub const INFINITY: f64 = std.math.inf(f64);
pub const PI: f64 = 3.1415926535897932385;

// Utility Functions
pub fn degrees_to_radians(degrees: f64) f64 {
    return degrees * PI / 180.0;
}