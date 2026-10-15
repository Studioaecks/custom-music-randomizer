return function(mod)
  -- Custom Music Randomizer for Gen1Recomp
  -- Drop .ogg / .mp3 / .wav / .flac into context folders under assets/music/
  -- and the mod randomly selects from the matching folder via music.select.

  local CATEGORIES = {
    "battle", "overworld", "gym", "forest", "cave",
    "indoor", "water", "trainer", "wild", "jingle", "title"
  }

  local tracks = {}
  local loaded = false

  local function scanFolders()
    if loaded then return end
    loaded = true
    local base = mod.path and (mod.path .. "/assets/music") or "assets/music"
    for _, cat in ipairs(CATEGORIES) do
      tracks[cat] = {}
      local dir = base .. "/" .. cat
      local ok, files = pcall(function()
        return love.filesystem.getDirectoryItems(dir)
      end)
      if ok and files then
        for _, f in ipairs(files) do
          local lower = f:lower()
          if lower:match("%.ogg$") or lower:match("%.mp3$") or
             lower:match("%.wav$") or lower:match("%.flac$") then
            table.insert(tracks[cat], dir .. "/" .. f)
          end
        end
      end
      mod.log:info("Category %s: %d tracks", cat, #tracks[cat])
    end
  end

  local function pick(cat)
    local list = tracks[cat]
    if not list or #list == 0 then return nil end
    return list[math.random(#list)]
  end

  local function decideCategory(song, ctx)
    if not ctx then return "overworld" end
    local reason = (ctx.reason or ""):lower()
    local mapId = (ctx.mapId or ""):lower()
    local kind = (ctx.battleKind or ctx.kind or ""):lower()

    if reason:find("battle") or kind:find("battle") or kind:find("trainer") or kind:find("wild") then
      if kind:find("trainer") or reason:find("trainer") then return "trainer" end
      if kind:find("wild") then return "wild" end
      return "battle"
    end
    if reason:find("jingle") or reason:find("fanfare") or reason:find("heal") or reason:find("evolution") then
      return "jingle"
    end
    if reason:find("title") or reason:find("intro") then return "title" end

    if mapId:find("gym") or mapId:find("league") then return "gym" end
    if mapId:find("forest") or mapId:find("viridian") then return "forest" end
    if mapId:find("cave") or mapId:find("mt") or mapId:find("tunnel") then return "cave" end
    if mapId:find("center") or mapId:find("mart") or mapId:find("house") or mapId:find("lab") or mapId:find("room") then
      return "indoor"
    end
    if mapId:find("water") or mapId:find("sea") or mapId:find("lake") or ctx.surfing then
      return "water"
    end
    return "overworld"
  end

  mod.options:define({
    { key = "enabled", label = "ENABLE CUSTOM MUSIC", type = "toggle", default = true },
    { key = "shuffle", label = "SHUFFLE WITHIN CATEGORY", type = "toggle", default = true },
    { key = "fallback", label = "FALL BACK TO ORIGINAL", type = "toggle", default = true },
    { key = "volume_scale", label = "VOLUME SCALE", type = "number", default = 1.0, min = 0.2, max = 1.5, step = 0.1 },
  })

  -- Hook every song choice
  mod.hooks:wrap("music.select", function(next, song, ctx)
    local original = next(song, ctx)
    if not mod.options:get("enabled") then return original end

    scanFolders()
    local cat = decideCategory(original, ctx)
    local file = pick(cat)

    if file then
      local songId = "custom_rand_" .. cat
      pcall(function()
        mod.content.music:register(songId, {
          file = file,
          name = "Custom " .. cat:upper(),
          loop = true
        })
      end)
      mod.log:info("Playing custom %s track: %s", cat, file)
      return songId
    end

    if mod.options:get("fallback") then
      return original
    end
    return nil
  end)

  -- Optional volume hook
  mod.hooks:wrap("music.volume", function(next, vol, ctx)
    local v = next(vol, ctx)
    if mod.options:get("enabled") then
      v = v * (mod.options:get("volume_scale") or 1.0)
    end
    return v
  end)

  -- Force scan on ready
  mod.events:on("game.ready", function()
    scanFolders()
    mod.log:info("Custom Music Randomizer ready. Drop tracks into assets/music/<category>/")
  end)

  mod.log:info("Custom Music Randomizer loaded.")
end
