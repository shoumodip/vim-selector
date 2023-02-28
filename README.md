# selector.vim
Interactive selection prompt for vim

## Installation
```vim
Plug 'shoumodip/vim-selector'
```

## Usage
| Function           | Description            |
| ------------------ | ---------------------- |
| `selector#files`   | Find files recursively |
| `selector#browse`  | Browse the filesystem  |
| `selector#buffers` | Switch buffers         |

## API
```vim
selector#run({prompt}, {items}, [, {needs_match}])
```
