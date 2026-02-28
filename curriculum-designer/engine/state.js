const fs = require("fs");
const path = require("path");

const BASE_DIR = "./sessions";

function getSessionDir(sessionId) {
    const dir = path.join(BASE_DIR, sessionId);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    return dir;
}

function saveStage(sessionId, stageName, data) {
    const dir = getSessionDir(sessionId);
    fs.writeFileSync(
        path.join(dir, `${stageName}.json`),
        JSON.stringify(data, null, 2)
    );
}

function loadStage(sessionId, stageName) {
    const file = path.join(getSessionDir(sessionId), `${stageName}.json`);
    if (!fs.existsSync(file)) return null;
    return JSON.parse(fs.readFileSync(file));
}

module.exports = { saveStage, loadStage };