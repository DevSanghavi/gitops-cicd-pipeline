import http from "node:http";

const PORT = Number(process.env.PORT || 3000);
const APP_ENV = process.env.APP_ENV || "development";

export function healthPayload() {
  return { status: "ok", environment: APP_ENV };
}

const server = http.createServer((request, response) => {
  if (request.url === "/health") {
    response.writeHead(200, { "Content-Type": "application/json" });
    response.end(JSON.stringify(healthPayload()));
    return;
  }
  response.writeHead(404, { "Content-Type": "application/json" });
  response.end(JSON.stringify({ error: "not found" }));
});

if (process.env.NODE_ENV !== "test") {
  server.listen(PORT, "0.0.0.0", () => {
    console.log(`API listening on port ${PORT}`);
  });
}

export default server;
