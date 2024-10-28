map = vim.keymap.set
opt = vim.opt
api = vim.api
g = vim.g

-- REMAP
g.mapleader = " "
map("n", "<C-f>", "<nop>")
map("i", "<C-c>", "<Esc>")

map("n", "<LEADER>w", "<CMD>w<CR>")
map("n", "<LEADER><LEADER>", "<CMD>so<CR>")
map("n", "<LEADER>pv", "<CMD>Ex<CR>")
map("n", "<LEADER>tw", "<CMD>set wrap!<CR>")

map("n", "J", "mzJ`z")
map("n", "gJ", "mzgJ`z")
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
map({"n", "v"}, "j", "gj")
map({"n", "v"}, "k", "gk")

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "*", "*zzzv")
map("n", "#", "#zzzv")

map("n", "<A-h>", "<C-w>h")
map("n", "<A-j>", "<C-w>j")
map("n", "<A-k>", "<C-w>k")
map("n", "<A-l>", "<C-w>l")

map({"n", "v"}, "<LEADER>y", [["+y]])
map("n", "<LEADER>Y", [["+Y]])
map("x", "<LEADER>p", [["_dP]])
map({"n", "v"}, "<LEADER>d", [["_d]])
map({"n", "v"}, "<LEADER>c", [["_c]])
map({"n", "v"}, "<LEADER>x", [["_x]])

map("n", "<LEADER>s", ":%s/<C-r><C-w>/<C-r><C-w>/g<Left><Left>")
map("n", "<C-s>", ":%s//g<Left><Left>")
map("v", "<LEADER>s", "\"hy:%s/<C-r>h/<C-r>h/g<Left><Left>")
map("v", "<C-s>", ":s//g<Left><Left>")
map("v", "<C-n>", ":normal ")

-- Will specifically search in files in the program directory
map("n", "<LEADER>qg", ":silent grep  program/*/*<C-Left><Left>")
map("n", "<LEADER>qo", "<CMD>copen<CR>")
map("n", "<LEADER>qr", ":cdo s//g<Left><Left>")
map("n", "<LEADER>qw", "\"+yiw:silent grep <C-r><C-w> program/*/*<CR><CMD>copen<CR>")
map("n", "<LEADER>qW", "\"+yiw:silent grep <C-r><C-a> program/*/*<CR><CMD>copen<CR>")
map("v", "<LEADER>q", "\"+ygv\"hy:silent grep <C-r>h program/*/*<CR><CMD>copen<CR>")

map("n", "<LEADER>v", "<CMD>!./script/clean.sh<CR>")
map("n", "<LEADER>b", "<CMD>!./script/build.sh<CR>")
map("n", "<LEADER>n", "<CMD>!./script/run.sh<CR>")
map("n", "<LEADER>m", "<CMD>!./script/debug.sh<CR>")
-- REMAP

-- SET
g.netrw_banner = 0

opt.nu = true
opt.relativenumber = true
opt.signcolumn = "no"
opt.colorcolumn = "100"

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

opt.wrap = false
opt.linebreak = true
opt.scrolloff = 1000
opt.textwidth = 100
opt.formatoptions:remove("t")
opt.formatoptions:remove("c")

opt.autoread = true
opt.swapfile = false
opt.undofile = true
opt.backup = false
opt.writebackup = false

opt.ignorecase = false
opt.hlsearch = false
opt.incsearch = true

opt.termguicolors = true

opt.isfname:append("@-@")
opt.updatetime = 300

api.nvim_create_autocmd("VimResized", { command = "wincmd =" })
-- SET

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
    vim.notify("Not a C source or header file!", "error")
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
    local source, header = assign_cc_file_types(files)
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
map("n", "<LEADER>pU", function() switch_file_in_cc_unit(vim.fn.getcwd() .. "/program") end)
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
    vim.notify("Not a C++ source, header or inline file!", "error")
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
map("n", "<LEADER>pu", function() switch_file_in_cxx_unit(vim.fn.getcwd() .. "/program") end)
                       -- Folder to recursively search for files in the compilation unit ^^^
-- C/C++
