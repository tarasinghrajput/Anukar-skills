// index.js
const { getBestVideoForTopic } = require("./youtube");

(async () => {
    const topics = [
        "computer basics",
        "advanced excel formulas",
        "gmail tutorial"
    ];

    for (let topic of topics) {
        const result = await getBestVideoForTopic(topic);
        console.log(JSON.stringify(result, null, 2));
    }
})();