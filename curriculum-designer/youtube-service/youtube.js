// youtube.js
const { searchVideos } = require("./search");
const { validateVideo } = require("./validate");

async function getBestVideoForTopic(topic) {
    const queries = [
        `${topic} tutorial hindi beginners`,
        `${topic} for students hindi`,
        `${topic} tutorial english beginners`
    ];

    for (let query of queries) {
        const candidates = await searchVideos(query);

        for (let candidate of candidates) {
            const isValid = await validateVideo(candidate.videoId);

            if (isValid) {
                return {
                    topic,
                    video: {
                        title: candidate.title,
                        channel: candidate.channel,
                        url: `https://www.youtube.com/watch?v=${candidate.videoId}`,
                        videoId: candidate.videoId
                    }
                };
            }
        }
    }

    return {
        topic,
        fallback: {
            search_query: `${topic} tutorial hindi beginners`,
            reason: "No valid video found after retries"
        }
    };
}

module.exports = { getBestVideoForTopic };