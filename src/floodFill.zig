const Vector2I = @import("vector.zig").Vector2I;
const std = @import("std");
//first in first out -> depth search -> A* <- if trying to hit everything, then this is more memory intensive (maybe?)
//last in first out -> width search -> flood <- less memory required, know want to hit everything
pub const FloodFill = struct {
    pub fn fill(start: Vector2I, target: u16, space: []u16, comptime size: Vector2I, buffer: []Vector2I) void {
        if (start.y < 0 or start.x < 0) return;
        if (start.y >= size.y or start.x >= size.x) return;
        if (space[@intCast(start.y * size.x + start.x)] == target) return;
        buffer[0] = start;
        var no: u16 = 1; //start
        var cur: u16 = 0;

        while (cur < no) {
            const pos = buffer[cur];
            space[@intCast(pos.y * size.x + pos.x)] = target;
            inline for (0..4) |dir| {
                const offset = switch (dir) {
                    0 => Vector2I{ .x = 0, .y = 1 },
                    1 => Vector2I{ .x = 1, .y = 0 },
                    2 => Vector2I{ .x = 0, .y = -1 },
                    3 => Vector2I{ .x = -1, .y = 0 },
                    else => unreachable,
                };
                const test_pos = pos.add(offset);
                if (test_pos.y >= 0 and test_pos.x >= 0 and
                    test_pos.y < size.y and test_pos.x < size.x and
                    space[@intCast(test_pos.y * size.x + test_pos.x)] != target)
                {
                    if (no == buffer.len) return;
                    buffer[no] = test_pos;
                    no += 1;
                }
            }
            cur += 1;
        }
    }
};
