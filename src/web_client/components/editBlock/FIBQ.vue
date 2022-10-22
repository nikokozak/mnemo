<template>
    <BlockBuilderBlock title="Fill in the Blank Question">
        <template #icon>
            <IconImage class="mr-2 w-6 h-6" />
        </template>

        <div class="p-4">
            <h2>Question</h2>

            <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>

            <textarea v-model="block.fibq_question_text_template" class="w-full text-sm mt-4" placeholder="Anything in {curly} brackets will have to be guessed by the {student}."></textarea>
        </div>

        <template #controls>
            <EditBlockControls @leftClick="deleteBlock" @rightClick="saveBlock" />
        </template>
    </BlockBuilderBlock>
</template>

<script setup>
import { ref } from 'vue';
import BlockBuilderBlock from '@/components/blockBuilder/Block.vue';

const emit = defineEmits(['delete', 'save']);

const props = defineProps(['block']);
const block = ref(props.block);

function deleteBlock() {
    useDeleteBlock(block).then(response => {
        emit('delete', block.value.id);
    });
}

function saveBlock() {
    useSaveBlock(block).then(response => {
        emit('save');
    })
}
</script>
