const { getBestVideoForTopic } = require("../../youtube-service/youtube");

async function runResearchStage(requirements) {
    const topics = requirements.subject_areas;

    const results = [];

    for (let topic of topics) {
        const resource = await getBestVideoForTopic(topic);
        results.push(resource);
    }

    return results;
}

module.exports = { runResearchStage };