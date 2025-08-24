const Vector2I = @import("vector.zig").Vector2I;
const std = @import("std");
//first in first out -> depth search -> A* <- if trying to hit everything, then this is more memory intensive (maybe?)
//last in first out -> width search -> flood <- less memory required, know want to hit everything
pub const FloodFill = struct {
    pub fn fill(start: Vector2I, target: u16, space: []u16, width: u16, buffer: []Vector2I) void {
        if (space[@intCast(start.y * width + start.x)] == target) return;
        buffer[0] = start;
        var no: u16 = 1; //start
        var cur: u16 = 0;

        while (cur < no) {
            const pos = buffer[cur];
            space[@intCast(pos.y * width + pos.x)] = target;
            inline for (0..4) |dir| {
                const offset = switch (dir) {
                    0 => Vector2I{ .x = 0, .y = 1 },
                    1 => Vector2I{ .x = 1, .y = 0 },
                    2 => Vector2I{ .x = 0, .y = -1 },
                    3 => Vector2I{ .x = -1, .y = 0 },
                };
                const test_pos = pos.add(offset);
                if (space[@intCast(test_pos.y * width + test_pos.x)] == target) continue;
                buffer[no] = test_pos;
                no += 1;
            }
            cur += 1;
        }
    }
};
