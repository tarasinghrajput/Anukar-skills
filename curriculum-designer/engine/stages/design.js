const { agentChat } = require("openclaw-api-wrapper"); // example

async function generateLessonFromLLM(context) {
    const prompt = `
You are a curriculum designer.

Generate one lesson in JSON format.

INPUT:
Topic: ${context.topic}
Validated Resource:
${JSON.stringify(context.resource)}

Requirements:
${context.requirements_summary}

Previous Lesson Summary:
${context.previous_summary || "None"}

Output JSON only.
`;

    const response = await agentChat({
        model: "anthropic/claude-opus-4-6",
        message: prompt,
        temperature: 0.3
    });

    return JSON.parse(response);
}