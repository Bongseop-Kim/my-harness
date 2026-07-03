-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 줄바꿈
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

-- 4스페이스 인덴트
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- 줄번호
vim.opt.number = true

-- 키보드 이동 효율을 위한 상대 줄번호
vim.opt.relativenumber = true

-- 커서 주변 여백 (스크롤 시 8줄 유지)
vim.opt.scrolloff = 8

-- 시스템 클립보드 연동
vim.opt.clipboard = "unnamedplus"
