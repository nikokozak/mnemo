<template>
<div class="border rounded-lg mt-2 mb-4">

    <!-- Inner Question -->
    <div class="p-4">
        <h2>Question</h2>

        <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>

        <p>{{block.mcq_question_text}}</p>
    </div>
    <!-- End Inner Question -->
    <hr>
    <!-- Inner Answers -->
    <div class="p-4">
        <h2>Answers</h2>
        <p class="text-xs text-gray-400">pick one!</p>

        <template v-for="(choice, index) in block.mcq_answer_choices">
            <div @click="currentAnswer = choice.key" :class="[currentAnswer == choice.key ? 'border-blue-400' : '']" class="flex justify-between border rounded-lg text-xs mt-4 mr-4">
                <div class="w-8 pl-3 border-r">
                    <p class="pr-2 py-2">{{ choice.key }}</p>
                </div>
                <p class="px-4 py-2">{{ choice.text }}</p>
            </div>
        </template>
    </div>
    <!-- End Inner Answers -->

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
const emit = defineEmits(['consume']);

const props = defineProps(['block']);
const block = ref(props.block);
let currentAnswer = ref(null);
let answers = [];

function testBlock() {
    if (currentAnswer.value != null) {
        useTestBlock(block, currentAnswer.value).then(isCorrect => {
            if (isCorrect) {
                answers.push({answer: currentAnswer.value, correct: true})
                emit('consume', answers)
            } else {
                answers.push({answer: currentAnswer.value, correct: false})
            }
        })
    }
}
</script>
