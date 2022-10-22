<template>
    <BlockBuilderBlock title="Single Answer Question">
        <template #icon>
            <IconFlashCard class="mr-2 w-4 h-4" />
        </template>

        <div class="p-4">
            <h2>Question</h2>

            <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>

            <textarea v-model="block.saq_question_text" class="w-full text-sm mt-4" placeholder="Your Question here."></textarea>
        </div>
        <hr>

        <BlockBuilderPossibleAnswersEditable :choices="block.saq_answer_choices" />

        <template #controls>
            <EditBlockControls @leftClick="deleteBlock" @rightClick="saveBlock" />
        </template>
    </BlockBuilderBlock>
</template>

<script setup>
import { ref } from 'vue';
import BlockBuilderBlock from '@/components/blockBuilder/Block.vue';

const emit = defineEmits(['delete', 'save']);
const config = useRuntimeConfig();

const props = defineProps(['block']);
const block = ref(props.block);

function deleteBlock() {
    useDeleteBlock(block).then(response => {
        emit('delete', block.value.id);
    })
}

function saveBlock() {
    useSaveBlock(block).then(response => {
        emit('save');
    })
}
</script>
