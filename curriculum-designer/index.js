// index.js
const { runCurriculum } = require("./engine/orchestrator");

module.exports = async function runSkill({ sessionId, message, send }) {
    try {
        await send("🚀 Curriculum generation started...");

        const input = extractRequirementsFromMessage(message);

        const result = await runCurriculum(sessionId, input);

        await send("📚 Curriculum design complete.");
        await send(formatPreview(result));

        return result;
    } catch (err) {
        await send("❌ Error occurred: " + err.message);
        throw err;
    }
};