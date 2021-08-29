return {
  'matze/vim-move',
  event = 'BufLeave', -- when leaving dashboard buffer
  setup = function()
    -- change vim-vim modifier key from alt/option to shift
    vim.g.move_key_modifier = 'S'
  end,
}
