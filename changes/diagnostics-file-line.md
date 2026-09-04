bump: minor
type: feat
Every compiler diagnostic is reported as `file:line: error: message` — the file the line really lives in, even through imports — so editors can jump to it. Unexpected characters are errors (they used to be skipped silently), and defining one `function` twice is reported in source terms instead of failing in the IR assembler.
