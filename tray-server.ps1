Add-Type -AssemblyName System.Windows.Forms, System.Drawing

$h = New-Object System.Net.HttpListener
$h.Prefixes.Add("http://+:80/")
$h.Start()

$rs = [runspacefactory]::CreateRunspace()
$rs.Open()
$rs.SessionStateProxy.SetVariable("h", $h)
$rs.SessionStateProxy.SetVariable("dir", $PWD.Path)

$ps = [powershell]::Create()
$ps.Runspace = $rs
[void]$ps.AddScript({
  $gbFile = Join-Path $dir "guestbook.json"
  $scFile = Join-Path $dir "scores.json"
  $tttFile = Join-Path $dir "ttt.json"
  $clipFile = Join-Path $dir "clip.json"
  $tttInit = '{"board":["","","","","","","","",""],"turn":"X","pX":"","pO":"","winner":""}'
  if (-not (Test-Path $gbFile)) { [IO.File]::WriteAllText($gbFile, "[]", [Text.Encoding]::UTF8) }
  if (-not (Test-Path $scFile)) { [IO.File]::WriteAllText($scFile, '{"snake":{"name":"--","val":0},"react":{"name":"--","val":9999}}', [Text.Encoding]::UTF8) }
  if (-not (Test-Path $tttFile)) { [IO.File]::WriteAllText($tttFile, $tttInit, [Text.Encoding]::UTF8) }
  if (-not (Test-Path $clipFile)) { [IO.File]::WriteAllText($clipFile, '{"text":"","time":""}', [Text.Encoding]::UTF8) }

  while ($h.IsListening) {
    try {
      $c = $h.GetContext()
      $u = $c.Request.Url.LocalPath.TrimStart('/')
      if ($u -eq "api/guestbook") {
        $method = $c.Request.HttpMethod
        if ($method -eq "POST" -or $method -eq "PUT" -or $method -eq "DELETE") {
          $sr = New-Object IO.StreamReader($c.Request.InputStream, [Text.Encoding]::UTF8)
          $body = $sr.ReadToEnd()
          $sr.Close()
          $entry = $body | ConvertFrom-Json
          $raw = [IO.File]::ReadAllText($gbFile, [Text.Encoding]::UTF8)
          $list = @($raw | ConvertFrom-Json)

          if ($method -eq "POST") {
            $name = if ($entry.name) { $entry.name.ToString().Trim() } else { "Anonymous" }
            $msg = if ($entry.msg) { $entry.msg.ToString().Trim() } else { "" }
            if ($name.Length -gt 24) { $name = $name.Substring(0, 24) }
            if ($msg.Length -gt 280) { $msg = $msg.Substring(0, 280) }
            if ($msg -ne "") {
              $id = [guid]::NewGuid().ToString("N").Substring(0, 8)
              $newItem = [PSCustomObject]@{ id = $id; name = $name; msg = $msg; time = (Get-Date -Format "MMM d, h:mm tt") }
              $list = @($newItem) + $list
              if ($list.Count -gt 50) { $list = $list | Select-Object -First 50 }
            }
          } elseif ($method -eq "PUT") {
            $targetId = $entry.id
            $newMsg = if ($entry.msg) { $entry.msg.ToString().Trim() } else { "" }
            if ($newMsg.Length -gt 280) { $newMsg = $newMsg.Substring(0, 280) }
            if ($newMsg -ne "") {
              foreach ($item in $list) {
                if ($item.id -eq $targetId) {
                  $item.msg = $newMsg
                  $item.time = (Get-Date -Format "MMM d, h:mm tt") + " (edited)"
                }
              }
            }
          } elseif ($method -eq "DELETE") {
            $targetId = $entry.id
            $list = @($list | Where-Object { $_.id -ne $targetId })
          }

          $jsonOut = ConvertTo-Json -InputObject @($list) -Depth 3 -Compress
          [IO.File]::WriteAllText($gbFile, $jsonOut, [Text.Encoding]::UTF8)
        }
        $out = [IO.File]::ReadAllBytes($gbFile)
        $c.Response.ContentType = "application/json; charset=utf-8"
        $c.Response.ContentLength64 = $out.Length
        $c.Response.OutputStream.Write($out, 0, $out.Length)
      } elseif ($u -eq "api/scores") {
        if ($c.Request.HttpMethod -eq "POST") {
          $sr = New-Object IO.StreamReader($c.Request.InputStream, [Text.Encoding]::UTF8)
          $body = $sr.ReadToEnd()
          $sr.Close()
          $inData = $body | ConvertFrom-Json
          $scores = [IO.File]::ReadAllText($scFile, [Text.Encoding]::UTF8) | ConvertFrom-Json
          $player = if ($inData.name) { $inData.name.ToString().Trim() } else { "Anonymous" }
          if ($player.Length -gt 24) { $player = $player.Substring(0, 24) }
          $val = [int]$inData.val
          if ($inData.game -eq "snake" -and $val -gt [int]$scores.snake.val) {
            $scores.snake.name = $player
            $scores.snake.val = $val
          } elseif ($inData.game -eq "react" -and $val -gt 0 -and $val -lt [int]$scores.react.val) {
            $scores.react.name = $player
            $scores.react.val = $val
          }
          $scOut = ConvertTo-Json -InputObject $scores -Depth 3 -Compress
          [IO.File]::WriteAllText($scFile, $scOut, [Text.Encoding]::UTF8)
        }
        $out = [IO.File]::ReadAllBytes($scFile)
        $c.Response.ContentType = "application/json; charset=utf-8"
        $c.Response.ContentLength64 = $out.Length
        $c.Response.OutputStream.Write($out, 0, $out.Length)
      } elseif ($u -eq "api/ttt") {
        if ($c.Request.HttpMethod -eq "POST") {
          $sr = New-Object IO.StreamReader($c.Request.InputStream, [Text.Encoding]::UTF8)
          $body = $sr.ReadToEnd()
          $sr.Close()
          $act = $body | ConvertFrom-Json
          $st = [IO.File]::ReadAllText($tttFile, [Text.Encoding]::UTF8) | ConvertFrom-Json
          $pName = if ($act.name) { $act.name.ToString().Trim() } else { "Player" }
          if ($pName.Length -gt 20) { $pName = $pName.Substring(0, 20) }

          if ($act.action -eq "reset") {
            $st = $tttInit | ConvertFrom-Json
          } elseif ($act.action -eq "join") {
            if ($act.side -eq "X") { $st.pX = $pName }
            elseif ($act.side -eq "O") { $st.pO = $pName }
          } elseif ($act.action -eq "move" -and $st.winner -eq "") {
            $idx = [int]$act.idx
            $side = $act.side.ToString()
            if ($idx -ge 0 -and $idx -le 8 -and $st.turn -eq $side -and $st.board.GetValue($idx) -eq "") {
              $st.board.SetValue($side, $idx)
              $wins = @(@(0,1,2),@(3,4,5),@(6,7,8),@(0,3,6),@(1,4,7),@(2,5,8),@(0,4,8),@(2,4,6))
              foreach ($w in $wins) {
                $a = $st.board.GetValue($w.GetValue(0))
                $b = $st.board.GetValue($w.GetValue(1))
                $c2 = $st.board.GetValue($w.GetValue(2))
                if ($a -ne "" -and $a -eq $b -and $a -eq $c2) {
                  $st.winner = $a
                }
              }
              if ($st.winner -eq "" -and ($st.board -notcontains "")) { $st.winner = "Draw" }
              if ($st.winner -eq "") { $st.turn = if ($side -eq "X") { "O" } else { "X" } }
            }
          }
          $tttOut = ConvertTo-Json -InputObject $st -Depth 3 -Compress
          [IO.File]::WriteAllText($tttFile, $tttOut, [Text.Encoding]::UTF8)
        }
        $out = [IO.File]::ReadAllBytes($tttFile)
        $c.Response.ContentType = "application/json; charset=utf-8"
        $c.Response.ContentLength64 = $out.Length
        $c.Response.OutputStream.Write($out, 0, $out.Length)
      } elseif ($u -eq "api/clip") {
        if ($c.Request.HttpMethod -eq "POST") {
          $sr = New-Object IO.StreamReader($c.Request.InputStream, [Text.Encoding]::UTF8)
          $body = $sr.ReadToEnd()
          $sr.Close()
          $inClip = $body | ConvertFrom-Json
          $txt = if ($inClip.text) { $inClip.text.ToString() } else { "" }
          if ($txt.Length -gt 4000) { $txt = $txt.Substring(0, 4000) }
          $obj = [PSCustomObject]@{ text = $txt; time = (Get-Date -Format "MMM d, h:mm tt") }
          $clipOut = ConvertTo-Json -InputObject $obj -Depth 2 -Compress
          [IO.File]::WriteAllText($clipFile, $clipOut, [Text.Encoding]::UTF8)
        }
        $out = [IO.File]::ReadAllBytes($clipFile)
        $c.Response.ContentType = "application/json; charset=utf-8"
        $c.Response.ContentLength64 = $out.Length
        $c.Response.OutputStream.Write($out, 0, $out.Length)
      } else {
        if ($u -eq '' -or $u -eq '/') { $u = 'lathgategg.htm' }
        if ($u -eq 'favicon.ico') { $u = 'fox.png' }
        $p = Join-Path $dir $u
        if (Test-Path $p -PathType Leaf) {
          $c.Response.ContentType = if ($p -like '*.png') { 'image/png' } elseif ($p -like '*.jpg') { 'image/jpeg' } else { 'text/html; charset=utf-8' }
          $b = [IO.File]::ReadAllBytes($p)
          $c.Response.ContentLength64 = $b.Length
          $c.Response.OutputStream.Write($b, 0, $b.Length)
        } else { $c.Response.StatusCode = 404 }
      }
      $c.Response.Close()
    } catch {}
  }
})
$handle = $ps.BeginInvoke()

$lanIp = (Get-NetIPConfiguration -ErrorAction SilentlyContinue |
  Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq "Up" } |
  ForEach-Object { $_.IPv4Address.IPAddress } |
  Select-Object -First 1)
if (-not $lanIp) { $lanIp = "127.0.0.1" }
$ipUrl = "http://$lanIp/"
$localUrl = "http://lathgate.local"

$tray = New-Object System.Windows.Forms.NotifyIcon
$icoPath = Join-Path $PWD.Path "fox.ico"
$tray.Icon = if (Test-Path $icoPath) { New-Object System.Drawing.Icon($icoPath) } else { [System.Drawing.SystemIcons]::Application }
$tipText = "Lathgate.gg`n$localUrl`n$ipUrl"
$tray.Text = if ($tipText.Length -gt 63) { $tipText.Substring(0, 63) } else { $tipText }
$tray.Visible = $true

$menu = New-Object System.Windows.Forms.ContextMenuStrip
[void]$menu.Items.Add("Open $localUrl", $null, { Start-Process $localUrl })
[void]$menu.Items.Add("Open $ipUrl", $null, { Start-Process $ipUrl })
[void]$menu.Items.Add("Copy $ipUrl", $null, { [System.Windows.Forms.Clipboard]::SetText($ipUrl) })
[void]$menu.Items.Add("-")
[void]$menu.Items.Add("Stop Server", $null, {
  $h.Stop()
  $tray.Visible = $false
  $tray.Dispose()
  [System.Windows.Forms.Application]::Exit()
})
$tray.ContextMenuStrip = $menu
$tray.add_DoubleClick({ Start-Process $localUrl })

[System.Windows.Forms.Application]::Run()
