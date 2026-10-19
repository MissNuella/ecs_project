// API tier: a small notes API backed by PostgreSQL (Amazon RDS in AWS).
// DB settings come from environment variables. On ECS, DB_PASSWORD is
// injected from SSM Parameter Store, which Terraform fills from Vault.
const express = require("express");
const { Pool } = require("pg");

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || "localhost",
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || "notes",
  user: process.env.DB_USER || "notes",
  password: process.env.DB_PASSWORD,
  ssl: process.env.DB_SSL === "true" ? { rejectUnauthorized: false } : false,
});

async function init() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS notes (
      id SERIAL PRIMARY KEY,
      text VARCHAR(500) NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now()
    )`);
}

// The ALB health check hits this path.
app.get("/api/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ status: "ok", db: "connected" });
  } catch (err) {
    res.status(503).json({ status: "error", db: err.message });
  }
});

app.get("/api/notes", async (_req, res) => {
  const { rows } = await pool.query("SELECT * FROM notes ORDER BY id DESC LIMIT 50");
  res.json(rows);
});

app.post("/api/notes", async (req, res) => {
  const text = (req.body.text || "").trim();
  if (!text) return res.status(400).json({ error: "text is required" });
  const { rows } = await pool.query("INSERT INTO notes (text) VALUES ($1) RETURNING *", [text]);
  res.status(201).json(rows[0]);
});

app.delete("/api/notes/:id", async (req, res) => {
  await pool.query("DELETE FROM notes WHERE id = $1", [req.params.id]);
  res.status(204).end();
});

const port = Number(process.env.PORT || 3000);
init()
  .then(() => app.listen(port, () => console.log(`API listening on ${port}`)))
  .catch((err) => {
    console.error("Failed to initialise database", err);
    process.exit(1);
  });
