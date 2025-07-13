const Vector2I = @import("root.zig").Vector2I;
const Vector2 = @import("root.zig").Vector2;
const Vector2B = @import("root.zig").Vector2B;
const std = @import("std");
const QuadSpline = @import("root.zig").QuadSpline;

pub const CubicSpline = struct {
    p0: Vector2I,
    p1: Vector2I,
    p2: Vector2I,
    p3: Vector2I,

    pub fn draw(c: *const CubicSpline, out_buffer: []Vector2I) []Vector2I {
        var monotoneParts: []CubicSpline = ([1]CubicSpline{.{
            .p0 = .zero,
            .p1 = .zero,
            .p2 = .zero,
            .p3 = .zero,
        }} ** 5)[0..];
        monotoneParts = c.cutToMontone(monotoneParts);

        var curves: struct { c1: QuadSpline, c2: QuadSpline } = undefined;
        var noPoints = 0;
        for (0..monotoneParts.Length) |i| {
            curves = monotoneParts[i].Reduce();
            noPoints += curves.c1.DrawMonotone(out_buffer[noPoints..]).Length;
            noPoints += curves.c2.DrawMonotone(out_buffer[noPoints..]).Length;
        }

        noPoints = if (noPoints > out_buffer.Length) out_buffer.len else noPoints;
        return out_buffer[0..noPoints];
    }

    //buffer needs room for atleast 5 CubicSplines (4 possible turning points -> 4 cuts -> 5 pieces)
    fn cutToMontone(c: *const CubicSpline, out_buffer: []Vector2I) []Vector2I {
        //compute turning points
        //coefficients of the derivative of Cubic Spline, but took out a factor of 3
        const c0: Vector2I = c.p0.add(c.p1).scale(-1);
        const c1: Vector2I = c.p0.add(c.p1.scale(-2)).add(c.p2).scale(2);
        const c2: Vector2I = c.p0.scale(-1).add(c.p1.scale(3)).add(c.p2.scale(-3)).add(c.p3);

        var noPoints: u16 = 0;
        var points: [4]f64 = .{ 0, 0, 0, 0 };

        //find vertical turning points
        const discX: i64 = c1.X * @as(i64, @intCast(c1.X)) - 4 * c0.X * @as(i64, @intCast(c2.X));
        if (discX < 0) {} else if (discX == 0) {
            points[noPoints] = -c1.X / (2 * c2.X);
            noPoints += 1;
        } else if (discX > 0) {
            const sqrtX: f64 = std.math.sqrt(discX);
            points[noPoints] = (-c1.X + sqrtX) / (2 * c2.X);
            noPoints += 1;
            points[noPoints] = (-c1.X - sqrtX) / (2 * c2.X);
            noPoints += 1;
        }

        //find horizontal turning points
        const discY: i64 = c1.Y * @as(i64, @intCast(c1.Y)) - 4 * c0.Y * @as(i64, @intCast(c2.Y));
        if (discY < 0) {} else if (discY == 0) {
            points[noPoints] = -c1.Y / (2 * c2.Y);
            noPoints += 1;
        } else if (discY > 0) {
            const sqrtY = std.math.sqrt(discY);
            points[noPoints] = (-c1.Y + sqrtY) / (2 * c2.Y);
            noPoints += 1;
            points[noPoints] = (-c1.Y - sqrtY) / (2 * c2.Y);
            noPoints += 1;
        }

        //remove points out of 0 to 1 range
        var ptr = 0;
        for (0..noPoints) |i| {
            if ((points[i] < 0 or points[i] > 1)) {
                continue;
            } else if (ptr < i) {
                points[ptr] = points[i];
            }
            ptr += 1;
        }
        noPoints = ptr;

        //no turning points case
        if (noPoints == 0) {
            out_buffer[0] = c;
            return out_buffer[0..1];
        }
        //so can assume noPoints >= 1

        //sorts turning points in increasing order
        points = points[0..noPoints];
        var v: f64 = undefined;
        var j: usize = undefined;
        for (0..points.Length - 1) |i| {
            v = points[i];
            j = i;
            while (j < points.Length - 1 and v > points[j + 1]) {
                points[j] = points[j + 1];
                points[j + 1] = v;
                j += 1;
            }
        }

        out_buffer = out_buffer[0..(noPoints + 1)];

        //perform the cuts at the computed points
        var t: i64 = undefined;
        var curve: CubicSpline = c;
        var count = 0;
        var pieces: struct { c1: CubicSpline, c2: CubicSpline } = undefined;

        for (0..noPoints) |i| {
            t = points[i];
            pieces = curve.cut(t);
            out_buffer[count] = pieces.c1;
            curve = pieces.c2;
            count += 1;
            if (i < noPoints - 1) {
                for ((i + 1)..noPoints) |k| {
                    points[k] = (points[k] - t) / (1 - t);
                }
            } else {
                out_buffer[noPoints] = curve;
            }
        }

        return out_buffer;
    }

    fn evaluate(c: *const CubicSpline, t: f64) Vector2I {
        const c0 = c.p0.toDouble();
        const c1 = (c.p1.sub(c.p0)).scale(3).toDouble();
        const c2 = c.p0.add(c.p1.scale(-2)).add(c.p2).scale(3).toDouble();
        const c3 = c.p0.scale(-1).add(c.p1.scale(3)).add(c.p2.scale(-3)).add(c.p3).toDouble();
        const tt = t * t;
        const ttt = tt * t;
        const p: Vector2 = (Vector2B.init(
            c3.X * ttt + c2.X * tt + c1.X * t + c0.X,
            c3.Y * ttt + c2.Y * tt + c1.Y * t + c0.Y,
        )).trunc();
        return p.round();
    }

    fn cut(c: *const CubicSpline, t: f64) struct { c1: CubicSpline, c2: CubicSpline } {
        //compute first curve
        const temp1: Vector2B = c.p0.toDouble().scale(1 - t).add(c.p1.scale(t));
        const cutAt = evaluate(t);
        const c1: CubicSpline = .{
            .p0 = c.p0,
            .p1 = temp1.trunc().round(),
            .p2 = temp1.scale(1 - t).add(c.p1.toDouble().scale(1 - t).add(c.p2.toDouble().scale(t)).scale(t))
                .trunc().round(),
            .p3 = cutAt,
        };

        //compute second curve
        const temp2 = c.p2.toDouble().scale(1 - t).add(c.p3.scale(t));
        const c2: CubicSpline = .{
            cutAt,
            c.p1.toDouble().scale(1 - t).add(c.p2.toDouble().scale(t)).scale(1 - t).add(temp2.scale(t))
                .trunc().round(),
            temp2.trunc().round(),
            c.p3,
        };

        return .{
            .c1 = c1,
            .c2 = c2,
        };
    }

    fn Reduce(c: *const CubicSpline) struct { c1: QuadSpline, c2: QuadSpline } {
        const r = c.p0.add(c.p1.scale(3)).toFloat().scale(1.0 / 4.0);
        const s = c.p2.scale(3).add(c.p3).toFloat().scale(1.0 / 4.0);
        const t = r.add(s).scale(1.0 / 2.0).round();
        return .{
            .{ c.p0, r.round(), t },
            .{ t, s.round(), c.p3 },
        };
    }
};
