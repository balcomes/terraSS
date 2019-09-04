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
    tick = 1
    season_days = 1000

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
        --[[
        -- Grass Seasons
        ahead_id = math.floor((tick + season_days/2)/season_days) % 4 + 1
        behind_id = math.floor((tick - season_days/2)/season_days) % 4 + 1
        ahead_fraction = tick/season_days
        local vc1 = 0
        local vc2 = 0
        local vc3 = 0

        if math.random() < ahead_fraction then
            if ahead_id == 1 then
                vc1 = math.random(75,100)/255
                vc2 = math.random(150, 200)/255
                vc3 = 0
            end
            if ahead_id == 2 then
                vc1 = math.random(50, 150)/255
                vc2 = math.random(100, 150)/255
                vc3 = 0
            end
            if ahead_id == 3 then
                vc1 = 1
                vc2 = 1
                vc3 = 1
            end
            if ahead_id == 4 then
                vc1 = math.random(125, 200)/255
                vc2 = 250/255
                vc3 = math.random(0, 150)/255
            end
        else
            if behind_id == 1 then
                vc1 = math.random(75,100)/255
                vc2 = math.random(150, 200)/255
                vc3 = 0
            end
            if behind_id == 2 then
                vc1 = math.random(50, 150)/255
                vc2 = math.random(100, 150)/255
                vc3 = 0
            end
            if behind_id == 3 then
                vc1 = 1
                vc2 = 1
                vc3 = 1
            end
            if behind_id == 4 then
                vc1 = math.random(125, 200)/255
                vc2 = 250/255
                vc3 = math.random(0, 150)/255
            end
        end
        ]]--

        local this =
        {
            x = xo,
            y = yo,
            c1 = math.random(75,100)/255,
            c2 = math.random(150, 200)/255,
            c3 = 0,
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

        -- Tree Seasons
        --[[
        ahead_id = math.floor((tick + season_days/2)/season_days) % 4 + 1
        behind_id = math.floor((tick - season_days/2)/season_days) % 4 + 1
        ahead_fraction = tick/season_days
        local vc1 = 0
        local vc2 = 0
        local vc3 = 0

        if math.random() < ahead_fraction then
            if ahead_id == 1 then
                vc1 = math.random(0, 50)/255
                vc2 = math.random(50,100)/255
                vc3 = 0
            end
            if ahead_id == 2 then
                vc1 = math.random(150, 200)/255
                vc2 = math.random(0, 200)/255
                vc3 = 0
            end
            if ahead_id == 3 then
                vc1 = math.random(50, 150)/255
                vc2 = math.random(25, 75)/255
                vc3 = 0
            end
            if ahead_id == 4 then
                vc1 = math.random(200, 250)/255
                vc2 = math.random(0, 150)/255
                vc3 = math.random(100, 250)/255
            end
        else
            if behind_id == 1 then
                vc1 = math.random(0, 50)/255
                vc2 = math.random(50,100)/255
                vc3 = 0
            end
            if behind_id == 2 then
                vc1 = math.random(150, 200)/255
                vc2 = math.random(0, 200)/255
                vc3 = 0
            end
            if behind_id == 3 then
                vc1 = math.random(50, 150)/255
                vc2 = math.random(25, 75)/255
                vc3 = 0
            end
            if behind_id == 4 then
                vc1 = math.random(200, 250)/255
                vc2 = math.random(0, 150)/255
                vc3 = math.random(100, 250)/255
            end
        end
        ]]--

        local this =
        {
            x = xo,
            y = yo,
            c1 = math.random(0, 50)/255,
            c2 = math.random(50,100)/255,
            c3 = 0,
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

    tick = tick + 1
    if tick > 4*season_days then
        tick = 1
    end

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

    -- 75-100, 150-200, 0
    -- 0-50, 50-100, 0

    -- 50-150, 100-150, 0
    -- 150-200, 0-200, 0

    -- 250, 250, 250
    -- 50-150, 25-75, 0

    -- 125-200, 255, 0-150
    -- 200-250, 0-150, 100-250

    --10,000 per season 40,000

    -- math.random(75,100) math.random(150, 200) 0
    -- math.random(0, 50) math.random(50,100) 0

    -- math.random(50, 150) math.random(100, 150) 0
    -- math.random(150, 200) math.random(0, 200) 0

    -- 250 250 250
    -- math.random(50, 150) math.random(25, 75) 0

    -- math.random(125, 200) 250 math.random(0, 150)
    -- math.random(200, 250) math.random(0, 150) math.random(100, 250)



    -- print(math.floor((4000 + 5000)/season_days) % 4 + 1)
    -- print(math.floor((4000 - 5000)/season_days) % 4 + 1)

    -- print(4000/season_days)
    -- print(1-4000/season_days)
    ahead_id = math.floor((tick + season_days/2)/season_days) % 4 + 1
    behind_id = math.floor((tick - season_days/2)/season_days) % 4 + 1
    ahead_fraction = tick/season_days
    behind_fraction = 1 - ahead_fraction

    -- Grass Seasons
    for k,v in pairs(grass_table) do
        if ahead_id == 1 then
            v.c1 = (v.c1 + ahead_fraction*(75+100)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c2 = (v.c2 + ahead_fraction*(150+200)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c3 = (v.c1 + ahead_fraction*0)/(1+ahead_fraction*1/season_days)
        end
        if ahead_id == 2 then
            v.c1 = (v.c1 + ahead_fraction*(50 + 150)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c2 = (v.c2 + ahead_fraction*(100 + 150)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c3 = (v.c3 + ahead_fraction*0)/(1+ahead_fraction*1/season_days)
        end
        if ahead_id == 3 then
            v.c1 = (v.c1 + ahead_fraction*1)/(1+ahead_fraction*1/season_days)
            v.c2 = (v.c2 + ahead_fraction*1)/(1+ahead_fraction*1/season_days)
            v.c3 = (v.c3 + ahead_fraction*1)/(1+ahead_fraction*1/season_days)
        end
        if ahead_id == 4 then
            v.c1 = (v.c1 + ahead_fraction*(125 + 200)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c2 = (v.c2 + ahead_fraction*1)/(1+ahead_fraction*1/season_days)
            v.c3 = (v.c3 + ahead_fraction*(0 + 150)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
        end

        if behind_id == 1 then
            v.c1 = (v.c1 + behind_fraction*(75 + 100)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c2 = (v.c2 + behind_fraction*(150 + 200)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c3 = (v.c3 + behind_fraction*0)/(1+behind_fraction*1/season_days)
        end
        if behind_id == 2 then
            v.c1 = (v.c1 + behind_fraction*(50 + 150)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c2 = (v.c2 + behind_fraction*(100 + 150)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c3 = (v.c3 + behind_fraction*0)/(1+behind_fraction*1/season_days)
        end
        if behind_id == 3 then
            v.c1 = (v.c1 + behind_fraction*1)/(1+behind_fraction*1/season_days)
            v.c2 = (v.c2 + behind_fraction*1)/(1+behind_fraction*1/season_days)
            v.c3 = (v.c3 + behind_fraction*1)/(1+behind_fraction*1/season_days)
        end
        if behind_id == 4 then
            v.c1 = (v.c1 + behind_fraction*(125 + 200)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c2 = (v.c2 + behind_fraction*1)/(1+behind_fraction*1/season_days)
            v.c3 = (v.c3 + behind_fraction*(0 + 150)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
        end
    end

    -- Tree Seasons
    for k,v in pairs(tree_table) do
        if ahead_id == 1 then
            v.c1 = (v.c1 + ahead_fraction*(0 + 50)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c2 = (v.c2 + ahead_fraction*(50 + 100)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c3 = (v.c3 + ahead_fraction*0)/(1+ahead_fraction*1/season_days)
        end
        if ahead_id == 2 then
            v.c1 = (v.c1 + ahead_fraction*(150 + 200)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c2 = (v.c2 + ahead_fraction*(0 + 200)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c3 = (v.c3 + ahead_fraction*0)/(1+ahead_fraction*1/season_days)
        end
        if ahead_id == 3 then
            v.c1 = (v.c1 + ahead_fraction*(50 + 150)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c2 = (v.c2 + ahead_fraction*(25 + 75)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c3 = (v.c3 + ahead_fraction*0)/(1+ahead_fraction*1/season_days)
        end
        if ahead_id == 4 then
            v.c1 = (v.c1 + ahead_fraction*(200 + 250)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c2 = (v.c2 + ahead_fraction*(0 + 150)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
            v.c3 = (v.c3 + ahead_fraction*(100 + 250)/(2*255)/season_days)/(1+ahead_fraction*1/season_days)
        end

        if behind_id == 1 then
            v.c1 = (v.c1 + behind_fraction*(0 + 50)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c2 = (v.c2 + behind_fraction*(50 + 100)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c3 = (v.c3 + behind_fraction*0)/(1+behind_fraction*1/season_days)
        end
        if behind_id == 2 then
            v.c1 = (v.c1 + behind_fraction*(150 + 200)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c2 = (v.c2 + behind_fraction*(0 + 200)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c3 = (v.c3 + behind_fraction*0)/(1+behind_fraction*1/season_days)
        end
        if behind_id == 3 then
            v.c1 = (v.c1 + behind_fraction*(50 + 150)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c2 = (v.c2 + behind_fraction*(25 + 75)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c3 = (v.c3 + behind_fraction*0)/(1+behind_fraction*1/season_days)
        end
        if behind_id == 4 then
            v.c1 = (v.c1 + behind_fraction*(200 + 250)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c2 = (v.c2 + behind_fraction*(0 + 150)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
            v.c3 = (v.c3 + behind_fraction*(100 + 250)/(2*255)/season_days)/(1+behind_fraction*1/season_days)
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
