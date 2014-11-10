function! playball#Playball(...) abort
  if a:0 >= 1
    let team = a:1
  else
    let team = g:playball_team
  end

python << EOF
import datetime
import sys
import urllib2
import vim
import lxml.html

def getGameInfo(today, team, league):
  """
  対戦相手，球場，時間を返す
  """
  n_year, n_month, n_day = today
  url = 'http://www.npb.or.jp/CGI/schedule/view.cgi?league_cd='+league+'&s_date='+n_year+'0301&e_date='+n_year+'1031'
  html = urllib2.urlopen(url).read() # html 取得
  root = lxml.html.fromstring(html, parser=lxml.html.HTMLParser(encoding='shift-jis'))

  color = '#CCFFCC' if league == 'C' else '#FFFFCC'
  trs = root.xpath('//tr[@bgcolor="' + color + '"]')
  for i, tr in enumerate(trs):
    # 日付
    day = tr.xpath('td[@align="RIGHT"]/text()')[0]
    if n_month[1] + '/' in day:
      tr = trs[i+int(n_day)-1]
      # 試合日程
      games = tr.xpath('td[@align="RIGHT"]/following-sibling::node()//text()')
      if not True in [team in game.split('-') for game in games]:
        # team の試合がない
        return False
      num = [team in game.split('-') for game in games].index(True)
      # DB-S, 神宮, 6:00
      return map(lambda x: x.encode('utf-8'), games[num:num+3])
  return False

def main():
  centralEN = ['G', 'D', 'T', 'DB', 'C', 'S']
  centralJA = ['読売', '中日', '阪神', '横浜DeNA', '広島東洋', '東京ヤクルト']
  pacificEN = ['H', 'M', 'Bs', 'L', 'F', 'E']
  pacificJA = ['福岡ソフトバンク', '千葉ロッテ', 'オリックス', '埼玉西武', '北海道日本ハム', '東北楽天']

  team = vim.eval('team')
  if not team in centralEN + pacificEN:
    info = 'Playball: Setting Error'
    return [info, 'error']

  # リーグ: セントラル or パシフィック
  league = 'C' if team in centralEN else 'P'

  today = datetime.datetime.now().strftime('%Y %m %d').split()
  #today = ['2014', '05', '10']
  gameInfo = getGameInfo(today, team, league)
  if not gameInfo:
    info = 'Playball: ' + '/'.join(today) + ' 今日は試合がありません'
    return [info, 'success']

  # チーム略称を英語から日本語に変換
  teams = dict(zip(centralEN + pacificEN, centralJA + pacificJA))
  gameTeamNames = [teams[gameTeamName] for gameTeamName in gameInfo[0].split('-')]
  gameInfo[0] = ' vs '.join(gameTeamNames)

  # ゲーム開始時刻を24時間表記に変換
  gameStartTime = gameInfo[2].split(':')
  gameStartTime[0] = str(int(gameStartTime[0]) + 12)
  gameInfo[2] = ':'.join(gameStartTime)

  # result
  info = ' '.join(['Playball:', '/'.join(today), gameInfo[2] + ',', ', '.join(gameInfo[:2])])
  return [info, 'success']

infoMsg = infoType = ''
try:
  infoMsg, infoType = main()
except urllib2.URLError as e:
  # ネットワークに繋がっていない
  pass

vim.command('let infoMsg="' + infoMsg + '"')
vim.command('let infoType="' + infoType + '"')
EOF

  if infoType == 'success'
    echohl MoreMsg | echo infoMsg | echohl None
  elseif infoType == 'error'
    echohl ErrorMsg | echo infoMsg | echohl None
  else
    echohl WarningMsg | echo infoMsg | echohl None
  endif
endfunction

"let g:playball_team='DB'
"command! -nargs=? Playball call playball#Playball(<f-args>)
