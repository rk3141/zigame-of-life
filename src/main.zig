const std = @import("std");
const builder = @import("build_page.zig");

const SIZE = builder.SIZE;

const Grid = struct {
    grid: [SIZE][SIZE]bool,

    const Self = @This();

    fn get(self: *Self, i: usize, j: usize) u1 {
        return if (self.grid[j][i]) 1 else 0;
    }

    fn update(self: *Self) void {
        var newGrid: [SIZE][SIZE]bool = undefined;

        var i: usize = 0;
        var j: usize = 0;

        while (j < SIZE) : (j += 1) {
            while (i < SIZE) : (i += 1) {
                var aliveNeighbors: u4 = 0;

                if (j != 0) {
                    if (i != 0) {
                        aliveNeighbors += self.get(i - 1, j - 1); // TOPLEFT
                    }
                    aliveNeighbors += self.get(i, j - 1); // UP
                    if (i != SIZE - 1) {
                        aliveNeighbors += self.get(i + 1, j - 1); // TOPRIG
                    }
                }

                if (i != 0) {
                    aliveNeighbors += self.get(i - 1, j); // LEFT
                }
                if (i != SIZE - 1) {
                    aliveNeighbors += self.get(i + 1, j); // RIGHT
                }

                if (j != SIZE - 1) {
                    if (i != 0) {
                        aliveNeighbors += self.get(i - 1, j + 1); // BOTLEFT
                    }
                    aliveNeighbors += self.get(i, j + 1); // DOWN
                    if (i != SIZE - 1) {
                        aliveNeighbors += self.get(i + 1, j + 1); // BOTRIG
                    }
                }

                if (self.get(i, j) == 1) {
                    switch (aliveNeighbors) {
                        0, 1 => {
                            newGrid[j][i] = false;
                        },
                        2, 3 => {
                            newGrid[j][i] = true;
                        },
                        4, 5, 6, 7, 8 => {
                            newGrid[j][i] = false;
                        },
                        else => {},
                    }
                } else {
                    if (aliveNeighbors == 3) {
                        newGrid[j][i] = true;
                    } else {
                        newGrid[j][i] = false;
                    }
                }
            }
            i = 0;
        }

        self.grid = newGrid;
    }

    fn show(self: *Self, writer: anytype) !void {
        const grid = self.grid;
        for (grid) |row| {
            for (row) |cell| {
                try writer.print("{s}", .{if (cell) "#" else "_"});
            }
            try writer.print("\n", .{});
        }
    }

    fn init(seed: u2500) Self {
        var s = seed;
        var grid: [SIZE][SIZE]bool = undefined;

        var i: usize = 0;
        var j: usize = 0;

        while (j < SIZE) : (j += 1) {
            while (i < SIZE) : (i += 1) {
                grid[j][i] = (s & 1) == 1;
                s >>= 1;
            }
            i = 0;
        }

        return Self{ .grid = grid };
    }
};

pub fn main() !void {
    try builder.generatePage();

    const fps = 20;
    var grid = Grid.init(0b110000000000000000000000000000000000000000000000100010000000000000000000000000000000000001000000010000010000000000000000000000000000000000010100001101000100000000110000000000000000000000000000110001000001000000001100000000000000110000000000001100001000100000000000000000000000001100000000000011000000110000000000000000000000000000000000000101000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000);

    const stdout = std.io.getStdOut().writer();
    var buf = std.io.bufferedWriter(stdout);
    const bw = buf.writer();

    while (true) {
        std.debug.print("\x1B[2J\x1B[H", .{});
        try grid.show(bw);
        try buf.flush();
        grid.update();

        std.time.sleep(@divFloor(1000, fps) * std.time.ns_per_ms);
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
