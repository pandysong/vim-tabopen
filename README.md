# the plugin to open the file under the cursor on the right windows

This is a lightweight bookmark like plugin.

# get the file:ln for the current cursor

Add following to .vimrc:

```
noremap <leader>m :let @@=expand("%:.").":".line(".").": ".expand("<cword>")
```

This will yank the file:ln, and you could paste to any document.

# Install this plugin

Add following in vundle or other plugins manager

```
Plugin 'pandysong/vim-tabopen`
```

In vim:

```
:PluginInstall
```

# How to use

gF to open the file:linenumber under the cursor

```
gF
```
