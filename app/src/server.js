// ---------------------------------------------------------------------------
// PLAIN ENGLISH: This is a deliberately tiny "hello world" web service. Its
// only job is to give the CI/CD pipeline, Docker image, and Kubernetes
// manifests something real to build, scan, and deploy — so every other
// piece of CloudPulse can be demonstrated end-to-end instead of staying
// theoretical. It exposes a health check (used by Kubernetes to know if
// the app is alive) and a version endpoint (used by the canary rollout
// to prove which version of the app is actually serving traffic).
// ---------------------------------------------------------------------------

const http = require("node:http");

const PORT = process.env.PORT || 8080;
const VERSION = process.env.APP_VERSION || "dev";

const server = http.createServer((req, res) => {
  if (req.url === "/healthz") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok" }));
    return;
  }

  if (req.url === "/version") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ version: VERSION }));
    return;
  }

  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ message: "CloudPulse sample service is running", version: VERSION }));
});

server.listen(PORT, () => {
  console.log(`CloudPulse sample app listening on port ${PORT} (version ${VERSION})`);
});

module.exports = server;
