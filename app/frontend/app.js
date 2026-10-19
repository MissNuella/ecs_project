// Presentation tier. All calls go to /api/*, which the ALB routes to the API service.
const list = document.getElementById("notes");
const statusEl = document.getElementById("status");

async function checkHealth() {
  try {
    const res = await fetch("/api/health");
    const body = await res.json();
    statusEl.textContent = `API: ${body.status}, database: ${body.db}`;
  } catch {
    statusEl.textContent = "API unreachable";
  }
}

async function load() {
  const res = await fetch("/api/notes");
  const notes = await res.json();
  list.innerHTML = "";
  for (const note of notes) {
    const li = document.createElement("li");
    li.textContent = note.text;
    const del = document.createElement("button");
    del.textContent = "Delete";
    del.onclick = async () => {
      await fetch(`/api/notes/${note.id}`, { method: "DELETE" });
      load();
    };
    li.appendChild(del);
    list.appendChild(li);
  }
}

document.getElementById("form").addEventListener("submit", async (e) => {
  e.preventDefault();
  const input = document.getElementById("text");
  await fetch("/api/notes", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text: input.value }),
  });
  input.value = "";
  load();
});

checkHealth();
load();
