-- Pandoc Lua filter: 以 {align=left|center|right} 指定圖片對齊方式（預設置中）
local cmds = { left = '\\raggedright', center = '\\centering', right = '\\raggedleft' }

function Figure(fig)
  local align = fig.attributes['align']
  if not align then
    local img
    pandoc.walk_block(fig, { Image = function(i) img = img or i end })
    align = img and img.attributes['align']
  end
  local cmd = align and cmds[align]
  if not cmd then
    return nil
  end
  -- figure 環境內的 \centering 會被局部取代為指定的對齊指令
  return {
    pandoc.RawBlock('latex', '\\begingroup\\let\\centering' .. cmd .. '\\relax'),
    fig,
    pandoc.RawBlock('latex', '\\endgroup'),
  }
end
