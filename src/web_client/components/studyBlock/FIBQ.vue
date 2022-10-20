<template>
<div class="border rounded-lg mt-2 mb-4">

    <!-- Inner Question -->
    <div class="p-4">
        <h2>Question</h2>

        <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>

        <template v-for="fragment in question">
            <p>{{fragment}}</p>
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
{{block}}
</template>

<script setup>
import { ref } from 'vue';

const emit = defineEmits(['delete', 'save']);
const config = useRuntimeConfig();

const props = defineProps(['block']);
const block = ref(props.block);

const question = computed(() => {
    return block.value?.fibq_question_text?.split(/\{\{.*?\}\}/);
})

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
