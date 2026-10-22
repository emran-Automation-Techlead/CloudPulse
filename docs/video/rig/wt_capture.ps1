# Windows Terminal capture helper (no registry changes).
#  -Verify : opens ONE Windows Terminal window titled CloudPulseDemo, locates it by exact title via EnumWindows,
#            positions it on the primary monitor, saves verify.png of exactly that rectangle, leaves it open.
#  -Record : continues: creates go.flag (demo starts) and records that same rectangle.
#  -Close  : closes the CloudPulseDemo window.
param([string]$Work, [string]$Tools, [switch]$Record, [switch]$Close, [int]$Seconds = 300, [string]$Out = "local_raw.mp4")
Add-Type @"
using System; using System.Text; using System.Collections.Generic; using System.Runtime.InteropServices;
public class WT {
 public delegate bool EP(IntPtr h, IntPtr l);
 [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
 [DllImport("user32.dll")] static extern bool EnumWindows(EP p, IntPtr l);
 [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
 [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr a, int x, int y, int w, int ht, uint f);
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out R r);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
 [StructLayout(LayoutKind.Sequential)] public struct R { public int L, T, Rt, B; }
 public static List<IntPtr> Find(string title) { var l = new List<IntPtr>();
  EnumWindows((h, p) => { if (IsWindowVisible(h)) { var sb = new StringBuilder(256); GetWindowText(h, sb, 256); if (sb.ToString() == title) l.Add(h); } return true; }, IntPtr.Zero); return l; }
}
"@
[void][WT]::SetProcessDPIAware()
New-Item -ItemType Directory -Force $Work | Out-Null
if($Close){ foreach($h in [WT]::Find("CloudPulseDemo")){ [void][WT]::PostMessage($h, 0x10, [IntPtr]::Zero, [IntPtr]::Zero) }; exit 0 }
Remove-Item "$Work\go.flag","$Work\verify.png" -Force -ErrorAction SilentlyContinue
if(([WT]::Find("CloudPulseDemo")).Count -gt 0){ Write-Host "FAIL: a CloudPulseDemo window already exists"; exit 1 }
$demo = Join-Path $PSScriptRoot 'local_demo.ps1'
Start-Process wt.exe -ArgumentList @("-w","new","--title","CloudPulseDemo","--suppressApplicationTitle","powershell.exe","-NoLogo","-NoProfile","-File","`"$demo`"","-Tools","`"$Tools`"","-Work","`"$Work`"")
$hs = @(); for($i=0; $i -lt 20 -and $hs.Count -eq 0; $i++){ Start-Sleep 1; $hs = @([WT]::Find("CloudPulseDemo")) }
if($hs.Count -ne 1){ Write-Host "FAIL: expected exactly 1 CloudPulseDemo window, found $($hs.Count)"; exit 1 }
$h = $hs[0]
[void][WT]::SetWindowPos($h, [IntPtr](-1), 40, 30, 1760, 990, 0x0040)   # HWND_TOPMOST, show
Start-Sleep 2
$r = New-Object WT+R; [void][WT]::GetWindowRect($h, [ref]$r)
$w = ($r.Rt-$r.L); $ht = ($r.B-$r.T); $w -= $w % 2; $ht -= $ht % 2
Write-Host "capture rect: x=$($r.L) y=$($r.T) ${w}x${ht}"
if($w -lt 800 -or $ht -lt 500){ Write-Host "FAIL: implausible window rectangle"; exit 1 }
& ffmpeg -y -loglevel error -f gdigrab -offset_x $r.L -offset_y $r.T -video_size ${w}x${ht} -i desktop -frames:v 1 "$Work\verify.png"
if(-not (Test-Path "$Work\verify.png")){ Write-Host "FAIL: verify frame not written"; exit 1 }
if(-not $Record){ Write-Host "VERIFY ONLY: inspect $Work\verify.png, then run with -Close"; exit 0 }
New-Item "$Work\go.flag" -ItemType File | Out-Null
& ffmpeg -y -loglevel error -f gdigrab -framerate 30 -offset_x $r.L -offset_y $r.T -video_size ${w}x${ht} -i desktop `
  -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2:color=black" `
  -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 -t $Seconds "$Work\$Out"
