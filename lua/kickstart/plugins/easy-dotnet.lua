return {
  'GustavEikaas/easy-dotnet.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'mfussenegger/nvim-dap',
    'nvim-telescope/telescope.nvim',
  },
  ft = { 'cs', 'csproj', 'fs', 'fsproj' },
  config = function()
    local dotnet_tools = vim.fn.expand '~/.dotnet/tools'
    if vim.fn.isdirectory(dotnet_tools) == 1 and not vim.env.PATH:find(dotnet_tools, 1, true) then
      vim.env.PATH = dotnet_tools .. ':' .. vim.env.PATH
    end

    local dotnet_binary = vim.fn.exepath 'dotnet'
    if dotnet_binary ~= '' then
      local dotnet_root = vim.fn.fnamemodify(dotnet_binary, ':h')
      if vim.fn.isdirectory(dotnet_root) == 1 then
        vim.env.DOTNET_ROOT = dotnet_root
      end
    end

    local dotnet = require 'easy-dotnet'

    dotnet.setup {
      picker = 'telescope',
      managed_terminal = {
        auto_hide = true,
        auto_hide_delay = 1000,
        mappings = {
          next_tab = { lhs = '<Tab>', desc = 'Next terminal tab' },
          prev_tab = { lhs = '<S-Tab>', desc = 'Previous terminal tab' },
          new_terminal = { lhs = '+', desc = 'New user terminal' },
          close_terminal = { lhs = 'X', desc = 'Close current terminal tab' },
          hide_panel = { lhs = 'q', desc = 'Hide terminal panel' },
        },
      },
      projx_lsp = {
        enabled = true,
      },
      lsp = {
        enabled = true,
        preload_roslyn = true,
        restart_roslyn_on_branch_change = true,
      },
      debugger = {
        engine = 'netcoredbg',
        console = 'externalTerminal',
        auto_register_dap = true,
      },
      external_terminal = {
        command = 'osascript',
        args = {
          '-e',
          [[
            on run argv
              set commandLine to ""
              repeat with argument in argv
                set commandLine to commandLine & quoted form of (contents of argument) & " "
              end repeat
              set commandLine to "/bin/zsh -lc " & quoted form of (commandLine & "; status=$?; echo; echo 'Process exited with status ' $status '. Press Enter to close.'; read -r; exit $status")
              tell application "iTerm2"
                create window with default profile command commandLine
              end tell
            end run
          ]],
        },
      },
      test_runner = {
        auto_start_testrunner = true,
        neotest_integration = false,
      },
      auto_bootstrap_namespace = {
        type = 'file_scoped',
        enabled = true,
      },
    }

    vim.keymap.set('n', '<A-t>', '<cmd>Dotnet testrunner<CR>', { nowait = true, desc = 'Toggle .NET test runner' })
    vim.keymap.set('n', '<C-A-p>', '<cmd>Dotnet debug profile default<CR>', { nowait = true, desc = 'Debug .NET default profile' })
    vim.keymap.set('n', '<C-p>', '<cmd>Dotnet run profile default<CR>', { nowait = true, desc = 'Run .NET default profile' })
    vim.keymap.set('n', '<C-b>', dotnet.build_default_quickfix, { nowait = true, desc = 'Build .NET default project' })
    vim.keymap.set({ 'n', 't' }, '<A-i>', '<cmd>Dotnet terminal toggle<CR>', {
      noremap = true,
      silent = true,
      desc = 'Toggle .NET terminal',
    })
  end,
}
