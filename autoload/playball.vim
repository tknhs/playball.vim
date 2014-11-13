function! playball#Playball(...) abort
  let pluginName = "Playball.vim: "
  let teamDict = {"G": "読売", "D": "中日", "T": "阪神",
        \ "DB": "横浜DeNA", "C": "広島東洋", "S": "東京ヤクルト",
        \ "H": "福岡ソフトバンク", "M": "千葉ロッテ", "Bs": "オリックス",
        \ "L": "埼玉西武", "F": "北海道日本ハム", "E": "東北楽天"}
  let date = strftime("%Y%m%d", localtime())

  if a:0 >= 1
    let p_args = split(a:1, " ")
    let myTeam = p_args[0]
    if len(p_args) == 2
      let date = p_args[1]
    endif
  else
    let myTeam = g:playball_team
  end

  " エラーチェック
  if len(date) != 8
    let infoMsg = pluginName."日付が不正 Ex) 20140920"
    echohl ErrorMsg | echo infoMsg | echohl None
    return
  endif
  if has_key(teamDict, myTeam) != 1
    let infoMsg = pluginName."チーム名が不正 Ex) DB"
    echohl ErrorMsg | echo infoMsg | echohl None
    return
  endif

let url = "https://npbann.appspot.com/api/game?date=".date
let res = webapi#http#get(url)
if res['status'] != 200
  let infoMsg = pluginName."ネットワークエラー"
  echohl WarningMsg | echo infoMsg | echohl None
  return
endif
let content = webapi#json#decode(res.content)

let date = content.date
let date = date[0:3]."/".date[4:5]."/".date[6:7]

let infoMsg = pluginName. join([date, "試合はありません"], ", ")
let game = content.game
for g in game
  let isMyTeam = "false"
  for t in split(g.team, "-")
    if t == myTeam
      let isMyTeam = "true"
    endif
  endfor

  if isMyTeam == "true"
    let team = split(g.team, "-")
    let g.team = teamDict[team[0]]." vs ".teamDict[team[1]]
    let infoMsg = pluginName.date." ".join([g.time, g.team, g.place], ", ")
    break
  endif
endfor

echohl MoreMsg | echo infoMsg | echohl None
endfunction
