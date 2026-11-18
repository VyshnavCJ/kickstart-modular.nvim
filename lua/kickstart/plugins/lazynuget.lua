local lazy_nuget

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {},
  keys = {
    {
      '<leader>np',
      function()
        if not lazy_nuget then
          lazy_nuget = require('toggleterm.terminal').Terminal:new {
            cmd = 'lazynuget',
            direction = 'float',
          }
        end
        lazy_nuget:toggle()
      end,
      desc = 'Open LazyNuGet popup',
    },
  },
}
