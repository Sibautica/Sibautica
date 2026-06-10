import fs from "fs";
import path from "path";
import { exec } from "child_process";
import https from "https";
import http from "http";
import url from "url";
const __filename = url.fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const BASE_DIR = path.join(__dirname, ".."); // Zakładam, że BASE_DIR to katalog nadrzędny względem "other"

// Wczytaj JSON
const raw = fs.readFileSync(path.join(__dirname, "download.json"), "utf8");
const items = JSON.parse(raw);

// Pobieranie pliku
function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    const proto = url.startsWith("https") ? https : http;

    const file = fs.createWriteStream(dest);
    proto.get(url, res => {
      if (res.statusCode !== 200) {
        reject(new Error("HTTP " + res.statusCode));
        return;
      }

      res.pipe(file);
      file.on("finish", () => file.close(resolve));
    }).on("error", reject);
  });
}

// Uruchamianie komendy (bash/cmd) z cwd = BASE_DIR
function runCommand(cmd) {
  return new Promise((resolve, reject) => {
    exec(cmd, { shell: true, cwd: BASE_DIR }, (err, stdout, stderr) => {
      if (err) reject(err);
      else resolve({ stdout, stderr });
    });
  });
}

(async () => {
  for (const item of items) {
    const url = item.url;
    const outPath = path.resolve(BASE_DIR, item.to);
    const post = item.postdownload;

    // Tworzenie folderów
    fs.mkdirSync(path.dirname(outPath), { recursive: true });

    console.log("Pobieram:", url);
    await downloadFile(url, outPath);
    console.log("Zapisano do:", outPath);

    // Wykonaj postdownload TYLKO jeśli istnieje i nie jest pusty
    if (post && typeof post === "string" && post.trim() !== "") {
      console.log("Wykonuję postdownload:", post);
      await runCommand(post);
    } else {
      console.log("Brak postdownload — pomijam");
    }

    console.log("OK\n");
  }
})();
