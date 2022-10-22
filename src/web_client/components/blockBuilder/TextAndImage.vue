<template>
    <div>
        <template v-for="brick in bricks">
            <div v-if="brick.type == 'text'" class="ml-5 mr-4 mb-4">
                <input 
                    v-if="editable"
                    v-model="brick.content" 
                    placeholder="Some text you feel is important." 
                    class="text-xs w-full" />
                <p 
                    v-else
                    class="text-sm">
                    {{ brick.content }}
                </p>
            </div>
            <div v-else>
                <div 
                    class="block w-4/5 h-20 border border-dashed rounded-lg ml-5 mr-4 mb-4">
                </div>
            </div>
        </template>

        <!-- End Inner Block Content -->

        <!-- Inner Block Controls -->
        <template v-if="editable">
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
        </template>
        <!-- End Inner Block Controls -->
    </div>
</template>

<script setup>
import { ref } from 'vue';
const emit = defineEmits(['add'])
// We call the objects stored in static content arrays "bricks".
const props = defineProps(['bricks', 'editable']);
const bricks = ref(props.bricks);

function addImage() {
    bricks.value.push(newImage());
    emit('add', unref(bricks));
}

function addText() {
    bricks.value.push(newText());
    emit('add', unref(bricks));
}

function newImage() { return { type: "image", content: "" } }
function newText() { return { type: "text", content: ""} }
</script>
