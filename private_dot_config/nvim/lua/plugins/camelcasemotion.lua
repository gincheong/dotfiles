return {
  {
    'bkad/CamelCaseMotion',
    config = function()
      -- CamelCaseMotion 키 매핑
      -- n = normal, o = operator-pending, x = visual mode
      vim.keymap.set({'n', 'o', 'x'}, 'w', '<Plug>CamelCaseMotion_w', { silent = true })
      vim.keymap.set({'n', 'o', 'x'}, 'b', '<Plug>CamelCaseMotion_b', { silent = true })
      vim.keymap.set({'n', 'o', 'x'}, 'e', '<Plug>CamelCaseMotion_e', { silent = true })
    end,
  }
}
