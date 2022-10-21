import { unref } from 'vue';

const MAX_ATTEMPTS = 3;

export function useStudyBlockHelpers(block, emitter) {

    const answerStore = [];

    const testBlock = (answers = null) => {
        answers = unref(answers);        
        block = unref(block);

        return useTestBlock(block, answers).then(isCorrect => {
            logStatus(block, isCorrect);
            addAnswerStateToStore(answers, isCorrect, answerStore); 
            maybeConsumeBlock(isCorrect, answerStore, answers, emitter);

            return isCorrect;
        })
    }

    return {
        testBlock
    }
}

function addAnswerStateToStore(answer, isCorrect, answerStore) {
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
