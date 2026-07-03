return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    modes = {
      search = {
        enabled = true
      },
      char = {
        char_actions = function(motion)
          return {
            [";"] = "next",
            [","] = "prev",
            -- flash 기본 설정인 clever-f style 제거
            -- [motion:lower()] = "next",
            -- [motion:upper()] = "prev",
          }
        end,
      }
    }
  },
  keys = {
    { "S", mode = { "n" }, function() require("flash").jump({
      jump = { register = true, history = true },
    }) end, desc = "Flash" },
    -- { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
