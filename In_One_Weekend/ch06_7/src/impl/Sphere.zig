const Hittable = @import("Hittable.zig");
const point3 = @import("vec3.zig").point3;
const vec3 = @import("vec3.zig").vec3;
const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");

const Sphere = @This(); // Hittable

center: point3,
radius: f64,

pub fn init(center: point3, radius: f64) Sphere {
    return .{
        .center = center,
        .radius = @max(0.0, radius),
    };
}

pub fn hittable(self: *Sphere) Hittable {
    return Hittable{
        .ptr = self,
        .vtable = &.{
            .hit = hit,
        },
    };
}

fn hit(ctx: *anyopaque, ray: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
    const self: *Sphere = @ptrCast(@alignCast(ctx));

    const C = self.center;
    const r = self.radius;
    const Q = ray.origin;
    const d = ray.direction;
    // r^2 = (C ? P)^2
    //
    // P(t) = Q + t*d
    //
    // r^2 = (C ? (Q + t*d))^2
    //
    // 0 = t^2*d^2 - 2td*(C-Q) + (C-Q)^2 - r^2
    //
    // 0 = a*x^2 + b*x + c
    //
    // a = d^2z
    // b = -2*d*(C-Q)
    // c = (C-Q)^2 - r^2
    //
    // x = (?b ¡¾ sqrt(b^2 ? 4ac)) / 2a
    // x = (h ¡¾ sqrt(h^2 ? 4ac)) / a
    // h = -b/2 = d * (C-Q)

    const C_Q = vec3.sub(C, Q);

    // const a = vec3.dot(d, d);
    // const b = -2.0 * vec3.dot(d, C_Q);
    // const c = vec3.dot(C_Q, C_Q) - r * r;
    // const discriminant = b * b - 4 * a * c;
    const a = d.length_squared();
    const h = vec3.dot(d, C_Q);
    const c = C_Q.length_squared() - r * r;
    const discriminant = h * h - a * c;
    if (discriminant < 0) {
        return false;
    }

    const sqrtd = @sqrt(discriminant);

    var root = (h - sqrtd) / a;
    if (root <= ray_tmin or ray_tmax <= root) {
        root = (h + sqrtd) / a;
        if (root <= ray_tmin or ray_tmax <= root) {
            return false;
        }
    }

    rec.t = root;
    rec.p = ray.at(rec.t);
    const outward_normal = vec3.div(vec3.sub(rec.p, self.center), self.radius);
    rec.set_face_normal(ray, outward_normal);
    return true;
}
