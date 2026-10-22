# Recording plan (capture-source rules)

1. Capture **only** a verified window rectangle (never `-i desktop` full-screen): the user's second monitor/browser can show
   unrelated content (e.g. a course video). A frame of the exact capture rectangle must be saved and visually checked
   BEFORE recording; a recording that shows anything else is deleted, never used.
2. Segments and their sources
   | Segment | Source | Status |
   |---|---|---|
   | GitHub walkthrough | Chrome (Claude in Chrome tab/window) on github.com/emran-Automation-Techlead/CloudPulse - note the repo does NOT contain `deploy/` until pushed | not recorded |
   | Code, tests, OPA, synthetic cost report | demo terminal (`docs/video/rig/local_demo.ps1`, real commands) | rig works up to window capture; see blocker |
   | AWS Console (Sydney) + endpoint + CloudWatch | Chrome window | blocked on approvals + deploy |
3. RESOLVED 2026-10-22 (rig/wt_capture.ps1: EnumWindows by exact title, verify frame inspected before recording; no registry changes). Old blocker: on this Windows 11 host, consoles launched via `conhost.exe` are delegated to Windows Terminal, so
   `GetConsoleWindow()` returns a hidden pseudo-window (rect 0,0) and the per-title font registry key is ignored.
   Options: record a Windows Terminal window found by process handle (font enlarged in post), or have the owner start
   the demo in their own terminal and record that window.
4. Narration: ElevenLabs only after visuals are final; credits cannot be queried with the available tools, and the
   workspace was at 0 credits on 2026-09-07 - stop on any quota error.
5. Final checks: ffprobe duration/resolution/audio, frame sampling for secrets (account ID, keys), URL correctness.

## Status 2026-10-22
- Local segments recorded from a verified Windows Terminal window: `docs/video/raw/local_segments.mp4` (136 s, 1920x1080, 30 fps, no audio; git-ignored). Contains: server.js, handler.js, 5/5 tests, repo tree, OPA deny/allow + 4/4 policy tests, SYNTHETIC cost report.
- GitHub segment deferred until `deploy/` is pushed (otherwise the page would not show the serverless demo); push needs user authorization.
- AWS segments, narration, final assembly: blocked on administrator IAM changes + deploy approval.
