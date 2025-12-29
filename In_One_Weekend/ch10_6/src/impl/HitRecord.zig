const point3 = @import("vec3.zig").point3;
const vec3 = @import("vec3.zig").vec3;
const Ray = @import("Ray.zig");
const Material = @import("Material.zig");

pub const HitRecord = @This();

p: point3,
normal: vec3,
t: f64,
front_face: bool,
mat: *const Material,

pub fn set_face_normal(self: *HitRecord, r: Ray, outward_normal: vec3) void {
    self.front_face = vec3.dot(r.direction, outward_normal) < 0;
    if (self.front_face) {
        self.normal = outward_normal;
    } else {
        self.normal = outward_normal.neg();
    }
}
