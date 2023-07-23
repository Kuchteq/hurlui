-- Have the window be transparent/the same as the terminal
local background = "NONE"


local palette_light = {
    color0 = '#525E5E',
    color1 = '#e57474',
    color2 = '#8ccf7e',
    color3 = '#e5c76b',
    color4 = '#67b0e8', -- sort of Secondary Color
    color5 = '#c47fd5', -- sort of a Primary Color
    color6 = '#6cbfbf',
    color7 = '#b3b9b8',
    color8 = '#2d3437',
    color9 = '#ef7e7e',
    color10 = '#96d988',
    color11 = '#f4d67a',
    color12 = '#71baf2',
    color13 = '#ce89df',
    color14 = '#67cbe7',
    color15 = '#bdc3c2',
    comment = '#4A4F53',
    contrast = '#161d1f',
    background = '#141b1e',
    foreground = '#dadada',
    cursorline = '#242A2A',
    ogpurple = "#ff00d7",
    baraccent = "#8C1F8C",
    barinactive = "#0F5C7A",
    none = 'NONE',
    bar = 'NONE',
}
local p = palette_light

local theme = {
    -- base highlights
    Boolean = { fg = p.color5 },
    Character = { fg = p.color12 },
    ColorColumn = { bg = background },
    Comment = { fg = p.comment, italic = true },
    Conceal = { fg = p.color4, bg = background },
    Conditional = { fg = p.color6 },
    Constant = { fg = p.color5 },
    Cursor = { fg = p.foreground, bg = p.foreground },
    CursorColumn = { bg = background },
    CursorIM = { fg = p.foreground, bg = p.foreground },
    CursorLine = { bg = p.cursorline },
    CursorLineNr = { fg = p.ogpurple },
    Debug = { fg = p.color1 },
    Define = { fg = p.color6 },
    Delimiter = { fg = p.foreground },
    DiffAdd = { fg = p.color4, bg = background },
    DiffChange = { fg = p.color5, bg = background },
    DiffDelete = { fg = p.color1, bg = background },
    DiffText = { fg = p.color1, bg = background },
    Directory = { fg = p.color4 },
    EndOfBuffer = { fg = p.background },
    Error = { fg = p.color1, bg = background },
    ErrorMsg = { fg = p.color1, bg = background },
    Exception = { fg = p.color6 },
    Float = { fg = p.color5 },
    FloatBorder = { fg = p.color2 },
    FoldColumn = { fg = p.color4, bg = background },
    Folded = { fg = p.color4, bg = background },
    Function = { fg = p.color6 },
    Identifier = { fg = p.color5 },
    Ignore = { fg = p.color7, bg = background },
    IncSearch = { fg = p.background, bg = p.color10 },
    Include = { fg = p.color6 },
    Keyword = { fg = p.color6 },
    Label = { fg = p.color4 },
    LineNr = { fg = p.color0, bg = background },
    Macro = { fg = p.color6 },
    MatchParen = { fg = p.color4, bg = background },
    ModeMsg = { fg = p.foreground, bg = background },
    MoreMsg = { fg = p.color5 },
    MsgArea = { fg = p.foreground, bg = background },
    MsgSeparator = { fg = p.foreground, bg = background },
    NonText = { fg = p.color1 },
    Normal = { fg = p.foreground, bg = background },
    NormalFloat = { bg = background },
    NormalNC = { fg = p.foreground, bg = background },
    Number = { fg = p.color3 },
    Operator = { fg = p.color6 },
    Pmenu = { fg = p.foreground, bg = background },
    PmenuSbar = { bg = background },
    PmenuSel = { fg = p.background, bg = p.color4 },
    PmenuThumb = { bg = p.color2 },
    PreCondit = { fg = p.color6 },
    PreProc = { fg = p.color6 },
    Question = { fg = p.color5 },
    QuickFixLine = { bg = p.color2 },
    Repeat = { fg = p.color6 },
    Search = { fg = p.background, bg = p.color10 },
    SignColumn = { fg = p.background, bg = background },
    Special = { fg = p.color6 },
    SpecialChar = { fg = p.foreground },
    SpecialComment = { fg = p.color2 },
    SpecialKey = { fg = p.color4 },
    SpellBad = { fg = p.color2 },
    SpellCap = { fg = p.color6 },
    SpellLocal = { fg = p.color4 },
    SpellRare = { fg = p.color6 },
    Statement = { fg = p.color6 },
    StatusLine = { fg = p.foreground, bg = p.baraccent },
    StatusLineNC = { bg = p.barinactive, fg = p.foreground },
    Storage = { fg = p.color9 },
    StorageClass = { fg = p.color7 },
    String = { fg = p.color2 },
    Structure = { fg = p.color6 },
    Substitute = { fg = p.color3, bg = p.color6 },
    TabLine = { fg = p.foreground, bg = p.barinactive },
    TabLineFill = { fg = p.foreground, bg = p.background },
    TabLineSel = { fg = p.foreground, bg = p.baraccent },
    Tag = { fg = p.color4 },
    TermCursor = { fg = p.foreground, bg = p.foreground },
    TermCursorNC = { fg = p.foreground, bg = p.foreground },
    Title = { fg = p.color4, bold = true },
    Todo = { fg = p.color1, bg = background },
    Type = { fg = p.color5 },
    Typedef = { fg = p.color6 },
    Underlined = { fg = p.color3 },
    Variable = { fg = p.color5 },
    VertSplit = { fg = p.background, bg = p.color0 },
    Visual = { fg = p.foreground, bg = p.color0 },
    VisualNOS = { bg = background },
    WarningMsg = { fg = p.color3, bg = background },
    Whitespace = { fg = p.color1 },
    WildMenu = { fg = p.color7, bg = p.color4 },
    lCursor = { fg = p.foreground, bg = p.foreground },
    WinSeparator = { fg = p.barinactive, bg = background },

    -- hurly
    HttpSuccessFill = { fg = p.background, bg = p.color2 },
    HttpErrorFill = { fg = p.background, bg = p.color1 },
    EnvBarFill = { fg = p.background, bg = p.color3 },
    Boldy = { bold = true, bg = nil, fg = p.background },


    -- diff
    diffAdded = { fg = p.color4 },
    diffChanged = { fg = p.color5 },
    diffFile = { fg = p.color7 },
    diffIndexLine = { fg = p.color6 },
    diffLine = { fg = p.color1 },
    diffNewFile = { fg = p.color5 },
    diffOldFile = { fg = p.color5 },
    diffRemoved = { fg = p.color1 },


    -- Neogit: https://github.com/TimUntersberger/neogit
    NeogitBranch = { fg = p.color6 },
    NeogitDiffAddHighlight = { fg = p.color4, bg = background },
    NeogitDiffContextHighlight = { bg = background, fg = p.foreground },
    NeogitDiffDeleteHighlight = { fg = p.color1, bg = background },
    NeogitHunkHeader = { bg = background, fg = p.foreground },
    NeogitHunkHeaderHighlight = { bg = p.comment, fg = p.color7 },
    NeogitRemote = { fg = p.color6 },


    -- nvim-cmp: https://github.com/hrsh7th/nvim-cmp
    CmpDocumentationBorder = { fg = p.foreground, bg = background },
    CmpItemAbbr = { fg = p.foreground, bg = background },
    CmpItemAbbrDeprecated = { fg = p.color2, bg = background },
    CmpItemAbbrMatch = { fg = p.color7, bg = background },
    CmpItemAbbrMatchFuzzy = { fg = p.color7, bg = background },
    CmpItemKind = { fg = p.color4, bg = background },
    CmpItemMenu = { fg = p.color2, bg = background },

    -- nvim-treesitter: https://github.com/nvim-treesitter/nvim-treesitter
    ["@attribute"] = { fg = p.color4 },
    ["@boolean"] = { fg = p.color6 },
    ["@character"] = { fg = p.color4 },
    ["@comment"] = { fg = p.comment, italic = true },
    ["@conditional"] = { fg = p.color1 },
    ["@constant"] = { fg = p.color6 },
    ["@constant.builtin"] = { fg = p.color4 },
    ["@constant.macro"] = { fg = p.color3 },
    ["@constructor"] = { fg = p.color4 },
    ["@exception"] = { fg = p.color8 },
    ["@field"] = { fg = p.color1 },
    ["@float"] = { fg = p.color8 },
    ["@function"] = { fg = p.color1 },
    ["@function.builtin"] = { fg = p.color14 },
    ["@function.macro"] = { fg = p.color2 },
    ["@include"] = { fg = p.color9 },
    ["@keyword"] = { fg = p.color5 },
    ["@keyword.function"] = { fg = p.color4 },
    ["@keyword.operator"] = { fg = p.color12 },
    ["@keyword.return"] = { fg = p.color4 },
    ["@label"] = { fg = p.color4 },
    ["@method"] = { fg = p.color12 },
    ["@namespace"] = { fg = p.color9 },
    ["@number"] = { fg = p.color3 },
    ["@operator"] = { fg = p.color7 },
    ["@parameter"] = { fg = p.color1 },
    ["@parameter.reference"] = { fg = p.color9 },
    ["@property"] = { fg = p.color1 },
    ["@punctuation.bracket"] = { fg = p.color7 },
    ["@punctuation.delimiter"] = { fg = p.color7 },
    ["@punctuation.special"] = { fg = p.color7 },
    ["@repeat"] = { fg = p.color11 },
    ["@string"] = { fg = p.color2 },
    ["@string.escape"] = { fg = p.color4 },
    ["@string.regex"] = { fg = p.color2 },
    ["@string.special"] = { fg = p.color4 },
    ["@symbol"] = { fg = p.color1 },
    ["@tag"] = { fg = p.color4 },
    ["@tag.attribute"] = { fg = p.color1 },
    ["@tag.delimiter"] = { fg = p.color7 },
    ["@text"] = { fg = p.color7 },
    ["@text.danger"] = { fg = p.color8 },
    ["@text.emphasis"] = { fg = p.color7, italic = true },
    ["@text.environment.name"] = { fg = p.color3 },
    ["@text.environtment"] = { fg = p.color5 },
    ["@text.literal"] = { fg = p.color2, italic = true },
    ["@text.math"] = { fg = p.color6 },
    ["@text.note"] = { fg = p.color8 },
    ["@text.reference"] = { fg = p.color6 },
    ["@text.strike"] = { fg = p.color7, strikethrough = true },
    ["@text.strong"] = { fg = p.color7, bold = true },
    ["@text.title"] = { fg = p.color3, bold = true },
    ["@text.underline"] = { fg = p.color5, underline = true },
    ["@text.uri"] = { fg = p.color3, underline = true },
    ["@text.warning"] = { fg = p.color0, bg = p.color1 },
    ["@type"] = { fg = p.color3 },
    ["@type.builtin"] = { fg = p.color3 },
    ["@variable"] = { fg = p.color7 },
    ["@variable.builtin"] = { fg = p.color4 },

    -- telescope.nvim: https://github.com/nvim-telescope/telescope.nvim
    TelescopeBorder = { fg = p.color0, bg = background },
    TelescopeNormal = { fg = p.foreground, bg = background },
    TelescopeSelection = { fg = p.background, bg = p.color5 },

    -- vim-illuminate: https://github.com/RRethy/vim-illuminate
    illuminatedCurWord = { bg = p.foreground },
    illuminatedWord = { bg = p.foreground },
}

vim.g.terminal_color_0 = p.color0
vim.g.terminal_color_1 = p.color1
vim.g.terminal_color_2 = p.color2
vim.g.terminal_color_3 = p.color3
vim.g.terminal_color_4 = p.color4
vim.g.terminal_color_5 = p.color5
vim.g.terminal_color_6 = p.color6
vim.g.terminal_color_7 = p.color7
vim.g.terminal_color_8 = p.color8
vim.g.terminal_color_9 = p.color9
vim.g.terminal_color_10 = p.color10
vim.g.terminal_color_11 = p.color11
vim.g.terminal_color_12 = p.color12
vim.g.terminal_color_13 = p.color13
vim.g.terminal_color_14 = p.color14
vim.g.terminal_color_15 = p.color15


local setHl = function(group, color)
    color = vim.tbl_extend('force', color, { fg = color.fg, bg = color.bg, sp = color.sp })
    vim.api.nvim_set_hl(0, group, color)
end

ENV_EDITOR_NS = vim.api.nvim_create_namespace("env_editor_ns");
vim.api.nvim_set_hl(ENV_EDITOR_NS, "StatusLineNC", { bg = p.color1, fg = p.background })
vim.api.nvim_set_hl(ENV_EDITOR_NS, "StatusLine", { bg = p.color3, fg = p.background })
vim.api.nvim_set_hl(ENV_EDITOR_NS, "StatusLine", { bg = p.color3, fg = p.background })
vim.api.nvim_set_hl(ENV_EDITOR_NS, "WinSeparator", { bg = background, fg = p.color1 })


for group, color in pairs(theme) do
    setHl(group, color)
end
