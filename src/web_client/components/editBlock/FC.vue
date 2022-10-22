<template>
    <BlockBuilderBlock title="Flash Card">
        <template #icon>
            <IconFlashCard class="mr-2 w-6 h-6" />
        </template>

        <div class="p-4">
            <h2>Front</h2>

            <BlockBuilderTextAndImageEditable 
                :bricks="block.fc_front_content" />
        </div>

        <div class="p-4">
            <h2>Back</h2>

            <BlockBuilderTextAndImageEditable 
                :bricks="block.fc_back_content" />
        </div>

        <template #controls>
            <EditBlockControls @leftClick="deleteBlock" @rightClick="saveBlock" />
        </template>
    </BlockBuilderBlock>
</template>

<script setup>
import { ref } from 'vue';
import BlockBuilderBlock from '@/components/blockBuilder/Block.vue'

const emit = defineEmits(['delete', 'save']);

const props = defineProps(['block']);
const block = ref(props.block);

function deleteBlock() {
    useDeleteBlock(block).then(response => {
        emit('delete', block.value.id);
    })
}

function saveBlock() {
    useSaveBlock(block).then(response => {
        console.log(`successfully saved fc`);
        emit('save');
    })
}
</script>
