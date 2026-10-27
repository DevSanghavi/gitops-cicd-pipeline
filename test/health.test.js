import assert from "node:assert/strict";
import test from "node:test";
import { healthPayload } from "../src/server.js";

test("health payload reports healthy status and database", () => {
  const payload = healthPayload();
  assert.equal(payload.status, "ok");
  assert.equal(payload.environment, "development");
  assert.equal(payload.database, "ok");
});
