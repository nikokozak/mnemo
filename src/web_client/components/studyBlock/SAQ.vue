<template>
    <BlockBuilderBlock>
        <div class="p-4">
            <h2>Question</h2>
            <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>
            <p>{{block.saq_question_text}}</p>
        </div>
        <hr>

        <div class="p-4">
            <h2>Your Answer</h2>
            <input v-model="currentAnswer"
                   placeholder="Type in your answer here."
                   class="pl-2 py-2 w-full rounded-lg border-b"
                   :class="{'border-red-500': testResult === false }" />
        </div>

        <BlockBuilderControlsSingle @click="testBlock(currentAnswer)">
            Check Answer & Continue
        </BlockBuilderControlsSingle>
    </BlockBuilderBlock>
</template>

<script setup>
import { ref } from 'vue';
import BlockBuilderBlock from '@/components/blockBuilder/Block.vue';

const emit = defineEmits(['consume']);

const props = defineProps(['block']);
const block = ref(props.block);
const currentAnswer = ref("");

const { testBlock, testResult } = useStudyBlockHelpers(block, emit);
</script>
