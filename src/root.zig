pub const Line = @import("line.zig").Line;
pub const Circle = @import("circle.zig").Circle;
pub const QuadSpline = @import("quad.zig").QuadSpline;
pub const CubicSpline = @import("cubic.zig").CubicSpline;
pub const FloodFill = @import("floodFill.zig").FloodFill;

test "line works" {
    const line = Line{
        .p = .zero,
        .q = .init(32, 32),
    };
    var buffer: [64]@import("zsmath").Vector2I = undefined;
    const points = line.draw(buffer[0..]);
    @import("std").debug.print("here!!", .{});
    try @import("std").testing.expect(points.len > 0);
}
