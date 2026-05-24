return {
  {
    'monkoose/neocodeium',
    event = 'VeryLazy',
    config = function()
      local neocodeium = require 'neocodeium'
      local blink = require 'blink.cmp'

      neocodeium.setup {
        filter = function()
          -- Only show AI suggestions when Blink menu is closed
          return not blink.is_visible()
        end,
        manual = true,
      }
      vim.api.nvim_create_autocmd('User', {
        pattern = 'BlinkCmpMenuOpen',
        callback = function() neocodeium.clear() end,
      })

      vim.keymap.set('i', '<A-f>', function() neocodeium.accept() end)

      vim.keymap.set('i', '<A-e>', function() neocodeium.cycle_or_complete() end)
    end,
  },
}
