-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- IF Any big popup (that is scrollable) has opened up, you can scroll inside of that popup with <c-f> and <c-b>
-- There can be use cases where you would want to go inside the popup to yoink some text that's shown, inorder to do it:
-- If the hover is generated by <S-k> press <c-w>w to go inside it, or <S-k> keybind again, and :q or <c-k> to go out.
-- Let's say you do '[e' which takes you to the previous error and you would wanna yoink the error to search for solutions,
-- press <c-w>w to go inside of it(<c-w> brings up windows options in neovim, and then pressing w again switches active windows) and <c-k> to go out.
--
-- Mini.Surround help keybinds.
-- "hello this is me typing" ---> while inside the quotes, do gsr"' to replace "" with ''.
-- "this is me again" ---> while inside the quotes, do gsd" to delete the surrounding quotes.
-- If you want to surround something inside of a html tag do, gsa{vim-motion}t , and then a box will appear in which you can type the tag name
-- to be surrounded with. The vim-motion can be 'iw' to signify you are trying to surround a word in a html tag.
-- Tip: when the box appears to enter the html tag name you can type, div classname='neovim' to get, <div classname="neovim"></div> as a result.
--
-- Talking of tags, if you want to change lets a tag type from a div to p, you can change the opening tag to p, and then press esc or <c-[> so that
-- the change will reflect on the closing tag aswell. You can do it with surround also, by first placing cursor on top of a tag and pressing, gsrtt,
-- and then giving a tag name which will then replace it on both opening and closing tags.
--

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
