import Database from "better-sqlite3";
import { readdirSync, readFileSync, mkdirSync } from "node:fs";
import path from "node:path";

const DB_PATH = process.env.DB_PATH || "./data/app.db";
const MIGRATIONS_DIR = "./migrations";

mkdirSync(path.dirname(DB_PATH), { recursive: true });
const database = new Database(DB_PATH);
database.pragma("journal_mode = WAL");

database.exec(`
  CREATE TABLE IF NOT EXISTS schema_migrations (
    name TEXT PRIMARY KEY,
    applied_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  );
`);

const applied = new Set(
  database.prepare("SELECT name FROM schema_migrations").all().map((row) => row.name)
);
const files = readdirSync(MIGRATIONS_DIR).filter((file) => file.endsWith(".sql")).sort();

for (const file of files) {
  if (applied.has(file)) continue;
  const apply = database.transaction(() => {
    database.exec(readFileSync(path.join(MIGRATIONS_DIR, file), "utf8"));
    database.prepare("INSERT INTO schema_migrations (name) VALUES (?)").run(file);
  });
  apply();
  console.log(`Applied migration: ${file}`);
}

console.log(`PASS: database migrations complete at ${DB_PATH}`);
database.close();
