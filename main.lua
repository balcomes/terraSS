function love.load()

    cellSize = 12

    water_table = {}
    dirt_table = {}
    sand_table = {}
    grass_table = {}
    stone_table = {}
    lava_table = {}
    tree_table = {}
    reverse_seasons = false
    adjust = 0

    water_stone_rate = 20

    dirt_sand_rate = 1000
    dirt_grass_rate = 1000
    dirt_grass_boost = 0.001
    dirt_lava_rate = 1000

    sand_water_rate = 1000
    sand_dirt_rate = 1000
    sand_lava_rate = 1000

    grass_tree_rate = 1000
    grass_dirt_rate = 1000
    grass_lava_rate = 1000

    tree_dirt_rate = 1000
    tree_lava_rate = 1000

    lava_dirt_rate = 100

    add_volcano_rate = 0.1
    add_tree_rate = 0.1

    gridXCount = math.floor(love.graphics.getWidth()/cellSize + 0.5)
    gridYCount = math.floor(love.graphics.getHeight()/cellSize + 0.5)
    love.graphics.setBackgroundColor(25/255, 30/255, 35/255)

    function spread(g,x,y,n)
        local tally = 0
        if g[y-1][x-1] == n then
            tally = tally + 1
        end
        if g[y-1][x] == n then
            tally = tally + 1
        end
        if g[y-1][x+1] == n then
            tally = tally + 1
        end
        if g[y][x-1] == n  then
            tally = tally + 1
        end
        if g[y][x+1] == n then
            tally = tally + 1
        end
        if g[y+1][x-1] == n then
            tally = tally + 1
        end
        if g[y+1][x] == n then
            tally = tally + 1
        end
        if g[y+1][x+1]== n then
            tally = tally + 1
        end
        return tally
    end

    -- Cell Drawing Function
    function drawCell(x, y)
        love.graphics.rectangle(
            'fill',
            (x - 1) * cellSize,
            (y - 1) * cellSize,
            cellSize - 1,
            cellSize - 1
        )
    end

--------------------------------------------------------------------------------
-- Board
--------------------------------------------------------------------------------

    -- Board Class
    Board = {}
    Board.__index = Board
    function Board:Create()
        local this =
        {
            grid = {},
        }
        for y = 1, gridYCount do
            this.grid[y] = {}
            for x = 1, gridXCount do
                this.grid[y][x] = ""
            end
        end
        setmetatable(this, Board)
        return this
    end

    -- Board Clear
    function Board:Clear()
        for y = 1, gridYCount do
            self.grid[y] = {}
            for x = 1, gridXCount do
                self.grid[y][x] = ""
            end
        end
    end

    -- Board Water Fill
    function Board:Ocean()
        for y = 1, gridYCount do
            for x = 1, gridXCount do
                table.insert(water_table, Water:Create(x,y))
            end
        end
    end

    -- Board Island Fill
    function Board:Island()
        for y = 10, gridYCount - 10 do
            for x = 10, gridXCount -10 do
                table.insert(dirt_table, Dirt:Create(x,y))
            end
        end
    end

--------------------------------------------------------------------------------
-- Water
--------------------------------------------------------------------------------

    -- Water Class
    Water = {}
    Water.__index = Water
    function Water:Create(xo,yo)
        local this =
        {
            x = xo,
            y = yo,
            c1 = math.random()/4,
            c2 = math.random()/4,
            c3 = math.random()/2 + 0.5,
            blink = true,
        }
        setmetatable(this, Water)
        board.grid[yo][xo] = "water"
        return this
    end

    -- Water Blink
    function Water:Blink()
        if math.random() < 0.01 then
            self.c1 = math.random()/4
            self.c2 = math.random()/4
            self.c3 = math.random()/2 + 0.5
        end
    end

    -- Water Animate
    function Water:Animate()
        love.graphics.setColor(self.c1, self.c2, self.c3)
        if self.blink == true then
            self:Blink()
        end
        drawCell(self.x, self.y)
    end

    -- Water to Stone
    function Water:Water_to_Stone()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local water_lava = spread(board.grid, self.x ,self.y, "lava")
            if math.random() < water_lava/water_stone_rate then
                table.insert(stone_table, Stone:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

--------------------------------------------------------------------------------
-- Dirt
--------------------------------------------------------------------------------

    -- Dirt Class
    Dirt = {}
    Dirt.__index = Dirt
    function Dirt:Create(xo,yo)
        local this =
        {
            x = xo,
            y = yo,
            c1 = 110/255,
            c2 = 80/255,
            c3 = 90/255,
        }
        setmetatable(this, Dirt)
        board.grid[yo][xo] = "dirt"
        return this
    end

    -- Dirt Animate
    function Dirt:Animate()
        love.graphics.setColor(self.c1, self.c2, self.c3)
        drawCell(self.x, self.y)
    end

    -- Dirt to Sand
    function Dirt:Dirt_to_Sand()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local dirt_water = spread(board.grid,self.x,self.y,"water")
            if math.random() < dirt_water/dirt_sand_rate then
                table.insert(sand_table, Sand:Create(self.x,self.y))
                result = true
            end
        end
        return result
    end

    -- Dirt to Grass
    function Dirt:Dirt_to_Grass()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local dirt_grass = spread(board.grid, self.x, self.y, "grass")
            if math.random() < dirt_grass/dirt_grass_rate + dirt_grass_boost then
                table.insert(grass_table, Grass:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

    -- Dirt to Lava
    function Dirt:Dirt_to_Lava()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local dirt_lava = spread(board.grid, self.x, self.y, "lava")
            if math.random() < dirt_lava/dirt_lava_rate then
                table.insert(lava_table, Lava:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

--------------------------------------------------------------------------------
-- Sand
--------------------------------------------------------------------------------

    -- Sand Class
    Sand = {}
    Sand.__index = Sand
    function Sand:Create(xo,yo)
        local this =
        {
            x = xo,
            y = yo,
            c1 = 190/255,
            c2 = 190/255,
            c3 = 160/255,
        }
        setmetatable(this, Sand)
        board.grid[yo][xo] = "sand"
        return this
    end

    -- Sand Animate
    function Sand:Animate()
        love.graphics.setColor(self.c1, self.c2, self.c3)
        drawCell(self.x, self.y)
    end

    -- Sand to Water
    function Sand:Sand_to_Water()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local sand_water = spread(board.grid, self.x, self.y, "water")
            if math.random() < sand_water/sand_water_rate then
                table.insert(water_table, Water:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

    -- Sand to Dirt
    function Sand:Sand_to_Dirt()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local sand_grass = spread(board.grid, self.x, self.y, "grass")
            if math.random() < sand_grass/sand_dirt_rate then
                table.insert(dirt_table, Dirt:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

    -- Sand to Lava
    function Sand:Sand_to_Lava()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local sand_lava = spread(board.grid, self.x, self.y, "lava")
            if math.random() < sand_lava/sand_lava_rate then
                table.insert(lava_table, Lava:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

--------------------------------------------------------------------------------
-- Grass
--------------------------------------------------------------------------------

    -- Grass Class
    Grass = {}
    Grass.__index = Grass
    function Grass:Create(xo,yo)
        local this =
        {
            x = xo,
            y = yo,
            c1 = 80/255 + adjust,
            c2 = 150/255 + adjust,
            c3 = 60/255 + adjust,
        }
        setmetatable(this, Grass)
        board.grid[yo][xo] = "grass"
        return this
    end

    -- Grass Animate
    function Grass:Animate()
        love.graphics.setColor(self.c1, self.c2, self.c3)
        drawCell(self.x, self.y)
    end

    -- Grass to Tree
    function Grass:Grass_to_Tree()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local grass_tree = spread(board.grid, self.x, self.y, "tree")
            if math.random() < grass_tree/grass_tree_rate then
                table.insert(tree_table, Tree:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

    -- Grass to Dirt
    function Grass:Grass_to_Dirt()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local grass_water = spread(board.grid, self.x, self.y, "water")
            if math.random() < grass_water/grass_dirt_rate then
                table.insert(dirt_table, Dirt:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

    -- Grass to Lava
    function Grass:Grass_to_Lava()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local grass_lava = spread(board.grid, self.x, self.y, "lava")
            if math.random() < grass_lava/grass_lava_rate then
                table.insert(lava_table, Lava:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

    --------------------------------------------------------------------------------
    -- Tree
    --------------------------------------------------------------------------------

    -- Tree Class
    Tree = {}
    Tree.__index = Tree
    function Tree:Create(xo,yo)
        local this =
        {
            x = xo,
            y = yo,
            c1 = (20 + math.random(50))/255 + adjust,
            c2 = (80 + math.random(50))/255 + adjust,
            c3 = (20 + math.random(10))/255 + adjust,
            hp = 10,
        }
        setmetatable(this, Tree)
        board.grid[yo][xo] = "tree"
        return this
    end

    -- Tree Animate
    function Tree:Animate()
        love.graphics.setColor(self.c1, self.c2, self.c3)
        drawCell(self.x, self.y)
    end

    -- Tree to Dirt
    function Tree:Tree_to_Dirt()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local tree_water = spread(board.grid, self.x, self.y, "water")
            local tree_tree = spread(board.grid, self.x, self.y, "tree")
            if math.random() < (tree_water+ tree_tree)/tree_dirt_rate then
                table.insert(dirt_table, Dirt:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

    -- Tree to Lava
    function Tree:Tree_to_Lava()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local tree_lava = spread(board.grid, self.x, self.y, "lava")
            if math.random() < tree_lava/tree_lava_rate then
                table.insert(lava_table, Lava:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

--------------------------------------------------------------------------------
-- Lava
--------------------------------------------------------------------------------
    -- Lava Class
    Lava = {}
    Lava.__index = Lava
    function Lava:Create(xo,yo)
        local this =
        {
            x = xo,
            y = yo,
            c1 = (150 + math.random(10))/255,
            c2 = (50 + math.random(10))/255,
            c3 = (50 + math.random(10))/255,
            blink = true,
        }
        setmetatable(this, Lava)
        board.grid[yo][xo] = "lava"
        return this
    end

    -- Lava Animate
    function Lava:Animate()
        love.graphics.setColor(self.c1, self.c2, self.c3)
        if self.blink == true then
            self:Blink()
        end
        drawCell(self.x, self.y)
    end

    -- Lava Blink
    function Lava:Blink()
        self.c1 = math.random()/2 + 0.5
        self.c2 = math.random()/2
        self.c3 = math.random()/2
    end

    -- Lava to Dirt
    function Lava:Lava_to_Dirt()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local lava_lava = spread(board.grid, self.x, self.y, "lava")
            if math.random() < (lava_lava + 1)/lava_dirt_rate then
                table.insert(dirt_table, Dirt:Create(self.x, self.y))
                result = true
            end
        end
        return result
    end

--------------------------------------------------------------------------------
-- Stone
--------------------------------------------------------------------------------

    -- Stone Class
    Stone = {}
    Stone.__index = Stone
    function Stone:Create(xo,yo)
        local this =
        {
            x = xo,
            y = yo,
            c1 = 40/255,
            c2 = 50/255,
            c3 = 60/255,
        }
        setmetatable(this, Stone)
        board.grid[yo][xo] = "stone"
        return this
    end

    -- Stone Animate
    function Stone:Animate()
        love.graphics.setColor(self.c1, self.c2, self.c3)
        drawCell(self.x, self.y)
    end

    -- Stone to Dirt
    function Stone:Stone_to_Dirt()
        local result = false
        if self.x > 1 and self.x < gridXCount and self.y > 1 and self.y < gridYCount then
            local stone_water = spread(board.grid,self.x,self.y,"water")
            if math.random() < stone_water/80 then
                table.insert(dirt_table, Dirt:Create(self.x,self.y))
                result = true
            end
        end
        return result
    end

--------------------------------------------------------------------------------

    -- Setup Board
    board = Board:Create()
    Board:Ocean()
    Board:Island()

end

--------------------------------------------------------------------------------

function love.update(dt)

    for k,v in pairs(water_table) do
        if v:Water_to_Stone() then
            table.remove(water_table, k)
        end
    end
    for k,v in pairs(dirt_table) do
        if v:Dirt_to_Sand() then
            table.remove(dirt_table, k)
        end
        if v:Dirt_to_Grass() then
            table.remove(dirt_table, k)
        end
        if v:Dirt_to_Lava() then
            table.remove(dirt_table, k)
        end
    end
    for k,v in pairs(sand_table) do
        if v:Sand_to_Water() then
            table.remove(sand_table, k)
        end
        if v:Sand_to_Dirt() then
            table.remove(sand_table, k)
        end
        if v:Sand_to_Lava() then
            table.remove(sand_table, k)
        end
    end
    for k,v in pairs(grass_table) do
        if v:Grass_to_Tree() then
            table.remove(grass_table, k)
        end
        if v:Grass_to_Dirt() then
            table.remove(grass_table, k)
        end
        if v:Grass_to_Lava() then
            table.remove(grass_table, k)
        end
    end
    for k,v in pairs(stone_table) do
        if v:Stone_to_Dirt() then
            table.remove(stone_table, k)
        end
    end
    for k,v in pairs(tree_table) do
        if v:Tree_to_Dirt() then
            table.remove(tree_table, k)
        end
        if v:Tree_to_Lava() then
            table.remove(tree_table, k)
        end
    end
    for k,v in pairs(lava_table) do
        if v:Lava_to_Dirt() then
            table.remove(lava_table, k)
        end
    end

    -- Seasons Change
    if reverse_seasons == false then
        adjust = 1/255
    else
        adjust = -1/255
    end

    -- Grass Seasons
    for k,v in pairs(grass_table) do
        if math.random() < 0.1 then
            v.c1 = v.c1 + adjust
            v.c2 = v.c2 + adjust
            v.c3 = v.c3 + adjust
        end
        if (v.c1 + v.c2 + v.c3)/3 > 0.98 then
            reverse_seasons = true
        end
        if (v.c1 + v.c2 + v.c3)/3 < 0.02 then
            reverse_seasons = false
        end
    end

    -- Tree Seasons
    for k,v in pairs(tree_table) do
        if math.random() < 0.1 then
            v.c1 = v.c1 + adjust
            v.c2 = v.c2 + adjust
            v.c3 = v.c3 + adjust
        end

        if (v.c1 + v.c2 + v.c3)/3 > 0.98 then
            reverse_seasons = true
        end
        if (v.c1 + v.c2 + v.c3)/3 < 0.02 then
            reverse_seasons = false
        end
    end

    -- Add a Volcano
    if math.random() < add_volcano_rate then
        x = math.random(5, gridXCount - 5)
        y = math.random(5, gridYCount - 5)
        table.insert(lava_table, Lava:Create(x,y))
    end

    -- Add a Tree
    if math.random() < add_tree_rate then
        x = math.random(5, gridXCount - 5)
        y = math.random(5, gridYCount - 5)
        if board.grid[y][x] == "grass" then
            table.insert(tree_table, Tree:Create(x,y))
        end
    end

end

--------------------------------------------------------------------------------

-- Draw Everything
function love.draw()
    for k,v in pairs(water_table) do
        v:Animate()
    end
    for k,v in pairs(dirt_table) do
        v:Animate()
    end
    for k,v in pairs(sand_table) do
        v:Animate()
    end
    for k,v in pairs(grass_table) do
        v:Animate()
    end
    for k,v in pairs(stone_table) do
        v:Animate()
    end
    for k,v in pairs(lava_table) do
        v:Animate()
    end
    for k,v in pairs(tree_table) do
        v:Animate()
    end
end