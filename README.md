# Playball.vim
今日，野球の試合があるかを確認するプラグイン

## インストール

```vim
NeoBundle 'mattn/webapi-vim'
NeoBundle 'tknhs/playball.vim'
```

## 設定

```vim
set runtimepath+=~/.vim/bundle/playball.vim
let g:playball_enable=1
let g:playball_team='DB' " チーム名: 英字省略表記
```

## 使い方

```vim
:Playball             " 設定したチーム
:Playball DB          " チーム名を指定
:Playball DB 20140920 " チーム名と日付を指定
```

## 使用できるチーム名

### セントラル・パシフィック
| 英 | 日           |   | 英 | 日               |
|:---|:-------------|:-:|:---|:-----------------|
| G  | 読売         |   | H  | 福岡ソフトバンク |
| T  | 阪神         |   | M  | 千葉ロッテ       |
| C  | 広島東洋     |   | Bs | オリックス       |
| D  | 中日         |   | L  | 埼玉西武         |
| DB | 横浜DeNA     |   | F  | 北海道日本ハム   |
| S  | 東京ヤクルト |   | E  | 東北楽天         |
