-- ============================================================================
-- Prompt Templates - Centralized prompt management
-- ============================================================================

local M = {}

-- Get current git branch name
local function get_git_branch()
  local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null")
  if branch and branch ~= "" then
    return vim.trim(branch)
  end
  return nil
end

-- Parse branch name and extract commit message format
-- If branch is A/B or A/B/C format (one or two slashes), return A[B] format
-- Otherwise return nil
local function get_commit_message_format()
  local branch = get_git_branch()
  if not branch then
    return nil
  end

  -- Check if branch has format A/B or A/B/C
  local parts = {}
  for part in branch:gmatch("[^/]+") do
    table.insert(parts, part)
  end

  if #parts >= 2 then
    -- Format: A[B] message (use first two parts)
    return parts[1] .. "[" .. parts[2] .. "]"
  end

  return nil
end

-- Code review prompt templates
local function get_code_review_prompt_template(lang, commit_format)
  local commit_message_section_en = [[
4. **Recommended Commit Message**
   - Generate a concise, accurate, and conventional commit message for this change.
   - IMPORTANT: The commit message MUST be written in English.]]

  local commit_message_section_zh = [[
4. **推荐提交信息**
   - 为此变更生成简洁、准确且符合规范的提交信息。
   - 重要：提交信息必须使用英文（The commit message MUST be written in English）。]]

  -- Add format requirement if branch format is detected
  if commit_format then
    commit_message_section_en = commit_message_section_en .. "\n   - IMPORTANT: The commit message MUST follow this format: " .. commit_format .. " <message> (message must be in English)"
    commit_message_section_zh = commit_message_section_zh .. "\n   - 重要：提交信息必须遵循以下格式：" .. commit_format .. " <message>（message 必须使用英文）"
  end

  local prompts = {
    ['en'] = [[
As a professional code reviewer, please analyze the above git diff and output your review in clear, structured English Markdown. Note that this diff may only show partial changes, so consider the broader codebase context when necessary. Strictly follow this format:

1. **Context Analysis & Dependencies**
   - Identify what files, modules, or components might be affected by these changes
   - Point out if additional context from related files would be helpful for a complete review
   - Highlight any potential integration points or cross-module dependencies that should be considered

2. **Problematic Code & Explanation**
   - List all code snippets with potential issues (bugs, design flaws, maintainability, performance, security, etc.)
   - Clearly explain the reason and impact for each issue, considering both local and system-wide effects

3. **Improvement Suggestions**
   - For each issue, provide concrete suggestions for improvement or fixes
   - Include recommendations for additional testing or validation if needed
   - Suggest related files that should be reviewed or updated alongside these changes

4. **Overall Assessment**
   - Summarize the strengths and risks of this change within the broader system context
   - Highlight anything that needs special attention or follow-up reviews
   - Recommend any additional files or areas that should be examined to ensure system integrity

]] .. commit_message_section_en .. [[

Format your output in clean Markdown for easy copy-paste into review tools or commit descriptions.
]],

    ['zh-cn'] = [[
作为一名专业的代码审查员，请分析上述 git diff 并以清晰、结构化的中文 Markdown 格式输出您的审查意见。请注意此 diff 可能只显示部分变更，必要时请考虑更广泛的代码库上下文。请严格遵循以下格式：

1. **上下文分析与依赖关系**
   - 识别这些变更可能影响的文件、模块或组件
   - 指出是否需要相关文件的额外上下文来进行完整审查
   - 突出显示应该考虑的任何潜在集成点或跨模块依赖关系

2. **问题代码及说明**
   - 列出所有存在潜在问题的代码片段（bug、设计缺陷、可维护性、性能、安全性等）
   - 清楚说明每个问题的原因和影响，同时考虑局部和系统级的影响

3. **改进建议**
   - 针对每个问题，提供具体的改进或修复建议
   - 如需要，包括额外测试或验证的建议
   - 建议应与这些变更一起审查或更新的相关文件

4. **整体评估**
   - 在更广泛的系统上下文中总结此次变更的优势和风险
   - 突出需要特别关注或后续审查的地方
   - 推荐应该检查的其他文件或区域，以确保系统完整性

]] .. commit_message_section_zh .. [[

请以清晰的 Markdown 格式输出，便于复制粘贴到审查工具或提交描述中。
]]
  }

  return prompts[lang] or prompts['en']
end

-- Get code review prompt by language
function M.get_code_review_prompt(lang)
  lang = lang or 'en'
  local commit_format = get_commit_message_format()
  return get_code_review_prompt_template(lang, commit_format)
end

-- Get code review prompt with git diff wrapper
function M.get_code_review_prompt_with_diff(diff, lang)
  local prompt_template = M.get_code_review_prompt(lang)
  return "```diff\n" .. diff .. "\n```\n\n" .. prompt_template
end

return M
