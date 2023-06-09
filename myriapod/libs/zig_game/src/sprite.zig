const std = @import("std");
const zgame = @import("zgame.zig");
const ZigGame = zgame.ZigGame;
const sdl = @import("sdl-wrapper"); // configured in build.zig

// uses the visitor pattern to forward calls to implementing classes
pub fn Group(comptime T1: type, comptime T2: type) type {
    const Context = ZigGame;
    const CollisionResult = struct { collided: bool, index: usize, item: ?*T1 };
    return struct {
        const Self = @This();

        pub const CollectionArrayList = std.ArrayList(T1);
        list: CollectionArrayList = CollectionArrayList.init(std.heap.page_allocator),

        pub fn destroy(self: *Self) void {
            var idx: usize = 0;
            while (idx != self.list.items.len) : (idx += 1) {
                var s = &self.list.items[idx];
                s.destroy();
            }
            self.list.clearAndFree();
        }

        pub fn add(self: *Self, item: T1) !usize {
            try self.list.append(item);
            return self.list.items.len - 1;
        }

        pub fn remove(self: *Self, index: usize) T1 {
            return self.list.swapRemove(index);
        }

        pub fn update(self: Self, t2: *T2) void {
            var idx: usize = 0;
            while (idx != self.list.items.len) : (idx += 1) {
                var s = &self.list.items[idx];
                s.update(t2);
            }
        }

        pub fn draw(self: Self, context: *Context) void {
            for (self.list.items) |item| {
                item.draw(context);
            }
        }

        pub fn collision(self: Self, s1: *T1) CollisionResult {
            var idx: usize = 0;
            while (idx != self.list.items.len) : (idx += 1) {
                var s2 = &self.list.items[idx];
                var collided = s1.position_rect().hasIntersection(s2.position_rect());
                if (collided) {
                    return .{ .collided = collided, .index = idx, .item = s2 };
                }
            }
            return .{ .collided = false, .index = 0, .item = null };
        }
    };
}
