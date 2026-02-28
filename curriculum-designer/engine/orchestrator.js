const { loadStage, saveStage } = require("./state");
const { runResearchStage } = require("./stages/research");
const { runDesignStage } = require("./stages/design");

async function runCurriculum(sessionId, input, send) {
    console.log("🚀 Starting curriculum pipeline");

    let requirements = loadStage(sessionId, "requirements");
    if (!requirements) {
        requirements = input;
        saveStage(sessionId, "requirements", requirements);
        console.log("✅ Requirements saved");
        await send("📝 Saving requirements...");
    }

    let resources = loadStage(sessionId, "validated-resources");
    if (!resources) {
        console.log("🔍 Running research stage...");
        resources = await runResearchStage(requirements);
        saveStage(sessionId, "validated-resources", resources);
        console.log("✅ Research complete");
        await send("🔍 Researching videos...");
    }

    let curriculum = loadStage(sessionId, "curriculum");
    if (!curriculum) {
        console.log("📚 Running design stage...");
        curriculum = await runDesignStage(requirements, resources);
        saveStage(sessionId, "curriculum", curriculum);
        console.log("✅ Curriculum generated");
        await send("📚 Designing lessons...");
    }

    console.log("🎉 Pipeline complete");
    await send("📊 Creating sheet...");
    return curriculum;
}

module.exports = { runCurriculum };