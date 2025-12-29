const std = @import("std");

pub const INFINITY: f64 = std.math.inf(f64);
pub const PI: f64 = 3.1415926535897932385;

// Utility Functions
pub fn degrees_to_radians(degrees: f64) f64 {
    return degrees * PI / 180.0;
}

var rand_state = std.Random.DefaultPrng.init(0);

pub fn random_double() f64 {
    // Returns a random real in [0,1).
    const rand = rand_state.random();
    return rand.float(f64);
}

pub fn random_double_minmax(min: f64, max: f64) f64 {
    // Returns a random real in [min,max).
    return min + (max - min) * random_double();
}
