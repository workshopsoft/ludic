bump: patch
type: feature
**`r3d_small`: a renderer sized for a small UI window.** Set before `r3d_open`, it gives the frame's
uniform ring 2 x 4 MB (was 2 x 64), memory blocks of 8 MB with anything over 4 MB on its own (was 64 and
16) and descriptor pools an eighth of a world's. Maroon Lake's launcher window, which draws a picture and
text and never becomes the game, went from 817 MB to 446 MB with it and its own trims; the rest is the
font atlas, the backdrop, Metal's command-buffer storage while it draws, and the program's states.
