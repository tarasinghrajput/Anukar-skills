// validate.js
const axios = require("axios");
require("dotenv").config();

const API_KEY = process.env.YOUTUBE_API_KEY;

function parseDuration(isoDuration) {
    const match = isoDuration.match(/PT(\d+M)?(\d+S)?/);
    const minutes = match[1] ? parseInt(match[1]) : 0;
    const seconds = match[2] ? parseInt(match[2]) : 0;
    return minutes * 60 + seconds;
}

async function validateVideo(videoId) {
    const url = "https://www.googleapis.com/youtube/v3/videos";

    const response = await axios.get(url, {
        params: {
            key: API_KEY,
            part: "snippet,contentDetails,status",
            id: videoId
        }
    });

    if (!response.data.items.length) return false;

    const video = response.data.items[0];

    const durationSeconds = parseDuration(video.contentDetails.duration);

    const isValid =
        video.status.embeddable === true &&
        video.status.privacyStatus === "public" &&
        durationSeconds >= 300 &&
        durationSeconds <= 600 &&
        video.snippet.liveBroadcastContent === "none";

    return isValid;
}

module.exports = { validateVideo };