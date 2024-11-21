map = vim.keymap.set
opt = vim.opt
api = vim.api
g = vim.g

----------------------------------------------------------------------------------------------------

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

----------------------------------------------------------------------------------------------------

g.mapleader = " "
g.netrw_banner = 0
opt.nu = true
opt.relativenumber = true
opt.signcolumn = "no"
opt.colorcolumn = "120"
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.linebreak = true
opt.scrolloff = 1000
opt.textwidth = 120
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
api.nvim_create_autocmd("VimResized", {command = "wincmd ="})

----------------------------------------------------------------------------------------------------

general_util = {}
general_util.make_relative_files = function(long_files, cwd)
  local files = {}
  for _, file in ipairs(long_files) do
    local new_file = string.gsub(file, cwd .. "\\", "")
    new_file = string.gsub(new_file, "\\", "/")
    table.insert(files, new_file)
  end
  return files
end
general_util.get_files_in_compilation_unit = function(directory)
  local cwd = vim.fn.getcwd()
  local name = vim.fn.expand("%:t:r")
  local long_files = vim.fn.globpath(directory, "**/" .. name .. ".*", 0, 1)
  local files = general_util.make_relative_files(long_files, cwd)
  return files
end

----------------------------------------------------------------------------------------------------
cc_util = {}
cc_util.assign_file_types = function(files)
  local source = ""
  local header = ""
  for _, file in ipairs(files) do
    if string.match(file, "%.c$") then source = file
    elseif string.match(file, "%.h$") then header = file end
  end
  return source, header
end
cc_util.switch_file_in_compilation_unit = function(directory, target_extension)
  local directory = vim.fn.getcwd() .. directory
  local current_extension = vim.fn.expand("%:e")
  if not string.match(current_extension, "c") and not string.match(current_extension, "h") then
    vim.notify("Not a c or h file!", "error")
    return
  end
  local files = general_util.get_files_in_compilation_unit(directory)
  if string.match(current_extension, target_extension) then
    vim.notify("Already in " .. target_extension .. " file!", "error")
    return
  end
  if #files == 0 then vim.notify("Problem reading filename!", "error")
  elseif #files == 1 then vim.notify("There is only one file in this compilation unit!", "error")
  elseif #files == 2 then
    local source, header, inline = cc_util.assign_file_types(files)
    if target_extension == "c" then
      if source ~= "" then vim.cmd("edit " .. source)
      else vim.notify("No c file found!", "error") end
    elseif target_extension == "h" then
      if header ~= "" then vim.cmd("edit " .. header)
      else vim.notify("No h file found!", "error") end
    else vim.notify("Unexpected target file extension!", "error") end
  else vim.notify("Unexpectedly high amount of corresponding files found!", "error") end
end
map("n", "<LEADER>Uc", function() cc_util.switch_file_in_compilation_unit("/program", "c") end)
map("n", "<LEADER>Uh", function() cc_util.switch_file_in_compilation_unit("/program", "h") end)

----------------------------------------------------------------------------------------------------

cxx_util = {}
cxx_util.assign_file_types = function(files)
  local source = ""
  local header = ""
  local inline = ""
  for _, file in ipairs(files) do
    if string.match(file, "%.cpp$") then source = file
    elseif string.match(file, "%.hpp$") then header = file
    elseif string.match(file, "%.inl$") then inline = file end
  end
  return source, header, inline
end
cxx_util.switch_file_in_compilation_unit = function(directory, target_extension)
  local directory = vim.fn.getcwd() .. directory
  local current_extension = vim.fn.expand("%:e")
  if not string.match(current_extension, "cpp") and not string.match(current_extension, "hpp") and not string.match(current_extension, "inl") then
    vim.notify("Not a cpp, hpp or inl file!", "error")
    return
  end
  local files = general_util.get_files_in_compilation_unit(directory)
  if string.match(current_extension, target_extension) then
    vim.notify("Already in " .. target_extension .. " file!", "error")
    return
  end
  if #files == 0 then vim.notify("Problem reading filename!", "error")
  elseif #files == 1 then vim.notify("There is only one file in this compilation unit!", "error")
  elseif #files == 2 or #files == 3 then
    local source, header, inline = cxx_util.assign_file_types(files)
    if target_extension == "cpp" then
      if source ~= "" then vim.cmd("edit " .. source)
      else vim.notify("No cpp file found!", "error") end
    elseif target_extension == "hpp" then
      if header ~= "" then vim.cmd("edit " .. header)
      else vim.notify("No hpp file found!", "error") end
    elseif target_extension == "inl" then
      if inline ~= "" then vim.cmd("edit " .. inline)
      else vim.notify("No inl file found!", "error") end
    else
      vim.notify("Unexpected target file extension!", "error")
      return
    end
  else vim.notify("Unexpectedly high amount of corresponding files found!", "error") end
end
map("n", "<LEADER>uc", function() cxx_util.switch_file_in_compilation_unit("/program", "cpp") end)
map("n", "<LEADER>uh", function() cxx_util.switch_file_in_compilation_unit("/program", "hpp") end)
map("n", "<LEADER>ui", function() cxx_util.switch_file_in_compilation_unit("/program", "inl") end)
