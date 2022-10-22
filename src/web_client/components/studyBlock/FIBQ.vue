<template>
    <BlockBuilderBlock>

    <div class="p-4">
        <h2>Question</h2>

        <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>
            <template v-for="field in answerFields">
                <input v-if="field.type == 'input'" v-model="field.text" class="inline underline border-b border-dashed border-gray-500 w-20" />
                <p v-else class="inline">{{field.text}}</p>
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

const SPLIT_TOKEN = "*$*";
const props = defineProps(['block']);
const block = ref(props.block);
const { testBlock } = useStudyBlockHelpers(block, emit);

// Split our text according to the special character we've defined
const fragments = block.value.fibq_question_text.split(/(\*\$\*)/);
// Create a structure so we can bind to the inputs.
const answerFields = ref(buildAnswerFields(fragments));

// Get only the text values from our inputs.
const currentAnswers = computed(() => {
    return answerFields.value
        .filter(field => field.type == "input")
        .map(field => field.text);
});

function buildAnswerFields(splitText) {
    return splitText.map(fragment => {
        if (fragment == SPLIT_TOKEN) {
            return {type: "input", text: ""}
        } else {
            return {type: "text", text: fragment}
        }
    })
}
</script>
