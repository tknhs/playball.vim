function! playball#Playball(...) abort
  let pluginName = "Playball.vim: "
  let teamDict = {
        \ "C": "広島", "T": "阪神", "DB": "DeNA",
        \ "G": "読売", "D": "中日", "S": "ヤクルト",
        \ "H": "ソフトバンク", "L": "西武", "E": "楽天",
        \ "Bs": "オリックス", "F": "日本ハム", "M": "ロッテ"}
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

  let dateYear = date[0:3]
  let dateMonth = date[4:5]
  let dateDay = date[6:7]
  if str2nr(dateYear, 10) <= 2015
    let infoMsg = pluginName."2015年以前は未対応"
    echohl WarningMsg | echo infoMsg | echohl None
    return
  endif

  " 解析開始
  let url = "http://npb.jp/games/".dateYear."/schedule_".dateMonth."_detail.html"
  let res = webapi#http#get(url)
  if res['status'] != 200
    let infoMsg = pluginName."ネットワークエラー"
    echohl WarningMsg | echo infoMsg | echohl None
    return
  endif

  let res.content = iconv(res.content, 'utf-8', &encoding)
  let res.content = substitute(res.content, '<!--.\{-}-->', '', 'g')
  let res.content = substitute(res.content, '<script[^>]*>.\{-}<\/script>', '', 'g')
  let res.content = substitute(res.content, '.*\(<body[^>]*>.*</body>\).*', '\1', '')
  let res.content = substitute(res.content, '<\(br\|meta\|link\|hr\)\s*>', '<\1/>', 'g')

  redraw | echo 'parsing data...'
  let dom = webapi#xml#parse(res.content)
  let games = dom.find('div', {'id': 'schedule_detail'}).findAll('tr', {'id': 'date'.dateMonth.dateDay})
  redraw | echo 'parsing finished'

  let result = "試合はありません"
  for game in games
    " 試合の有無
    let hasGame = empty(substitute(game.find('td').value(), '&nbsp;', '', 'g'))
    if hasGame
      break
    endif

    " 共通予備日
    let commonPreparationDay = game.childNode('td').childNode('div', {'class': 'commentLong'})
    if !empty(commonPreparationDay)
        break
    endif

    try
      let team1 = game.find('div', {'class': 'team1'}).value()
      let team2 = game.find('div', {'class': 'team2'}).value()
      if index([team1, team2], teamDict[myTeam]) == -1
          continue
      endif
      let place = game.find('div', {'class': 'place'}).value()
      let time = game.find('div', {'class': 'time'}).value()
      let score1 = substitute(game.find('div', {'class': 'score1'}).value(), '&nbsp;', ' ', 'g')
      let state = game.find('div', {'class': 'state'}).value()
      let score2 = substitute(game.find('div', {'class': 'score2'}).value(), '&nbsp;', ' ', 'g')
      let gameResult = join([team1, score1, state, score2, team2], ' ')
    catch
      let cancel = game.find('div', {'class': 'cancel'}).value()
      let gameResult = join([team1, cancel, team2], ' ')
    endtry
    let result = join([time, place, gameResult], ', ')
  endfor

  let date = dateYear.'/'.dateMonth.'/'.dateDay
  let infoMsg = pluginName.date.' '.result
  redraw | echo infoMsg
endfunction
