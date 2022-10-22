<template>
    <BlockBuilderBlock>
        <div class="p-4">
            <h2>Question</h2>
            <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>
            <p>{{block.mcq_question_text}}</p>
        </div>
        <hr>

        <BlockBuilderMultipleChoice 
         :choices="block.mcq_answer_choices"
            @select="(choiceKey) => selected = choiceKey"/>

        <BlockBuilderControlsSingle @click="testBlock(selected)">
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
let selected = ref("");

const { testBlock } = useStudyBlockHelpers(block, emit);
</script>
