-- vimrc 설정 로드
vim.cmd('source ~/.config/nvim/vimConfig.vim')

vim.g.mapleader = " "

-- lazy.nvim 로드 (플러그인 관리)
require("config.lazy")

---- Custom Keymaps
-- Register to Clipboard
vim.keymap.set('n', '<leader>rtc', function()
  local reg = vim.fn.nr2char(vim.fn.getchar())
  vim.fn.setreg('+', vim.fn.getreg(reg))
  
  print('Copied register "' .. reg .. '" to clipboard')
end, { desc = 'Paste register to clipboard' })

-- Clipboard to Register
vim.keymap.set('n', '<leader>ctr', function()
  local reg = vim.fn.nr2char(vim.fn.getchar())
  vim.fn.setreg(reg, vim.fn.getreg('+'))
  
  print('Pasted clipboard to register "' .. reg .. '"')
end, { desc = 'Paste clipboard to register' })

vim.keymap.set('n', '<leader>x', 'dd', { desc = 'Cut current line' })

if vim.g.vscode then
  -- 탭 이동
  vim.keymap.set('n', 'gh', "<cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>")
  vim.keymap.set('n', 'gl', "<cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>")

  vim.keymap.set('n', 'gH', "<cmd>call VSCodeNotify('workbench.action.moveEditorLeftInGroup')<CR>")
  vim.keymap.set('n', 'gL', "<cmd>call VSCodeNotify('workbench.action.moveEditorRightInGroup')<CR>")
else
  -- 일반 Neovim 환경
  -- gh -> 왼쪽 탭 선택, gl -> 오른쪽 탭 선택
  vim.keymap.set('n', 'gh', 'gT')
  vim.keymap.set('n', 'gl', 'gt')
  -- 탭 위치 이동
  vim.keymap.set("n", "gH", ":tabmove -1<CR>", { silent = true })
  vim.keymap.set("n", "gL", ":tabmove +1<CR>", { silent = true })
end

-- 현재 파일 이름 복사 (확장자 제외)
vim.keymap.set('n', '<leader>cf', function()
  local filename = vim.fn.expand('%:t:r')
  vim.fn.setreg('+', filename)
  print('Copied: ' .. filename)
end, { desc = 'Copy filename without extension' })

-- Yank시 하이라이트 
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = 'Search' })
  end,
})

-- o로 새 라인 만들 땐 코멘트 상태 해제
-- Enter로 새 라인 만들 땐 코멘트 상태 유지
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    -- 현재 버퍼의 formatoptions에서 o를 빼고 r을 더함
    vim.opt_local.formatoptions:remove("o")
    vim.opt_local.formatoptions:append("r")
  end,
})

-- <leader>{1~9} 탭 이동
for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, function()
    vim.cmd("tabnext " .. i)
  end, { desc = "Go to tab " .. i, silent = true })
end

-- 터미널 모드에서 Esc로 Normal 모드 복귀
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
---- endof Custom Keymaps

-- Neovide로 켤 때만 특정 디렉토리로 이동
if vim.g.neovide then
    local default_path = vim.fn.expand("~/Documents/workspace") 
    vim.api.nvim_set_current_dir(default_path)
end

---- netrw 설정
-- 라인넘버 표시 등..
vim.g.netrw_bufsettings = 'noma nomod nu nobl nowrap ro'
-- `mf`로 마크 시 색상
vim.api.nvim_set_hl(0, "netrwMarkFile", { bg = "#ff5f5f", fg = "#000000", bold = true })

