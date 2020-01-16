# vim-translate

这是基于有道网页翻译爬虫的一个vim插件，使用python3编写。需要安装python3环境，使用时需要联网。

## Install

### 安装依赖

需要环境中有`python3`，需要安装python3的包`bs4`和`html5lib`

```bash
pip3 install -U bs4 html5lib
```

### 安装插件

例如使用`vim-plug`，其他的也大同小异。

```vim
Plug '0382/vim-translate'
```

## Usage

目前只有中英互译，只提供一个命令`Trans`，例如
```vim
:Trans hello world
:Trans 你好
```

### Options

使用下面的选项控制输出格式

- `g:translate_show_pronunciation`

控制是否显示音标，default: `1`

- `g:translate_show_addition`

控制是否显示单词过去式，第三人称单数等附加信息，default: `1`

## todo

- [] 使用快捷键对光标悬停的单词进行翻译
