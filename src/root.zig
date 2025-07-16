const std = @import("std");
pub const Line = @import("line.zig").Line;
pub const CubicSpline = @import("cubic.zig").CubicSpline;

pub const Vector2I = struct {
    x: i32,
    y: i32,

    pub const zero: Vector2I = .{ .x = 0, .y = 0 };

    pub fn init(x: i32, y: i32) Vector2I {
        return .{ .x = x, .y = y };
    }

    pub fn add(a: Vector2I, b: Vector2I) Vector2I {
        return .{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub fn sub(a: Vector2I, b: Vector2I) Vector2I {
        return .{ .x = a.x - b.x, .y = a.y - b.y };
    }

    pub fn mult(a: Vector2I, b: Vector2I) Vector2I {
        return .{ .x = a.x * b.x, .y = a.y * b.y };
    }

    pub fn div(a: Vector2I, b: Vector2I) Vector2I {
        return .{ .x = a.x / b.x, .y = a.y / b.y };
    }

    pub fn scale(a: Vector2I, c: i32) Vector2I {
        return .{ .x = a.x * c, .y = a.y * c };
    }

    pub fn toFloat(a: Vector2I) Vector2 {
        return .{ .x = @floatFromInt(a.x), .y = @floatFromInt(a.y) };
    }

    pub fn toDouble(a: Vector2I) Vector2B {
        return .{ .x = @floatFromInt(a.x), .y = @floatFromInt(a.y) };
    }

    pub fn eql(a: Vector2I, b: Vector2I) bool {
        return a.x == b.x and a.y == b.y;
    }
};

pub const Vector2 = struct {
    x: f32,
    y: f32,

    pub const zero: Vector2 = .{ .x = 0, .y = 0 };

    pub fn init(x: f32, y: f32) Vector2 {
        return .{ .x = x, .y = y };
    }

    pub fn add(a: Vector2, b: Vector2) Vector2 {
        return .{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub fn sub(a: Vector2, b: Vector2) Vector2 {
        return .{ .x = a.x - b.x, .y = a.y - b.y };
    }

    pub fn mult(a: Vector2, b: Vector2) Vector2 {
        return .{ .x = a.x * b.x, .y = a.y * b.y };
    }

    pub fn div(a: Vector2, b: Vector2) Vector2 {
        return .{ .x = a.x / b.x, .y = a.y / b.y };
    }

    pub fn scale(a: Vector2, c: f32) Vector2 {
        return .{ .x = a.x * c, .y = a.y * c };
    }

    pub fn toVector2B(a: Vector2) Vector2B {
        return .{ .x = a.x, .y = a.y };
    }

    pub fn round(a: Vector2) Vector2I {
        var b: Vector2I = .{ .x = @intFromFloat(a.x), .y = @intFromFloat(a.y) };
        if (a.x - @as(f32, @floatFromInt(b.x)) >= 0.5)
            b.x += 1;
        if (a.y - @as(f32, @floatFromInt(b.y)) >= 0.5)
            b.y += 1;
        return b;
    }

    pub fn eql(a: Vector2, b: Vector2) bool {
        return a.x == b.x and a.y == b.y;
    }
};

pub const Vector2B = struct {
    x: f64,
    y: f64,

    pub const zero: Vector2B = .{ .x = 0, .y = 0 };

    pub fn init(x: f64, y: f64) Vector2B {
        return .{ .x = x, .y = y };
    }

    pub fn add(a: Vector2B, b: Vector2B) Vector2B {
        return .{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub fn sub(a: Vector2B, b: Vector2B) Vector2B {
        return .{ .x = a.x - b.x, .y = a.y - b.y };
    }

    pub fn mult(a: Vector2B, b: Vector2B) Vector2B {
        return .{ .x = a.x * b.x, .y = a.y * b.y };
    }

    pub fn div(a: Vector2B, b: Vector2B) Vector2B {
        return .{ .x = a.x / b.x, .y = a.y / b.y };
    }

    pub fn scale(a: Vector2B, c: f64) Vector2B {
        return .{ .x = a.x * c, .y = a.y * c };
    }

    pub fn trunc(a: Vector2B) Vector2 {
        return .{
            .x = @floatCast(a.x),
            .y = @floatCast(a.y),
        };
    }

    pub fn round(a: Vector2) Vector2I {
        var b: Vector2I = .{ .x = @intFromFloat(a.x), .y = @intFromFloat(a.y) };
        if (a.x - @as(f64, @floatFromInt(b.y)) >= 0.5)
            b.x += 1;
        if (a.y - @as(f64, @floatFromInt(b.y)) >= 0.5)
            b.y += 1;
        return b;
    }

    pub fn eql(a: Vector2B, b: Vector2B) bool {
        return a.x == b.x and a.y == b.y;
    }
};

pub const QuadSpline = struct {
    p0: Vector2I,
    p1: Vector2I,
    p2: Vector2I,

    const errors = error{
        weird,
    };

    pub fn draw(c: *const QuadSpline, out_buffer: []Vector2I) []Vector2I {
        var curve_buffer = [1]QuadSpline{.{
            .p0 = .zero,
            .p1 = .zero,
            .p2 = .zero,
        }} ** 3;
        var curves: []QuadSpline = curve_buffer[0..];
        curves = c.cutToMonotone(curves);
        switch (curves.len) {
            1 => return curves[0].drawMonotone(out_buffer),
            2 => {
                const c1 = curves[0].drawMonotone(out_buffer);
                const c2 = curves[1].drawMonotone(out_buffer[c1.len..]);
                return out_buffer[0..(c1.len + c2.len)];
            },
            3 => {
                const c1 = curves[0].drawMonotone(out_buffer);
                const c2 = curves[1].drawMonotone(out_buffer[c1.len..]);
                const c3 = curves[2].drawMonotone(out_buffer[(c1.len + c2.len)..]);
                return out_buffer[0..(c1.len + c2.len + c3.len)];
            },
            else => unreachable,
        }
    }

    pub fn cutToMonotone(c: *const QuadSpline, out_buffer: []QuadSpline) []QuadSpline {
        const t = c.p1.sub(c.p0).scale(-1).toFloat().div(c.p0.add(c.p1.scale(-2)).add(c.p2).toFloat());

        const State = packed struct {
            x_valid: bool,
            y_valid: bool,
            y_then_x: bool,
        };

        const x_valid = t.x >= 0 and t.x <= 1;
        const y_valid = t.y >= 0 and t.y <= 1;
        const _state: State = .{
            .x_valid = x_valid,
            .y_valid = y_valid,
            .y_then_x = x_valid and y_valid and t.y < t.x,
        };
        const state_enum = enum(u3) {
            null,
            x_valid,
            y_valid,
            x_then_y,
            y_then_x,
        };
        const state: state_enum = @enumFromInt(@as(u3, @bitCast(_state)));
        switch (state) {
            .null => {
                out_buffer[0] = c.*;
                return out_buffer[0..1];
            },
            .x_valid => {
                const p0: Vector2 = c.p0.toFloat();
                const p1: Vector2 = c.p1.toFloat();
                const p2: Vector2 = c.p2.toFloat();

                //find the point to cut at
                const p4: Vector2I = c.evaluate(t.x);
                const _p4: Vector2 = p4.toFloat();

                //find y-intersections with axes of the spline
                const t3: f32 = (_p4.x - p0.x) / (p1.x - p0.x);
                const p3: Vector2I = p0.scale(1 - t3).add(p1.scale(t3)).round();

                const t5: f32 = (_p4.x - p2.x) / (p1.x - p2.x);
                const p5: Vector2I = p2.scale(1 - t5).add(p1.scale(t5)).round();

                //get the new splines
                out_buffer[0] = .{ .p0 = c.p0, .p1 = p3, .p2 = p4 };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = c.p2 };
                return out_buffer[0..2];
            },
            .y_valid => {
                const p0: Vector2 = c.p0.toFloat();
                const p1: Vector2 = c.p1.toFloat();
                const p2: Vector2 = c.p2.toFloat();

                //find the point to cut at
                const p4: Vector2I = c.evaluate(t.y);
                const _p4: Vector2 = p4.toFloat();

                //find y-intersections with axes of the spline
                const t3: f32 = (_p4.y - p0.y) / (p1.y - p0.y);
                const p3: Vector2I = p0.scale(1 - t3).add(p1.scale(t3)).round();

                const t5: f32 = (_p4.y - p2.y) / (p1.y - p2.y);
                const p5: Vector2I = p2.scale(1 - t5).add(p1.scale(t5)).round();

                //get the new splines
                out_buffer[0] = .{ .p0 = c.p0, .p1 = p3, .p2 = p4 };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = c.p2 };
                return out_buffer[0..2];
            },
            .x_then_y => {
                const p0: Vector2 = c.p0.toFloat();
                const p1: Vector2 = c.p1.toFloat();
                const p2: Vector2 = c.p2.toFloat();

                const p4: Vector2I = c.evaluate(t.y);
                const _p4: Vector2 = p4.toFloat();
                const t3: f32 = (_p4.y - p0.y) / (p1.y - p0.y);
                const p3: Vector2I = p0.scale(1 - t3).add(p1.scale(t3)).round();
                out_buffer[0] = .{ .p0 = c.p0, .p1 = p3, .p2 = p4 };

                const p6: Vector2I = c.evaluate(t.x);
                const _p6: Vector2 = p6.toFloat();
                const t7: f32 = (_p6.x - p2.x) / (p1.x - p2.x);
                const p7: Vector2I = p2.scale(1 - t7).add(p1.scale(t7)).round();
                out_buffer[2] = .{ .p0 = p6, .p1 = p7, .p2 = c.p2 };

                const p5: Vector2I = .{ .x = p6.x, .y = p4.y };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = p6 };

                return out_buffer[0..3];
            },
            .y_then_x => {
                const p0: Vector2 = c.p0.toFloat();
                const p1: Vector2 = c.p1.toFloat();
                const p2: Vector2 = c.p2.toFloat();

                const p4: Vector2I = c.evaluate(t.x);
                const _p4: Vector2 = p4.toFloat();
                const t3: f32 = (_p4.x - p0.x) / (p1.x - p0.x);
                const p3: Vector2I = p0.scale(1 - t3).add(p1.scale(t3)).round();
                out_buffer[0] = .{ .p0 = c.p0, .p1 = p3, .p2 = p4 };

                const p6: Vector2I = c.evaluate(t.y);
                const _p6: Vector2 = p6.toFloat();
                const t7: f32 = (_p6.y - p2.y) / (p1.y - p2.y);
                const p7: Vector2I = p2.scale(1 - t7).add(p1.scale(t7)).round();
                out_buffer[2] = .{ .p0 = p6, .p1 = p7, .p2 = c.p2 };

                const p5: Vector2I = .{ .x = p4.x, .y = p6.y };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = p6 };

                return out_buffer[0..3];
            },
        }
    }

    fn evaluate(c: *const QuadSpline, t: f32) Vector2I {
        const p0: Vector2 = c.p0.toFloat();
        const p1: Vector2 = c.p1.toFloat();
        const p2: Vector2 = c.p2.toFloat();

        const eval = p0.scale((1 - t) * (1 - t)).add(p1.scale(2 * (1 - t) * t)).add(p2.scale(t * t));
        //std.debug.print("eval: ({}, {})", .{ eval.x, eval.y });
        return eval.round();
    }

    //public to be accessible for cubic impl.
    pub fn drawMonotone(c: *const QuadSpline, out_buffer: []Vector2I) []Vector2I {
        //translate to simplify
        var p = c.p0.sub(c.p1);
        var q = c.p2.sub(c.p1);

        //find orientation
        const s: Vector2I = .{
            .x = if ((q.sub(p)).x >= 0) 1 else -1,
            .y = if ((q.sub(p)).y <= 0) 1 else -1,
        };

        //move it, move it
        p = p.mult(s);
        q = q.mult(s);

        var cur: i64 = p.x * q.y - p.y * q.x;

        if (cur == 0) //straight line
        {
            const line: Line = .{ .p = c.p0, .q = c.p2 };
            return line.draw(out_buffer);
        }

        //negate curvature
        if (cur > 0) {
            const temp = p.scale(-1);
            p = q.scale(-1);
            q = temp;

            cur = p.x * q.y - p.y * q.x;
        }

        //some helpful mid-terms
        const a = p.add(q);

        const d = p.sub(q);

        const c20: i64 = a.y * a.y;
        const c11: i64 = -2 * a.x * a.y;
        const c02: i64 = a.x * a.x;
        const c10: i64 = 2 * d.y * cur;
        const c01: i64 = -2 * d.x * cur;
        //const c00: i64 = cur * cur;
        //_ = c00;

        if (!((q.sub(p)).x >= 0 and (q.sub(p)).y <= 0))
            std.debug.print("FAIL", .{});

        //begin with longer part
        //if (q.X * q.X + q.Y * q.Y > p.X * p.X + p.Y * p.Y)
        //{
        //    (p0, p2) = (p2, p0);
        //    cur = -cur;
        //    (p, q) = (q, p);
        //    b = -b;
        //}

        //2nd degree differences, hence CONSTANT
        const xx = 2 * c20;
        const yy = 2 * c02;
        const xy = c11;

        //1st degrree differences
        var dx: i64 =
            @intCast(2 * c20 * p.x +
            c20 +
            c11 * p.y +
            c10);
        var dy: i64 =
            @intCast(2 * (-1) * c02 * p.y +
            c02 +
            (-1) * c11 * p.x +
            (-1) * c01);
        var e: i64 = dx + dy + xy;

        var pos: Vector2I = c.p0;
        var no: u16 = 0;
        var yStep: bool = undefined;
        var xStep: bool = undefined;

        const step: Vector2I = .{
            .x = if (c.p0.x < c.p2.x) 1 else -1,
            .y = if (c.p0.y < c.p2.y) 1 else -1,
        };

        while (dy > 0 and dx < 0 and no < out_buffer.len) //if the gradient changes then alg fails
        {
            out_buffer[no] = pos;
            no += 1;
            if (pos.eql(c.p2))
                break;

            yStep = 2 * e < dy;
            xStep = 2 * e > dx;
            if (xStep) //x step
            {
                pos.x += step.x;
                dy += xy;
                dx += xx;
                e += dx + xy;
            }

            if (yStep) //y step
            {
                pos.y += step.y;
                dx += xy;
                dy += yy;
                e += dy + xy;
            }
        }

        //algorithm failed so is too close to being a straight line
        //do rest with s straight line
        if (!pos.eql(c.p2)) {
            const line: Line = .{ .p = pos, .q = c.p2 };
            const linePixels: []Vector2I = line.draw(out_buffer[no..]);
            no += @intCast(linePixels.len);
        }

        return out_buffer[0..no];
    }
};
