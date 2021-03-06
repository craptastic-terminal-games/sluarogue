--File contains functions for generating paths between rooms

local Pf       = require ("jumper.pathfinder") 
local Grid     = require("jumper.grid")

--get the x locations for each door for each room
local function getStartStopX(rand,rooms)
    local s_x = {}
    for i=1,#rooms, 1 do
        local x = 0
        local n = rand(0,8)
        if n < 3 then
            x = rooms[i].x
        elseif n < 6 then
            x = rooms[i].x + rooms[i].width
        else
            x = rand(rooms[i].x + 1,rooms[i].x + rooms[i].width - 1)
        end
        s_x[i] = x
    end
    return s_x
end

--get the y locations for each door for each room.
local function getStartStopY(rand,rooms,s_x)
    local s_y = {}
    for i=1,#s_x,1 do
        local y = 0
        if s_x[i] == rooms[i].x or s_x[i] == rooms[i].x + rooms[i].width then
            y = rand(rooms[i].y + 1, rooms[i].y + rooms[i].height - 1)
        else
            y = rand(0,9) < 5 and rooms[i].y or (rooms[i].y + rooms[i].height)
        end
        s_y[i] = y
    end
    return s_y
end

--make the doors on each room. each door is the start or the stop location of a path.
--each room should connect to another room. path should start at the a room and then end at the other room
function makeStartStop(rooms)
    local rand    = math.random 
    local start_x = getStartStopX(rand,rooms)        --x locations for the start of each path
    local start_y = getStartStopY(rand,rooms,start_x) --y locations for the start of each path
    local stop_x  = getStartStopX(rand,rooms)
    local stop_y  = getStartStopY(rand,rooms,stop_x)
    local start   = {} --table to hold the combines x,y locations for start of each path
    local stop    = {}
    for i=1,#start_x - 1, 1 do
        start[i] = {start_x[i],start_y[i]}
        stop[i]  = {stop_x[i + 1],stop_y[i + 1]}
    end
    --set the last start point to last room, and last stop to first room
    start[#start + 1] = {start_x[#start_x],start_y[#start_y]} 
    stop[#stop + 1]   = {stop_x[1],stop_y[1]}
    return start,stop
end

--mkae a path between two rooms
local function makePath(finder,start,stop,additem)
    local my_path = finder:getPath(start[1],start[2],stop[1],stop[2])
    if my_path then
        local path = {}
        for node,_ in my_path:nodes() do
            additem(path,{node:getX(),node:getY()})
        end
        return path
    end
    return false
end

--return a path finder. from 'jumper' library
function getFinder(collision_map,walkable)
    local grid     = Grid(collision_map)
    local finder   = Pf(grid,'DIJKSTRA',walkable)
    finder:setMode("ORTHOGONAL")
    return finder
end

--make paths between each room on map
function makePaths(map,start,stop)
    local paths    = {}
    local makepath = makePath
    local additem  = table.insert
    local finder   = getFinder(map,0)
    for i=1,#start,1 do
        local path = makepath(finder,start[i],stop[i],additem)
        if path == false then
            return false
        end
        additem(paths,path)
    end
    return paths
end


