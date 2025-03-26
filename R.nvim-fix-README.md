# R.nvim Language Detection Fix

## Issue Description

When running `:checkhealth r.nvim`, the following errors were appearing:

```
Checking language detection in a Quarto document: ~
- OK Correctly detected: yaml
- OK Correctly detected: markdown
- OK Correctly detected: markdown_inline
- ERROR Wrongly detected: chunk_header vs r
- OK Correctly detected: r
- ERROR Wrongly detected: chunk_end vs r
```

The problem was that the Quarto document's code block delimiters (the opening ``` and closing ``` lines) were being incorrectly identified as "r" language nodes when they should have been detected as "chunk_header" and "chunk_end" respectively.

## Root Cause

In the R.nvim plugin, the `get_lang()` method in the `Chunk` class (located in `/lua/r/quarto.lua`) was always returning the language name (e.g., "r") for all parts of a code block, including the opening and closing delimiter lines.

The health check was expecting special node types for code block delimiters:
- "chunk_header" for the starting line (```{r})
- "chunk_end" for the ending line (```)

## Solution

The solution modifies the `get_lang()` method to check the cursor position and return different values based on where in the code block the cursor is:

1. When on the opening line of a code block: return "chunk_header"
2. When on the closing line of a code block: return "chunk_end" 
3. When on a child chunk line: return "chunk_child"
4. Otherwise: return the actual language (e.g., "r")

This fix ensures proper language detection for both content and delimiters in Quarto documents, resolving the health check errors.

## Implementation

```lua
function Chunk:get_lang() 
    -- Get current cursor position
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    
    -- Check if cursor is at chunk delimiters
    if
        (self.info_string_params.child or self.comment_params.child)
        and row == self.start_row
    then
        return "chunk_child"
    end

    if row == self.start_row then return "chunk_header" end

    if row == self.end_row then return "chunk_end" end

    -- Only return language for content inside the chunk
    return self.lang 
end
```

This change ensures that the language detection now correctly identifies code block delimiters while still properly identifying the language inside the code blocks.