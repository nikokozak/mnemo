<template>
    <BlockBuilderBlock title="Static Text and Images">
    <template #icon>
        <IconText class="mr-2 w-6 h-6" />
    </template>
    <!-- Inner Block Content -->
    <div>
        <template v-for="brick in block.static_content">
            <div v-if="brick.type == 'text'" class="ml-5 mr-4 mb-4">
                <input 
                    v-model="brick.content" 
                    placeholder="Some text you feel is important." 
                    class="text-xs w-full" />
            </div>
            <div v-else>
                <div 
                    class="block w-4/5 h-20 border border-dashed rounded-lg ml-5 mr-4 mb-4">
                </div>
            </div>
        </template>

        <!-- End Inner Block Content -->

        <!-- Inner Block Controls -->
        <div class="flex justify-around mt-4">
            <MiscButton @click="addText">
            <IconText class="w-4 h-4 mr-2" />
            <p>Add Text</p>
            </MiscButton>
            <MiscButton @click="addImage">
            <IconImage class="w-4 h-4 mr-2" />
            <p>Add Image</p>
            </MiscButton>
        </div>
        <!-- End Inner Block Controls -->

        <BlockBuilderControlsDouble 
            leftText="Delete Block" 
            rightText="Save Block"
            @leftClick="deleteBlock"
            @rightClick="saveBlock"
            >
            <template #leftIcon>
                <IconTrash class="w-4 h-4 mr-2" />
            </template>
            <template #rightIcon>
                <IconSave class="w-4 h-4 mr-2" />
            </template>
        </BlockBuilderControlsDouble>
    </div>
    </BlockBuilderBlock>
</template>

<script setup>
import { ref } from 'vue';
import IconText from '@/components/icon/Text.vue'
import IconSave from '@/components/icon/Save.vue'
import IconTrash from '@/components/icon/Trash.vue'
import IconImage from '@/components/icon/Image.vue'
import BlockBuilderBlock from '@/components/blockBuilder/Block.vue'
import MiscButton from '@/components/misc/Button.vue'
import BlockBuilderControlsDouble from '@/components/blockBuilder/ControlsDouble.vue'

const emit = defineEmits(['delete', 'save']);
const props = defineProps(['block']);

const block = ref(props.block);
const editing = ref(true);

function addImage() {
    block.value.static_content.push({
        type: "image",
        content: "",
    })
}

function addText() {
    block.value.static_content.push({
        type: "text",
        content: "",
    })
}

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

function editBlock() {
    editing.value = true;
}

function toggleTestable() {
    block.value.testable = !block.value.testable;
}
</script>
