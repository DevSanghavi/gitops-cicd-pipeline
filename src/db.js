import Database from "better-sqlite3";
import { mkdirSync } from "node:fs";
import path from "node:path";

const DB_PATH = process.env.DB_PATH || "./data/app.db";
mkdirSync(path.dirname(DB_PATH), { recursive: true });

export const database = new Database(DB_PATH);
database.pragma("journal_mode = WAL");

export function recordRelease(imageDigest, environment) {
  database.prepare(
    "INSERT OR IGNORE INTO releases (image_digest, environment) VALUES (?, ?)"
  ).run(imageDigest, environment);
}

export function databaseHealth() {
  const result = database.prepare("SELECT COUNT(*) AS count FROM releases").get();
  return result.count >= 0 ? "ok" : "error";
}
