<template>
    <BlockBuilderBlock title="Multiple Choice Question">
    <template #icon>
        <IconMultipleChoice class="mr-2 w-6 h-6"/>
    </template>

    <!-- Inner Question -->
    <div class="p-4">
        <h2>Question</h2>
        <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>

        <textarea v-model="block.mcq_question_text" class="w-full text-sm mt-4" placeholder="Your Question here."></textarea>
    </div>
    <!-- End Inner Question -->

    <hr>

    <!-- Inner Answers -->
    <div class="p-4">
        <h2>Answers</h2>

        <BlockBuilderMultipleChoiceEditable 
        :choices="block.mcq_answer_choices" 
        :correctAnswer="block.mcq_answer_correct"
        @add="updateMCQState"
        @select="updateMCQState"
        @remove="updateMCQState" />
    </div>
    <!-- End Inner Question -->

    <!-- Block Controls -->
    <template #controls>
        <EditBlockControls @leftClick="deleteBlock" @rightClick="saveBlock" />
    </template>
    <!-- End Block Controls -->
    </BlockBuilderBlock>
    {{block}}
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

function deleteBlock() {
    useSimpleFetch(`/api/blocks/${block.value.id}`, {
        method: 'DELETE'
    }).then(response => {
        emit('delete', block.value.id);
    })
}

function saveBlock() {
    useSimpleFetch(`/api/blocks/${block.value.id}`, {
        method: 'PATCH',
        body: block.value
    }).then(response => {
        console.log(`correctly saved content block ${block.value.id}`);
        emit('save');
    })
}
</script>
