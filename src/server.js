import http from "node:http";
import { databaseHealth, recordRelease } from "./db.js";

const PORT = Number(process.env.PORT || 3000);
const APP_ENV = process.env.APP_ENV || "development";
const IMAGE_DIGEST = process.env.IMAGE_DIGEST || "local-development";

recordRelease(IMAGE_DIGEST, APP_ENV);

export function healthPayload() {
  return {
    status: "ok",
    environment: APP_ENV,
    database: databaseHealth(),
    image_digest: IMAGE_DIGEST
  };
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
