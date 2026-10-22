// ---------------------------------------------------------------------------
// PLAIN ENGLISH: This is the serverless twin of app/src/server.js. The
// original is a container that listens on a port; this one is a Lambda
// function that AWS wakes up per request. It answers the same three
// questions (/, /healthz, /version) with the same JSON, so the demo
// shows the real service behaviour without needing EKS.
//
// Differences from server.js (deliberate, see ../README.md):
//   - non-GET methods get 405 and unknown paths get 404 with a JSON error
//     (server.js answers 200 for everything that is not /healthz or /version)
//   - the Lambda event format replaces node:http request objects
// ---------------------------------------------------------------------------

const json = (statusCode, body, extraHeaders = {}) => ({
  statusCode,
  headers: { "Content-Type": "application/json", ...extraHeaders },
  body: JSON.stringify(body),
});

exports.handler = async (event) => {
  // Function URLs and API Gateway HTTP APIs both send payload format 2.0.
  const method = event?.requestContext?.http?.method ?? event?.httpMethod ?? "GET";
  const path = event?.rawPath ?? event?.path ?? "/";
  const version = process.env.APP_VERSION || "dev";

  console.log(JSON.stringify({ msg: "request", method, path, version }));

  if (method !== "GET") {
    return json(405, { error: "method_not_allowed", allowed: ["GET"] }, { Allow: "GET" });
  }
  if (path === "/healthz") return json(200, { status: "ok" });
  if (path === "/version") return json(200, { version });
  if (path === "/") {
    return json(200, { message: "CloudPulse sample service is running", version });
  }
  return json(404, { error: "not_found", path });
};
