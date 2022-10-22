<template>
    <BlockBuilderBlock title="Static Text and Images">
        <template #icon>
            <IconText class="mr-2 w-6 h-6" />
        </template>

        <BlockBuilderTextAndImageEditable 
            :bricks="block.static_content"
        />

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
        console.log(`successfully saved static block`); 
        emit('save');
    });
}
</script>
