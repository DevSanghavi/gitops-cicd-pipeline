import assert from "node:assert/strict";
import test from "node:test";
import { healthPayload } from "../src/server.js";

test("health payload reports healthy status", () => {
  const payload = healthPayload();
  assert.equal(payload.status, "ok");
  assert.equal(payload.environment, "development");
});
