const std = @import("std");

const json = std.json;

const GameRunner = enum {
    WineGE,
    Native
};

const GameOptions = struct {
    gamescope: bool,
    gamemode: bool,
};

const GameConfig = struct {
    name: []const u8,
    path: []const u8,
    runner: GameRunner,
    options: GameOptions
};

fn parse_game_json(path: []const u8) !GameConfig {
    const stream = json.TokenStream(init)
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("Hello World!\n");
}
