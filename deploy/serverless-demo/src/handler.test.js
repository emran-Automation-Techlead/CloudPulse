// PLAIN ENGLISH: Offline tests for the Lambda handler. Run: node --test src/handler.test.js
const test = require("node:test");
const assert = require("node:assert");
const { handler } = require("./handler");

const ev = (method, rawPath) => ({ rawPath, requestContext: { http: { method } } });
const call = async (method, path) => {
  const res = await handler(ev(method, path));
  return { ...res, json: JSON.parse(res.body) };
};

test("GET /healthz returns ok (same body as server.js)", async () => {
  const res = await call("GET", "/healthz");
  assert.strictEqual(res.statusCode, 200);
  assert.deepStrictEqual(res.json, { status: "ok" });
  assert.strictEqual(res.headers["Content-Type"], "application/json");
});

test("GET /version reflects APP_VERSION, defaulting to dev", async () => {
  delete process.env.APP_VERSION;
  assert.deepStrictEqual((await call("GET", "/version")).json, { version: "dev" });
  process.env.APP_VERSION = "1.2.3";
  assert.deepStrictEqual((await call("GET", "/version")).json, { version: "1.2.3" });
  delete process.env.APP_VERSION;
});

test("GET / returns the greeting plus version", async () => {
  process.env.APP_VERSION = "9";
  const res = await call("GET", "/");
  assert.strictEqual(res.statusCode, 200);
  assert.deepStrictEqual(res.json, { message: "CloudPulse sample service is running", version: "9" });
  delete process.env.APP_VERSION;
});

test("unknown path returns structured 404", async () => {
  const res = await call("GET", "/nope");
  assert.strictEqual(res.statusCode, 404);
  assert.deepStrictEqual(res.json, { error: "not_found", path: "/nope" });
});

test("non-GET method returns structured 405 with Allow header", async () => {
  const res = await call("POST", "/healthz");
  assert.strictEqual(res.statusCode, 405);
  assert.strictEqual(res.headers.Allow, "GET");
  assert.strictEqual(res.json.error, "method_not_allowed");
});
