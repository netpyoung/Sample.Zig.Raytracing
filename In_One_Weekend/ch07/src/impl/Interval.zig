const std = @import("std");

const Rtweekend = @import("Rtweekend.zig");

const Interval = @This();
min: f64,
max: f64,

pub const empty: Interval = Interval.init(Rtweekend.INFINITY, -Rtweekend.INFINITY);
pub const universe: Interval = Interval.init(-Rtweekend.INFINITY, Rtweekend.INFINITY);

pub fn initDefault() Interval {
    return init(Rtweekend.INFINITY, -Rtweekend.INFINITY);
}

pub fn init(min: f64, max: f64) Interval {
    return Interval{
        .min = min,
        .max = max,
    };
}

pub fn size(self: Interval) f64 {
    return self.max - self.min;
}

pub fn contains(self: Interval, x: f64) bool {
    return self.min <= x and x <= self.max;
}

pub fn surrounds(self: Interval, x: f64) bool {
    return self.min < x and x < self.max;
}