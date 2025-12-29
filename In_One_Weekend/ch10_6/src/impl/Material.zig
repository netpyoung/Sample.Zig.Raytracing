// ch10_5
const color = @import("vec3.zig").color;
const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");

const Material = @This();

ptr: *const anyopaque,
vtable: *const VTable,

pub const VTable = struct {
    scatter: *const fn (ctx: *const anyopaque, r_in: Ray, rec: HitRecord, attenuation: *color, scattered: *Ray) bool,
};

pub fn scatter(self: *const Material, r_in: Ray, rec: HitRecord, attenuation: *color, scattered: *Ray) bool {
    return self.vtable.scatter(self.ptr, r_in, rec, attenuation, scattered);
}
