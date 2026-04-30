-- ============================================================================
-- Markdown image helpers (Typora-style)
--
-- Two operations are exposed:
--   * paste_image()  - read the current line, extract a path that points to
--                      an image (already-dropped path, file:// URL, or
--                      existing ![alt](path) link), then copy that file into
--                      <md-basename>.assets/ and replace the line/segment
--                      with the proper Markdown image link.
--   * resize_image() - find the image reference on the current line
--                      (either ![](path) or <img src=...>), prompt for a
--                      zoom percentage (default 50) and rewrite it as the
--                      Typora <img src=... alt="..." style="zoom:NN%;" />
--                      form.
--
-- The on-disk layout matches Typora exactly so the same files render
-- cleanly in both Typora and :MarkdownPreviewToggle.
-- ============================================================================

local M = {}

-- Extension whitelist (lowercase). Lookup is always done after :lower(),
-- so PNG / Png / png all match.
local IMAGE_EXTS = {
  png = true, jpg = true, jpeg = true, gif = true, webp = true,
  bmp = true, svg = true, tiff = true, tif = true, ico = true,
  avif = true, heic = true, heif = true,
}

-- Magic-number sniff for cases where the extension is missing or wrong.
-- We only need to read the first ~16 bytes.
local function sniff_image(path)
  local f = io.open(path, "rb")
  if not f then return false end
  local head = f:read(16) or ""
  f:close()
  if #head < 4 then return false end

  -- PNG: 89 50 4E 47 0D 0A 1A 0A
  if head:sub(1, 8) == "\137PNG\r\n\26\n" then return true end
  -- JPEG: FF D8 FF
  if head:sub(1, 3) == "\255\216\255" then return true end
  -- GIF87a / GIF89a
  if head:sub(1, 6) == "GIF87a" or head:sub(1, 6) == "GIF89a" then return true end
  -- BMP
  if head:sub(1, 2) == "BM" then return true end
  -- WebP / AVIF / HEIC: RIFF....WEBP  or  ....ftyp{avif|heic|heif|mif1}
  if head:sub(1, 4) == "RIFF" and head:sub(9, 12) == "WEBP" then return true end
  if #head >= 12 and head:sub(5, 8) == "ftyp" then
    local brand = head:sub(9, 12):lower()
    if brand == "avif" or brand == "heic" or brand == "heix"
       or brand == "heif" or brand == "mif1" or brand == "msf1" then
      return true
    end
  end
  -- TIFF: II*\0 (little-endian) or MM\0* (big-endian)
  if head:sub(1, 4) == "II*\0" or head:sub(1, 4) == "MM\0*" then return true end
  -- SVG: text starts with "<?xml" or "<svg"
  local low = head:lower()
  if low:find("^<%?xml") or low:find("^<svg") then return true end

  return false
end

local function is_markdown_buffer()
  if vim.bo.filetype ~= "markdown" then
    vim.notify("Not a markdown buffer", vim.log.levels.WARN)
    return false
  end
  return true
end

local function current_md_path()
  local path = vim.api.nvim_buf_get_name(0)
  if path == nil or path == "" then
    vim.notify("Save the markdown file first so the image can live next to it", vim.log.levels.ERROR)
    return nil
  end
  return path
end

local function expand_path(path)
  path = vim.fn.expand(path)
  if path:sub(1, 1) ~= "/" then
    path = vim.fn.fnamemodify(path, ":p")
  end
  return path
end

local function assets_dir_for(md_path)
  local dir = vim.fn.fnamemodify(md_path, ":h")
  local stem = vim.fn.fnamemodify(md_path, ":t:r")
  return dir .. "/" .. stem .. ".assets"
end

local function ensure_dir(dir)
  if vim.fn.isdirectory(dir) == 1 then return true end
  local ok = vim.fn.mkdir(dir, "p") == 1
  if not ok then
    vim.notify("Failed to create directory: " .. dir, vim.log.levels.ERROR)
  end
  return ok
end

local function read_bytes(p)
  local f = io.open(p, "rb")
  if not f then return nil end
  local data = f:read("*a")
  f:close()
  return data
end

-- Copy src into dst_dir keeping its basename. If something with that name
-- already exists and is byte-identical, reuse it. Otherwise add -1/-2/...
-- to avoid clobbering.
local function copy_into(src, dst_dir)
  local base = vim.fn.fnamemodify(src, ":t")
  local stem = vim.fn.fnamemodify(base, ":r")
  local ext = vim.fn.fnamemodify(base, ":e")
  local dst = dst_dir .. "/" .. base

  if vim.fn.filereadable(dst) == 1 then
    local a = read_bytes(src)
    local b = read_bytes(dst)
    if a and b and a == b then
      return dst, base
    end
    local i = 1
    while true do
      local candidate_name = stem .. "-" .. i .. (ext ~= "" and ("." .. ext) or "")
      local candidate = dst_dir .. "/" .. candidate_name
      if vim.fn.filereadable(candidate) == 0 then
        dst = candidate
        base = candidate_name
        break
      end
      i = i + 1
    end
  end

  local src_data = read_bytes(src)
  if not src_data then
    vim.notify("Failed to read source image: " .. src, vim.log.levels.ERROR)
    return nil
  end
  local out = io.open(dst, "wb")
  if not out then
    vim.notify("Failed to write: " .. dst, vim.log.levels.ERROR)
    return nil
  end
  out:write(src_data)
  out:close()

  return dst, base
end

-- Decide whether `path` points to an image.
--   * extension check is case-insensitive (PNG = png).
--   * content sniff confirms the extension (so a text file named foo.png
--     is rejected) and also catches no-extension or wrong-extension files.
local function is_image_file(path)
  if vim.fn.filereadable(path) == 0 then return false, "file not readable" end
  local ext = vim.fn.fnamemodify(path, ":e"):lower()
  local ext_ok = ext ~= "" and IMAGE_EXTS[ext]
  local sniff_ok = sniff_image(path)
  if ext_ok and sniff_ok then return true end
  if ext_ok and not sniff_ok then
    return false, "extension '." .. ext .. "' but file content is not an image"
  end
  if not ext_ok and sniff_ok then return true end
  if ext == "" then
    return false, "no extension and content does not look like an image"
  end
  return false, "extension '." .. ext .. "' is not an image and content does not look like an image"
end

-- Strip surrounding decoration (quotes, brackets, parens) from the candidate.
local function strip_decor(s)
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  -- Repeatedly peel matched outer wrappers.
  while #s >= 2 do
    local first, last = s:sub(1, 1), s:sub(-1, -1)
    if (first == '"' and last == '"')
       or (first == "'" and last == "'")
       or (first == "<" and last == ">")
       or (first == "(" and last == ")")
       or (first == "[" and last == "]") then
      s = s:sub(2, -2):gsub("^%s+", ""):gsub("%s+$", "")
    else
      break
    end
  end
  return s
end

-- Normalize what the user dropped/typed:
--   * file:// URL prefix
--   * percent-encoded characters (file:// only)
--   * backslash-escaped spaces (Finder drag on macOS sometimes does this)
--   * surrounding quotes/brackets
local function normalize_path(raw)
  if not raw then return nil end
  local s = strip_decor(raw)
  if s == "" then return nil end

  if s:lower():sub(1, 7) == "file://" then
    s = s:sub(8)
    -- A file:// URL is percent-encoded. Decode %HH.
    s = s:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
    -- file://localhost/...  ->  /...
    if s:lower():sub(1, 10) == "localhost/" then
      s = s:sub(10)
    end
  end

  -- Unescape "\ " -> " " (Finder drag style).
  s = s:gsub("\\ ", " ")

  -- Expand ~, env vars; force absolute.
  s = expand_path(s)
  return s
end

-- Try to extract a path from the current line. Returns:
--   path, replace_start, replace_end
-- where replace_start/end are 1-based byte offsets covering the original
-- segment we should swap out (so we can replace just the link, not the whole
-- line). If no good candidate, returns nil.
local function extract_path_from_line(line)
  if not line or line == "" then return nil end

  -- 1) Existing markdown image link: ![alt](path)
  local s, e, _alt, link_path = line:find("!%[([^%]]*)%]%(([^%)]+)%)")
  if s and link_path then
    local p = normalize_path(link_path)
    if p then return p, s, e end
  end

  -- 2) Existing <img src="..."> tag — also useful (e.g. user dragged then
  --    Typora-style HTML was already inserted manually).
  local hs, he = line:find("<img[^>]->")
  if hs then
    local tag = line:sub(hs, he)
    local src = tag:match('src%s*=%s*"([^"]+)"')
      or tag:match("src%s*=%s*'([^']+)'")
      or tag:match("src%s*=%s*([^%s/>]+)")
    if src then
      local p = normalize_path(src)
      if p then return p, hs, he end
    end
  end

  -- 3) Bare path on the line. Look for a token containing '/' or starting
  --    with '~'. Be permissive about spaces inside the path: if the entire
  --    trimmed line resolves to a real file, prefer that (handles "My
  --    Folder/foo.png" with literal spaces).
  local trimmed_line = line:gsub("^%s+", ""):gsub("%s+$", "")
  if trimmed_line ~= "" then
    local p = normalize_path(trimmed_line)
    if p and vim.fn.filereadable(p) == 1 then
      local rs = line:find(vim.pesc(trimmed_line), 1, true)
      local re = rs and (rs + #trimmed_line - 1) or nil
      return p, rs, re
    end
  end

  -- 4) Fall back to scanning the line for path-like tokens. We split on
  --    whitespace but keep "\ " (backslash-escaped space, Finder-style)
  --    glued to its surrounding token, since real macOS drag paths look
  --    like /Users/x/My\ Folder/foo.png .
  do
    local i = 1
    local n = #line
    while i <= n do
      -- Skip leading whitespace.
      while i <= n and line:sub(i, i):match("%s") do i = i + 1 end
      if i > n then break end

      local start = i
      while i <= n do
        local ch = line:sub(i, i)
        if ch == "\\" and i < n and line:sub(i + 1, i + 1) == " " then
          i = i + 2  -- consume "\ " as part of the token
        elseif ch:match("%s") then
          break
        else
          i = i + 1
        end
      end
      local stop = i - 1
      local tok = line:sub(start, stop)
      local candidate = strip_decor(tok)

      if candidate:find("/", 1, true) or candidate:sub(1, 1) == "~"
         or candidate:lower():sub(1, 7) == "file://" then
        local p = normalize_path(candidate)
        if p and vim.fn.filereadable(p) == 1 then
          return p, start, stop
        end
      end
    end
  end

  return nil
end

local function replace_segment(line, s, e, replacement)
  return line:sub(1, s - 1) .. replacement .. line:sub(e + 1), s + #replacement - 1
end

function M.paste_image()
  if not is_markdown_buffer() then return end
  local md_path = current_md_path()
  if not md_path then return end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()

  local src_path, seg_s, seg_e = extract_path_from_line(line)
  if not src_path then
    vim.notify("No path found on this line. Drop a file onto the line first.", vim.log.levels.WARN)
    return
  end

  local ok, why = is_image_file(src_path)
  if not ok then
    vim.notify("Not an image: " .. src_path .. " (" .. (why or "unknown") .. ")", vim.log.levels.ERROR)
    return
  end

  local assets = assets_dir_for(md_path)
  if not ensure_dir(assets) then return end

  local dst, base = copy_into(src_path, assets)
  if not dst then return end

  local rel = vim.fn.fnamemodify(md_path, ":t:r") .. ".assets/" .. base
  local alt = vim.fn.fnamemodify(base, ":r")
  local link = string.format("![%s](%s)", alt, rel)

  if seg_s and seg_e then
    local new_line, end_col = replace_segment(line, seg_s, seg_e, link)
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
    vim.api.nvim_win_set_cursor(0, { row, end_col })
  else
    vim.api.nvim_set_current_line(link)
    vim.api.nvim_win_set_cursor(0, { row, #link })
  end

  vim.notify("Pasted image: " .. rel, vim.log.levels.INFO)
end

-- Resize the image reference on the current line. Supports both
--   ![alt](path)
-- and
--   <img src="path" .../> | <img src=path .../>
-- Rewrites it to the Typora zoom form:
--   <img src="path" alt="alt" style="zoom:NN%;" />
function M.resize_image()
  if not is_markdown_buffer() then return end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()

  local s, e, alt, src
  s, e, alt, src = line:find("!%[([^%]]*)%]%(([^%)]+)%)")
  if not s then
    s, e = line:find("<img[^>]->")
    if not s then
      vim.notify("No image link on this line", vim.log.levels.WARN)
      return
    end
    local tag = line:sub(s, e)
    src = tag:match('src%s*=%s*"([^"]+)"')
      or tag:match("src%s*=%s*'([^']+)'")
      or tag:match("src%s*=%s*([^%s/>]+)")
    alt = tag:match('alt%s*=%s*"([^"]*)"')
      or tag:match("alt%s*=%s*'([^']*)'")
      or ""
    if not src then
      vim.notify("Could not parse <img> src", vim.log.levels.WARN)
      return
    end
  end

  vim.ui.input({
    prompt = "Zoom % (default 50): ",
    default = "",
  }, function(input)
    local pct = 50
    if input and input ~= "" then
      local n = tonumber(input)
      if not n then
        vim.notify("Not a number: " .. input, vim.log.levels.WARN)
        return
      end
      pct = math.floor(n + 0.5)
    end

    if alt == nil or alt == "" then
      alt = vim.fn.fnamemodify(src, ":t:r")
    end

    local replacement = string.format(
      '<img src="%s" alt="%s" style="zoom:%d%%;" />',
      src, alt, pct
    )

    local new_line = line:sub(1, s - 1) .. replacement .. line:sub(e + 1)
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
  end)
end

return M
