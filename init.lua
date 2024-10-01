-- REMAP
vim.g.mapleader = " "
vim.keymap.set("n", "<C-f>", "<nop>")
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<LEADER>w", "<CMD>w<CR>")
vim.keymap.set("n", "<LEADER><LEADER>", "<CMD>so<CR>")
vim.keymap.set("n", "<LEADER>pv", "<CMD>Ex<CR>")
vim.keymap.set("n", "<LEADER>tw", "<CMD>set wrap!<CR>")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "gJ", "mzgJ`z")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set({"n", "v"}, "j", "gj")
vim.keymap.set({"n", "v"}, "k", "gk")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "*", "*zzzv")
vim.keymap.set("n", "#", "#zzzv")

vim.keymap.set("n", "<A-h>", "<C-w>h")
vim.keymap.set("n", "<A-j>", "<C-w>j")
vim.keymap.set("n", "<A-k>", "<C-w>k")
vim.keymap.set("n", "<A-l>", "<C-w>l")

vim.keymap.set({"n", "v"}, "<LEADER>y", [["+y]])
vim.keymap.set("n", "<LEADER>Y", [["+Y]])
vim.keymap.set("x", "<LEADER>p", [["_dP]])
vim.keymap.set({"n", "v"}, "<LEADER>d", [["_d]])
vim.keymap.set({"n", "v"}, "<LEADER>c", [["_c]])
vim.keymap.set({"n", "v"}, "<LEADER>x", [["_x]])

vim.keymap.set("n", "<LEADER>s", ":%s/<C-r><C-w>/<C-r><C-w>/g<Left><Left>")
vim.keymap.set("n", "<C-s>", ":%s//g<Left><Left>")
vim.keymap.set("v", "<LEADER>s", "\"hy:%s/<C-r>h/<C-r>h/g<Left><Left>")
vim.keymap.set("v", "<C-s>", ":s//g<Left><Left>")
vim.keymap.set("v", "<C-n>", ":normal ")

-- Will specifically search in files in the program directory
vim.keymap.set("n", "<LEADER>qg", ":silent grep  program<C-Left><Left>")
vim.keymap.set("n", "<LEADER>qo", "<CMD>copen<CR>")
vim.keymap.set("n", "<LEADER>qr", ":cdo s//g<Left><Left>")
vim.keymap.set("n", "<LEADER>qw", "\"+yiw:silent grep <C-r><C-w> program<CR><CMD>copen<CR>")
vim.keymap.set("n", "<LEADER>qW", "\"+yiw:silent grep <C-r><C-a> program<CR><CMD>copen<CR>")
vim.keymap.set("v", "<LEADER>q", "\"+ygv\"hy:silent grep <C-r>h program<CR><CMD>copen<CR>")

vim.keymap.set("n", "<LEADER>v", "<CMD>!./script/clean.bat<CR>")
vim.keymap.set("n", "<LEADER>b", "<CMD>!./script/build.bat<CR>")
vim.keymap.set("n", "<LEADER>n", "<CMD>!./script/run.bat<CR>")
vim.keymap.set("n", "<LEADER>m", "<CMD>!./script/debug.bat<CR>")
-- REMAP

-- SET
vim.g.netrw_banner = 0

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "no"
vim.opt.colorcolumn = "100"

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.scrolloff = 8
vim.opt.textwidth = 100
vim.opt.formatoptions:remove("t")
vim.opt.formatoptions:remove("c")

vim.opt.autoread = true
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.ignorecase = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.opt.termguicolors = false

vim.opt.isfname:append("@-@")
vim.opt.updatetime = 300

vim.api.nvim_create_autocmd("VimResized", { command = "wincmd =" })
-- SET

-- COLORS
vim.api.nvim_create_autocmd({"BufEnter", "WinEnter"},
{
  callback = function()
    local separator = " ▎ "
    vim.opt.statuscolumn =
    '%s%=%#LineNr4#%{(v:relnum >= 4)?v:relnum.\"' .. separator .. '\":\"\"}' ..
    '%#LineNr3#%{(v:relnum == 3)?v:relnum.\"' .. separator .. '\":\"\"}' ..
    '%#LineNr2#%{(v:relnum == 2)?v:relnum.\"' .. separator .. '\":\"\"}' ..
    '%#LineNr1#%{(v:relnum == 1)?v:relnum.\"' .. separator .. '\":\"\"}' ..
    '%#LineNr0#%{(v:relnum == 0)?v:lnum.\"' .. separator .. '\":\"\"}'
  end
})
-- COLORS

-- C/C++
local function assign_files(long_files, cwd)
  local files = {}
  for _, file in ipairs(long_files) do
    local new_file = string.gsub(file, cwd .. "\\", "")
    new_file = string.gsub(new_file, "\\", "/")
    table.insert(files, new_file)
  end

  return files
end

local function assign_cc_file_types(files)
  local source = ""
  local header = ""

  for _, file in ipairs(files) do
    if string.match(file, "%.c$") then
      source = file
    elseif string.match(file, "%.h$") then
      header = file
    end
  end

  return source, header
end

function switch_file_in_cc_unit(dir)
  if not string.match(vim.fn.expand("%:e"), "c") and not string.match(vim.fn.expand("%:e"), "h") then
    vim.notify("Not a source or header file!", "error")
    return
  end

  local cwd = vim.fn.getcwd()
  local name = vim.fn.expand("%:t:r")
  local long_files = vim.fn.globpath(dir, "**/" .. name .. ".*", 0, 1)
  local files = assign_files(long_files, cwd)

  if #files == 0 then
    vim.notify("Problem reading filename!", "error")

  elseif #files == 1 then
    vim.notify("There is only one file in this compilation unit!", "error")

  elseif #files == 2 then
    local source, header = assign_file_types(files)
    local other_file = ""

    if string.match(vim.fn.expand("%:e"), "c") then
      other_file = header
    elseif string.match(vim.fn.expand("%:e"), "h") then
      other_file = source
    else
      vim.notify("Unexpected file extension!", "error")
      return
    end
    vim.cmd("edit " .. other_file)

  else
    vim.notify("Unexpectedly high amount of corresponding files found!", "error")
  end
end
vim.keymap.set("n", "<LEADER>pU", function() switch_file_in_unit(vim.fn.getcwd() .. "/program") end)
                    -- Folder to recursively search for files in the compilation unit ^^^

local function find_one_from_two(file1, file2)
  if file1 ~= "" then
    return file1
  elseif file2 ~= "" then
    return file2
  end
end

local function assign_cxx_file_types(files)
  local source = ""
  local header = ""
  local inline = ""

  for _, file in ipairs(files) do
    if string.match(file, "%.cpp$") then
      source = file
    elseif string.match(file, "%.hpp$") then
      header = file
    elseif string.match(file, "%.inl$") then
      inline = file
    end
  end

  return source, header, inline
end

function switch_file_in_cxx_unit(dir)
  if not string.match(vim.fn.expand("%:e"), "cpp") and not string.match(vim.fn.expand("%:e"), "hpp") and not string.match(vim.fn.expand("%:e"), "inl") then
    vim.notify("Not a source, header or inline file!", "error")
    return
  end

  local cwd = vim.fn.getcwd()
  local name = vim.fn.expand("%:t:r")
  local long_files = vim.fn.globpath(dir, "**/" .. name .. ".*", 0, 1)
  local files = assign_files(long_files, cwd)

  if #files == 0 then
    vim.notify("Problem reading filename!", "error")

  elseif #files == 1 then
    vim.notify("There is only one file in this compilation unit!", "error")

  elseif #files == 2 then
    local source, header, inline = assign_cxx_file_types(files)
    local other_file = ""

    if string.match(vim.fn.expand("%:e"), "cpp") then
      other_file = find_one_from_two(header, inline)
    elseif string.match(vim.fn.expand("%:e"), "hpp") then
      other_file = find_one_from_two(source, inline)
    elseif string.match(vim.fn.expand("%:e"), "inl") then
      other_file = find_one_from_two(source, header)
    else
      vim.notify("Unexpected file extension!", "error")
      return
    end
    vim.cmd("edit " .. other_file)

  elseif #files == 3 then
    local source, header, inline = assign_cxx_file_types(files)
    local selection = {}

    if string.match(vim.fn.expand("%:e"), "cpp") then
      selection = {header, inline}
    elseif string.match(vim.fn.expand("%:e"), "hpp") then
      selection = {source, inline}
    elseif string.match(vim.fn.expand("%:e"), "inl") then
      selection = {source, header}
    else
      vim.notify("Unexpected file extension!", "error")
      return
    end
    vim.ui.select(selection, {prompt = "Choose a file:"}, function(choice) if choice then vim.cmd("edit " .. choice) end end)

  else
    vim.notify("Unexpectedly high amount of corresponding files found!", "error")
  end
end
vim.keymap.set("n", "<LEADER>pu", function() switch_file_in_cxx_unit(vim.fn.getcwd() .. "/program") end)
                       -- Folder to recursively search for files in the compilation unit ^^^
-- C/C++
