function validateCurriculum(curriculum) {
    for (let lesson of curriculum) {
        if (!lesson.youtube_link && !lesson.fallback_search_query) {
            throw new Error("Invalid lesson: missing video and fallback");
        }
    }
}