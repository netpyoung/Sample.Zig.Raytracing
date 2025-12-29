const Material = @import("Material.zig");
const color = @import("vec3.zig").color;
const vec3 = @import("vec3.zig").vec3;
const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");

const Mat_Metal = @This();

albedo: color,
fuzz: f64,

pub fn init(albedo: color, fuzz: f64) Mat_Metal {
    return .{
        .albedo = albedo,
        .fuzz = fuzz,
    };
}

pub fn ToMaterial(self: *const Mat_Metal) Material {
    return .{
        .ptr = self,
        .vtable = &.{
            .scatter = scatter,
        },
    };
}

pub fn scatter(ctx: *const anyopaque, r_in: Ray, rec: HitRecord, attenuation: *color, scattered: *Ray) bool {
    const self: *const Mat_Metal = @ptrCast(@alignCast(ctx));

    var reflected = vec3.reflect(r_in.direction, rec.normal);
    reflected = vec3.add(vec3.unit(reflected), vec3.mul(vec3.random_unit_vector(), self.fuzz));

    attenuation.* = self.albedo;
    scattered.* = Ray.init(rec.p, reflected);

    return (vec3.dot(scattered.direction, rec.normal) > 0);
}
