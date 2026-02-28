// search.js
const axios = require("axios");
require("dotenv").config();

const API_KEY = process.env.YOUTUBE_API_KEY;

async function searchVideos(query) {
    const url = "https://www.googleapis.com/youtube/v3/search";

    const response = await axios.get(url, {
        params: {
            key: API_KEY,
            part: "snippet",
            q: query,
            type: "video",
            maxResults: 5,
            videoDuration: "medium",
            relevanceLanguage: "hi"
        }
    });

    return response.data.items.map(item => ({
        videoId: item.id.videoId,
        title: item.snippet.title,
        channel: item.snippet.channelTitle
    }));
}

module.exports = { searchVideos };