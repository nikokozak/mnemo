<template>
    <BlockBuilderBlock title="Multiple Choice Question">

        <template #icon>
            <IconMultipleChoice class="mr-2 w-6 h-6"/>
        </template>

        <div class="p-4">
            <h2>Question</h2>
            <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>

            <textarea v-model="block.mcq_question_text" class="w-full text-sm mt-4" placeholder="Your Question here."></textarea>
        </div>

    <hr>

        <div class="p-4">
            <h2>Answers</h2>

            <BlockBuilderMultipleChoiceEditable 
            :choices="block.mcq_answer_choices" 
            :correctAnswer="block.mcq_answer_correct"
            @add="updateMCQState"
            @select="updateMCQState"
            @remove="updateMCQState" />
        </div>

        <template #controls>
            <EditBlockControls @leftClick="deleteBlock(block)" @rightClick="saveBlock(block)" />
        </template>

    </BlockBuilderBlock>
</template>

<script setup>
import { ref } from 'vue';
import BlockBuilderBlock from '@/components/blockBuilder/Block.vue'

const emit = defineEmits(['delete', 'save']);

const props = defineProps(['block']);
const block = ref(props.block);

function updateMCQState({ choices, correctAnswer}) {
    block.value.mcq_answer_choices = choices;
    block.value.mcq_answer_correct = correctAnswer;
}

const { deleteBlock, saveBlock } = useEditBlockHelpers(emit);
</script>
