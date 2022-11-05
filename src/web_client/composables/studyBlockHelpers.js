import { ref, unref } from 'vue';

const MAX_ATTEMPTS = 3;

export function useStudyBlockHelpers(block, emitter) {

    const answerStore = [];
    let testResult = ref(null);

    const testBlock = (answer = null) => {
        answer = unref(answer);        
        block = unref(block);

        return useTestBlock(block, answer).then(testResp => {
            const { blockCorrect, results } = testResp;
            logStatus(block, blockCorrect);
            testResult.value = results;
            addTestResultToStore(answer, results, answerStore);
            maybeConsumeBlock(blockCorrect, answerStore, answer, emitter);

            return blockCorrect;
        })
    }

    return {
        testBlock,
        testResult
    }
}

function addTestResultToStore(answer, isCorrect, answerStore) {
    answerStore.push({answer, correct: isCorrect});
}

function logStatus(block, isCorrect) {
    console.log(`The answer to block ${block.id} was ${isCorrect ? "correct" : "incorrect" }`);
}

function maybeConsumeBlock(isCorrect, answerStore, answers, emitter) {
    if (isCorrect || answerStore.length >= MAX_ATTEMPTS) {
        emitter('consume', {answers, correct: isCorrect});
    }
}
