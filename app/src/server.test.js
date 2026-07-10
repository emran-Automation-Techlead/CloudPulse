// ---------------------------------------------------------------------------
// PLAIN ENGLISH: A minimal automated test proving the health check
// endpoint actually works. CI runs this before building a container
// image — if the app is broken, the pipeline stops here instead of
// shipping a broken image further down the line.
// ---------------------------------------------------------------------------

const test = require("node:test");
const assert = require("node:assert");
const http = require("node:http");

process.env.PORT = 0; // ephemeral port for the test run

test("GET /healthz returns 200 and status ok", async () => {
  delete require.cache[require.resolve("./server")];
  const server = require("./server");

  await new Promise((resolve) => server.on("listening", resolve));
  const { port } = server.address();

  const body = await new Promise((resolve, reject) => {
    http.get(`http://127.0.0.1:${port}/healthz`, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => resolve({ status: res.statusCode, data }));
    }).on("error", reject);
  });

  assert.strictEqual(body.status, 200);
  assert.deepStrictEqual(JSON.parse(body.data), { status: "ok" });

  server.close();
});
