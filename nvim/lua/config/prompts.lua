-- ============================================================================
-- Prompt Templates - Centralized prompt management
-- ============================================================================

local M = {}

-- Code review prompt templates
local code_review_prompts = {
  ['en'] = [[
As a professional code reviewer, please analyze the above git diff and output your review in clear, structured English Markdown. Strictly follow this format:

1. **Problematic Code & Explanation**
   - List all code snippets with potential issues (bugs, design flaws, maintainability, performance, etc.), and clearly explain the reason and impact for each.

2. **Improvement Suggestions**
   - For each issue, provide concrete suggestions for improvement or fixes.

3. **Overall Assessment**
   - Summarize the strengths and risks of this change, and highlight anything that needs special attention.

4. **Recommended Commit Message**
   - Generate a concise, accurate, and conventional commit message for this change.

Format your output in clean Markdown for easy copy-paste into review tools or commit descriptions.
]],

  ['zh-cn'] = [[
作为一名专业的代码审查员，请分析上述 git diff 并以清晰、结构化的中文 Markdown 格式输出您的审查意见。请严格遵循以下格式：

1. **问题代码及说明**
   - 列出所有存在潜在问题的代码片段（bug、设计缺陷、可维护性、性能等），并清楚说明每个问题的原因和影响。

2. **改进建议**
   - 针对每个问题，提供具体的改进或修复建议。

3. **整体评估**
   - 总结此次变更的优势和风险，并突出需要特别关注的地方。

4. **推荐提交信息**
   - 为此变更生成简洁、准确且符合规范的提交信息，提交信息使用英文。

请以清晰的 Markdown 格式输出，便于复制粘贴到审查工具或提交描述中。
]]
}

-- Get code review prompt by language
function M.get_code_review_prompt(lang)
  lang = lang or 'en'
  return code_review_prompts[lang] or code_review_prompts['en']
end

-- Get code review prompt with git diff wrapper
function M.get_code_review_prompt_with_diff(diff, lang)
  local prompt_template = M.get_code_review_prompt(lang)
  return "```diff\n" .. diff .. "\n```\n\n" .. prompt_template
end

return M
