<template>
<div class="border rounded-lg mt-2 mb-4">

    <!-- Inner Question -->
    <div class="p-4">
        <h2>Question</h2>

        <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>

        <template v-for="fragment in answerFields">
            <input v-if="fragment.type == 'input'" v-model="fragment.text" class="inline underline border-b border-dashed border-gray-500 w-20" />
            <p v-else class="inline">{{fragment.text}}</p>
        </template>
    </div>
    <!-- End Inner Question -->

    <!-- Block Controls -->
    <div class="flex text-xs border-t mt-4 py-2 justify-center"> 
        <div @click="testBlock" class="flex">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 5.25l-7.5 7.5-7.5-7.5m15 6l-7.5 7.5-7.5-7.5" />
            </svg>
            Check Answer & Continue
        </div>
    </div>
    <!-- End Block Controls -->
</div>
</template>

<script setup>
import { ref } from 'vue';

const emit = defineEmits(['delete', 'save']);
const config = useRuntimeConfig();

const props = defineProps(['block']);
const block = ref(props.block);

// Split our text according to the special character we've defined
// as a placeholder
const fragments = block.value?.fibq_question_text?.split(/(\*\$\*)/);

// Create a structure so we can bind to the inputs.
const answerFields = ref(fragments.map(e => {
    if (e == "*$*") {
        return {type: "input", text: null}
    } else {
        return {type: "text", text: e}
    }
}));

const currentAnswers = computed(() => {
    return answerFields.value.filter(e => e.type == "input").map(e => e.text);
});
// Store previous answers here.
const answers = [];

function testBlock() {
    useTestBlock(block, currentAnswers).then(isCorrect => {
        if (isCorrect) {
            answers.push({answer: currentAnswers.value, correct: true})
            emit('consume', answers)
        } else {
            answers.push({answer: currentAnswers.value, correct: false})
        }
    })
}

</script>
