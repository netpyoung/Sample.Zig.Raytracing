const std = @import("std");
const Rtweekend = @import("Rtweekend.zig");

pub const color = vec3;

pub const point3 = vec3;

pub const vec3 = struct {
    e: @Vector(4, f64),

    const VEC4_MASK = @Vector(4, bool){ true, true, true, false };

    pub const one: vec3 = vec3.init(1, 1, 1);
    pub const zero: vec3 = vec3.init(0, 0, 0);

    pub fn init(vx: f64, vy: f64, vz: f64) vec3 {
        return vec3{ .e = .{ vx, vy, vz, 0 } };
    }

    pub fn initByScalar(v: f64) vec3 {
        return vec3{ .e = @splat(@as(64, v)) };
    }

    pub fn format(self: vec3, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        try writer.print("{{ {d}, {d}, {d} }}", .{ self.e[0], self.e[1], self.e[2] });
    }

    pub inline fn x(self: vec3) f64 {
        return self.e[0];
    }

    pub inline fn y(self: vec3) f64 {
        return self.e[1];
    }

    pub inline fn z(self: vec3) f64 {
        return self.e[2];
    }

    pub fn neg(self: vec3) vec3 {
        return vec3{ .e = -self.e };
    }

    pub fn add(a: anytype, b: anytype) vec3 {
        const TB = @TypeOf(b);
        if (TB == vec3) {
            return a.addByVec3(b);
        }

        if (TB == @Vector(4, f64)) {
            return a.addByVec3(vec3{ .e = b });
        }

        if (TB == f64) {
            return a.addByVec3(vec3{ .e = @Vector(4, f64){ b, b, b, 0.0 } });
        }

        return switch (@typeInfo(TB)) {
            .int, .comptime_int => {
                return a.add(@as(f64, @floatFromInt(b)));
            },
            .float, .comptime_float => {
                return a.add(@as(f64, @floatCast(b)));
            },
            else => {
                @compileError("add only supports vector or scalar");
            },
        };
    }

    pub fn sub(a: vec3, b: anytype) vec3 {
        const TB = @TypeOf(b);
        if (TB == vec3) {
            return a.subByVec3(b);
        }

        if (TB == @Vector(4, f64)) {
            return a.subByVec3(vec3{ .e = b });
        }

        if (TB == f64) {
            return a.subByVec3(vec3{ .e = @Vector(4, f64){ b, b, b, 0.0 } });
        }

        return switch (@typeInfo(TB)) {
            .int, .comptime_int => {
                return a.sub(@as(f64, @floatFromInt(b)));
            },
            .float, .comptime_float => {
                return a.sub(@as(f64, @floatCast(b)));
            },
            else => {
                @compileError("sub only supports vector or scalar");
            },
        };
    }

    pub fn mul(a: vec3, b: anytype) vec3 {
        const TB = @TypeOf(b);
        if (TB == vec3) {
            return a.mulByVec3(b);
        }

        if (TB == @Vector(4, f64)) {
            return a.mulByVec3(vec3{ .e = b });
        }

        if (TB == f64) {
            return a.mulByVec3(vec3{ .e = @Vector(4, f64){ b, b, b, 0.0 } });
        }

        return switch (@typeInfo(TB)) {
            .int, .comptime_int => {
                return a.mul(@as(f64, @floatFromInt(b)));
            },
            .float, .comptime_float => {
                return a.mul(@as(f64, @floatCast(b)));
            },
            else => {
                @compileError("mul only supports vector or scalar");
            },
        };
    }

    pub fn div(a: vec3, b: anytype) vec3 {
        const T = @TypeOf(b);
        if (T == vec3) {
            return a.divByVec3(b);
        }

        if (T == @Vector(4, f64)) {
            return a.divByVec3(vec3{ .e = b });
        }

        if (T == f64) {
            return a.divByVec3(vec3{ .e = @Vector(4, f64){ b, b, b, 0.0 } });
        }

        return switch (@typeInfo(T)) {
            .int, .comptime_int => {
                return a.div(@as(f64, @floatFromInt(b)));
            },
            .float, .comptime_float => {
                return a.div(@as(f64, @floatCast(b)));
            },
            else => {
                @compileError("div only supports vector or scalar");
            },
        };
    }

    fn addByVec3(self: vec3, other: vec3) vec3 {
        return .{ .e = self.e + other.e };
    }

    fn subByVec3(self: vec3, other: vec3) vec3 {
        return .{ .e = self.e - other.e };
    }

    fn mulByVec3(self: vec3, other: vec3) vec3 {
        return .{ .e = self.e * other.e };
    }

    fn divByVec3(self: vec3, other: vec3) vec3 {
        if (std.debug.runtime_safety) {
            if (other.e[0] == 0.0 or other.e[1] == 0.0 or other.e[2] == 0.0) {
                @panic("division by zero in vec3.div");
            }
        }
        const safe_oe = @select(f64, VEC4_MASK, other.e, @as(@Vector(4, f64), @splat(@as(f64, 1.0))));
        const temp = @select(f64, VEC4_MASK, self.e / safe_oe, @as(@Vector(4, f64), @splat(@as(f64, 0.0))));
        return .{ .e = temp };
    }

    pub fn length(self: vec3) f64 {
        const ret: f64 = @sqrt(self.length_squared());
        return ret;
    }

    pub fn length_squared(self: vec3) f64 {
        const squared = self.e * self.e;
        const sum_sq: f64 = @reduce(.Add, squared);
        return sum_sq;
    }

    pub fn unit(self: vec3) vec3 {
        return self.div(self.length());
    }

    pub fn dot(u: vec3, v: vec3) f64 {
        return @reduce(.Add, u.mul(v).e);
    }

    pub fn cross(u: vec3, v: vec3) vec3 {
        return vec3.init(
            u.e[1] * v.e[2] - u.e[2] * v.e[1],
            u.e[2] * v.e[0] - u.e[0] * v.e[2],
            u.e[0] * v.e[1] - u.e[1] * v.e[0],
        );
    }

    // ch09_1
    pub fn random() vec3 {
        return vec3.init(
            Rtweekend.random_double(),
            Rtweekend.random_double(),
            Rtweekend.random_double(),
        );
    }

    pub fn random_minmax(min: f64, max: f64) vec3 {
        return vec3.init(
            Rtweekend.random_double_minmax(min, max),
            Rtweekend.random_double_minmax(min, max),
            Rtweekend.random_double_minmax(min, max),
        );
    }
    pub fn random_unit_vector() vec3 {
        while (true) {
            var p = vec3.random_minmax(-1, 1);
            const lensq = p.length_squared();
            if (1e-160 < lensq and lensq <= 1) {
                return vec3.div(p, @sqrt(lensq));
            }
        }
    }
    pub fn random_on_hemisphere(normal: vec3) vec3 {
        const on_unit_sphere = random_unit_vector();
        if (vec3.dot(on_unit_sphere, normal) > 0.0) { // In the same hemisphere as the normal
            return on_unit_sphere;
        }
        return vec3.neg(on_unit_sphere);
    }

    // ch10_5
    pub fn near_zero(self: vec3) bool {
        const s = 1e-8;
        return (@abs(self.e[0]) < s) and
            (@abs(self.e[1]) < s) and
            (@abs(self.e[2]) < s);
    }
    pub fn reflect(v: vec3, n: vec3) vec3 {
        return vec3.sub(v, vec3.mul(n, 2.0 * vec3.dot(v, n)));
    }
};
