<template>
    <BlockBuilderBlock>

    <div class="p-4">
        <h2>Question</h2>

        <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>
            <template v-for="field in questionStructure">
                <input v-if="field.type == 'input'"
                       v-model="field.value"
                       class="inline underline border-b border-dashed border-grey-500 w-20"
                       :class="
                       {'border-red-500': answerStatus[field.input_idx] == false,
                           'border-green-500': answerStatus[field.input_idx] == true}"/>

                <p v-else class="inline">{{field.value}}</p>
            </template>
        </div>

        <BlockBuilderControlsSingle @click="testBlock(currentAnswers)">
            Check Answer and Continue
        </BlockBuilderControlsSingle>
    </BlockBuilderBlock>
</template>

<script setup>
import { ref } from 'vue';
import BlockBuilderBlock from '@/components/blockBuilder/Block.vue';

const emit = defineEmits(['consume']);

const props = defineProps(['block']);
const block = ref(props.block);
const { testBlock, testResult } = useStudyBlockHelpers(block, emit);

const questionStructure = ref(block.value.fibq_question_structure);

// Build a map that holds the input idxs and the result of each correction.
const answerStatus = computed(() => {
     const answerResultStruct = {};
     if (testResult.value) {
        testResult.value.forEach(el => answerResultStruct[el.input_idx] = el.correct)
     }
     return answerResultStruct;
 })

// Get only the input values
const currentAnswers = computed(() => {
    return questionStructure.value
        .filter(field => field.type == "input")
});
</script>
