-- Pandoc Lua filter to format tables with full grid borders (vertical and horizontal lines)
local function add_vlines(cols_str)
  -- Remove outer @{} and whitespace
  local s = cols_str:gsub('^%s*@{}%s*', ''):gsub('%s*@{}%s*$', '')
  
  -- Match column tokens: either >{...}p{...} or p{...} or single l/c/r
  local cols = {}
  local pos = 1
  while pos <= #s do
    local sub = s:sub(pos)
    local col = sub:match('^(%s*>%b{}p%b{})') or sub:match('^(%s*p%b{})') or sub:match('^(%s*[lcr])')
    if col then
      table.insert(cols, col:match("^%s*(.-)%s*$"))
      pos = pos + #col
    else
      pos = pos + 1
    end
  end
  if #cols == 0 then
    return cols_str
  end
  return "|" .. table.concat(cols, "|") .. "|"
end

function Table(tbl)
  local doc = pandoc.Pandoc({tbl})
  local latex = pandoc.write(doc, 'latex')

  -- 1. Replace column specifier safely without corrupting internal LaTeX macros
  latex = latex:gsub('(\\begin{longtable}%b[]%s*){(@{}?.-@{}?)}', function(prefix, cols)
    return prefix .. '{' .. add_vlines(cols) .. '}'
  end)

  -- 2. Replace booktabs rules
  latex = latex:gsub('\\toprule%s*\\noalign{}', '\\hline')
  latex = latex:gsub('\\midrule%s*\\noalign{}', '\\hline')
  latex = latex:gsub('\\bottomrule%s*\\noalign{}', '')

  -- 3. Add \hline after each data row in the body
  local lines = {}
  local in_body = false
  for line in latex:gmatch("([^\r\n]+)") do
    local trimmed = line:match("^%s*(.-)%s*$")
    if trimmed:find("\\endhead", 1, true) or trimmed:find("\\endlastfoot", 1, true) then
      in_body = true
      table.insert(lines, line)
    elseif in_body and trimmed:sub(-2) == "\\\\" and not trimmed:find("\\hline", 1, true) then
      table.insert(lines, line .. " \\hline")
    else
      table.insert(lines, line)
    end
  end

  local result = table.concat(lines, "\n")
  return pandoc.RawBlock('latex', result)
end

-- Ensure code blocks without a specified language are also wrapped in shaded boxes
function CodeBlock(cb)
  if #cb.classes == 0 then
    cb.classes = {'text'}
    return cb
  end
end

