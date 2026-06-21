import fs from "fs";
import path from "path";
import { exec } from "child_process";
import https from "https";
import http from "http";
import url from "url";
import unzipper from "unzipper";
import fsExtra from "fs-extra";

const __filename = url.fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const BASE_DIR = path.join(__dirname, "..", "..");

// Wczytaj JSON
const raw = fs.readFileSync(path.join(__dirname, "download.json"), "utf8");
const items = JSON.parse(raw);

// Pobieranie pliku z obsługą redirectów
function downloadFile(fileUrl, dest, redirectCount = 0) {
  return new Promise((resolve, reject) => {
    if (redirectCount > 10) {
      reject(new Error("Too many redirects"));
      return;
    }

    const proto = fileUrl.startsWith("https") ? https : http;

    proto.get(fileUrl, res => {
      if ([301, 302, 303, 307, 308].includes(res.statusCode)) {
        const newUrl = res.headers.location;
        console.log("Redirect:", res.statusCode, "→", newUrl);
        return resolve(downloadFile(newUrl, dest, redirectCount + 1));
      }

      if (res.statusCode !== 200) {
        reject(new Error("HTTP " + res.statusCode));
        return;
      }

      const file = fs.createWriteStream(dest);
      res.pipe(file);
      file.on("finish", () => file.close(resolve));
    }).on("error", reject);
  });
}

// Uruchamianie komendy
function run(cmd) {
  return new Promise((resolve, reject) => {
    exec(cmd, { cwd: BASE_DIR }, (err, stdout, stderr) => {
      if (err) reject(err);
      else resolve({ stdout, stderr });
    });
  });
}

(async () => {


  //
  // 1. Pobieranie i instalacja WezTerm
  //
  for (const item of items) {
    const fileUrl = item.url;
    const outPath = path.resolve(BASE_DIR, item.to);

    fs.mkdirSync(path.dirname(outPath), { recursive: true });

    console.log("Pobieram:", fileUrl);
    await downloadFile(fileUrl, outPath);
    console.log("Zapisano do:", outPath);

    // 1. Rozpakuj ZIP w Node.js
    await fs.createReadStream(outPath)
      .pipe(unzipper.Extract({ path: path.join(BASE_DIR, "dist/terminal") }))
      .promise();

    // 2. Usuń ZIP
    fs.unlinkSync(outPath);

    // 3. Znajdź folder WezTerm-*
    const termDir = path.join(BASE_DIR, "dist", "terminal");
    const subdirs = fs.readdirSync(termDir).filter(f => f.startsWith("WezTerm-"));

    if (subdirs.length === 0) {
      throw new Error("Nie znaleziono folderu WezTerm-*");
    }

    const wezFolder = path.join(termDir, subdirs[0]);

    // 4. Kopiuj pliki (rename NIE działa na Windows z DLL)
    for (const file of fs.readdirSync(wezFolder)) {
      await fsExtra.copy(
        path.join(wezFolder, file),
        path.join(termDir, file),
        { overwrite: true }
      );
    }

    // 5. Usuń folder WezTerm-*
    fs.rmSync(wezFolder, { recursive: true, force: true });
  }

  //
  // 2. Budowanie projektu
  //
  console.log("Instaluję zależności...");
  await run("npm i");

  console.log("Kompiluję TypeScript...");
  await run("npx tsc");

})();
