# Runs REAL commands in a visible Windows Terminal window, with typed-out prompts for readability.
# Everything printed below the typed command is genuine output of that command.
# It waits for go.flag so the recorder can verify the capture window first.
param([string]$Root = "C:\Users\Administrator\CloudPulse", [string]$Tools, [string]$Work)
$host.UI.RawUI.WindowTitle = 'CloudPulseDemo'
Write-Host "CLOUDPULSE DEMO TERMINAL - READY (capture check)" -ForegroundColor Yellow
while(-not (Test-Path (Join-Path $Work 'go.flag'))){ Start-Sleep -Milliseconds 300 }
$env:PATH = "$Tools\node\node-v22.11.0-win-x64;$Tools\opa;$env:PATH"
Set-Location $Root; Start-Sleep 2
$Host.UI.RawUI.BackgroundColor = 'Black'; Clear-Host
function Say($t){ Write-Host "`n# $t" -ForegroundColor Cyan; Start-Sleep 3 }
function Run($cmd, $wait = 4){
  Write-Host -NoNewline "PS CloudPulse> " -ForegroundColor Green
  foreach($c in $cmd.ToCharArray()){ Write-Host -NoNewline $c; Start-Sleep -Milliseconds 35 }
  Write-Host ""; Start-Sleep 1
  Invoke-Expression $cmd
  Start-Sleep $wait
}
Say "1/6  Original service (container / EKS design): app/src/server.js"
Run "Get-Content app/src/server.js | Select-Object -Skip 11 -First 22" 7
Say "2/6  Serverless port for the live demo: deploy/serverless-demo/src/handler.js"
Run "Get-Content deploy/serverless-demo/src/handler.js | Select-Object -Skip 13" 8
Say "3/6  Its unit tests (offline, real run)"
Run "cd deploy/serverless-demo; npm test 2>&1 | Select-String 'ok|not ok|# (tests|pass|fail)'; cd ../.." 5
Say "4/6  What else the repo holds (architecture as code, not deployed here)"
Run "Get-ChildItem terraform/modules, policies/opa/terraform, k8s/base -Name" 6
Say "5/6  OPA policy enforcement - real repository policy, two inputs"
Run "Get-Content docs/evidence/opa-samples/sg-rule-open-ssh.json" 3
Run "opa eval -d policies/opa/terraform/deny_open_security_groups.rego -i docs/evidence/opa-samples/sg-rule-open-ssh.json 'data.terraform.security.deny' --format pretty" 7
Run "opa eval -d policies/opa/terraform/deny_open_security_groups.rego -i docs/evidence/opa-samples/sg-rule-ssh-office-only.json 'data.terraform.security.deny' --format pretty" 5
Run "opa test policies/opa" 5
Say "6/6  Weekly cost report - SYNTHETIC numbers, no AWS call, not live billing"
Run "python deploy/serverless-demo/scripts/cost_report_synthetic.py" 9
Say "End of local segments. AWS segments are recorded only after approved deployment."
Start-Sleep 4
New-Item (Join-Path $Work 'done.flag') -ItemType File -Force | Out-Null
Start-Sleep 600   # keep the window open so the capture area never exposes another window
