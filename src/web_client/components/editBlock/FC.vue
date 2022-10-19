<template>
<div class="border rounded-lg mt-2 mb-4">
    <!-- Block Type Title -->
    <div class="flex m-4 text-md">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="mr-2 w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25H12" />
        </svg>
        <h1>Flash Card</h1>
    </div>
    <hr>
    <!-- End Block Type Title -->

    <!-- Front Content -->
    <div class="p-4">
        <h2>Front</h2>

        <template v-for="brick in block.fc_front_content">
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

        <!-- Inner Block Controls -->
        <div class="mt-4 flex justify-around">
            <button @click="addFrontText" class="flex text-xs border rounded-lg py-2 px-4">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25H12" />
                </svg>
                <p>Add Front Text</p>
            </button>
            <button @click="addFrontImage" class="flex text-xs border rounded-lg py-2 px-4">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 001.5-1.5V6a1.5 1.5 0 00-1.5-1.5H3.75A1.5 1.5 0 002.25 6v12a1.5 1.5 0 001.5 1.5zm10.5-11.25h.008v.008h-.008V8.25zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z" />
                </svg>
                <p>Add Front Image</p>
            </button>
        </div>
        <!-- End Inner Block Controls -->
    </div>
    <!-- End Front Content -->


    <!-- Back Content -->
    <div class="p-4">
        <h2>Back</h2>

        <template v-for="brick in block.fc_back_content">
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

        <!-- Inner Block Controls -->
        <div class="mt-4 flex justify-around">
            <button @click="addBackText" class="flex text-xs border rounded-lg py-2 px-4">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25H12" />
                </svg>
                <p>Add Back Text</p>
            </button>
            <button @click="addBackImage" class="flex text-xs border rounded-lg py-2 px-4">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 001.5-1.5V6a1.5 1.5 0 00-1.5-1.5H3.75A1.5 1.5 0 002.25 6v12a1.5 1.5 0 001.5 1.5zm10.5-11.25h.008v.008h-.008V8.25zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z" />
                </svg>
                <p>Add Back Image</p>
            </button>
        </div>
    </div>
    <!-- End Inner Block Controls -->
    <!-- End Back Content -->

    <!-- Block Controls -->
    <div class="flex justify-between text-xs border-t mt-4"> 
        <template v-if="editing"> 
            <div @click="deleteBlock" class="border-r w-1/2 flex pl-6 py-2">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mr-2">
                    <path fill-rule="evenodd" d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.52.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5zM10 4c.84 0 1.673.025 2.5.075V3.75c0-.69-.56-1.25-1.25-1.25h-2.5c-.69 0-1.25.56-1.25 1.25v.325C8.327 4.025 9.16 4 10 4zM8.58 7.72a.75.75 0 00-1.5.06l.3 7.5a.75.75 0 101.5-.06l-.3-7.5zm4.34.06a.75.75 0 10-1.5-.06l-.3 7.5a.75.75 0 101.5.06l.3-7.5z" clip-rule="evenodd" />
                </svg>
                Delete Block
            </div>
            <div @click="saveBlock" class="w-1/2 flex pl-6 py-2">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mr-2">
                    <path fill-rule="evenodd" d="M4.5 2A1.5 1.5 0 003 3.5v13A1.5 1.5 0 004.5 18h11a1.5 1.5 0 001.5-1.5V7.621a1.5 1.5 0 00-.44-1.06l-4.12-4.122A1.5 1.5 0 0011.378 2H4.5zM10 8a.75.75 0 01.75.75v1.5h1.5a.75.75 0 010 1.5h-1.5v1.5a.75.75 0 01-1.5 0v-1.5h-1.5a.75.75 0 010-1.5h1.5v-1.5A.75.75 0 0110 8z" clip-rule="evenodd" />
                </svg>
                Save Block
            </div>
        </template>
        <template v-else>
            <div @click="editBlock" class="border-r w-1/2 flex pl-6 py-2">
                Edit Block
            </div>
            <div @click="toggleTestable" class="border-r w-1/2 pl-6 py-2">Testable? {{ block.testable }}</div>
        </template>
    </div>
    <!-- End Block Controls -->
</div>
</template>

<script setup>
import { ref } from 'vue';

const emit = defineEmits(['delete', 'save']);
const config = useRuntimeConfig();

const props = defineProps(['block']);
const block = ref(props.block);

const editing = ref(true);


function addFrontImage() {
    block.value.fc_front_content.push({
        type: "image",
        content: "",
    })
}

function addFrontText() {
    block.value.fc_front_content.push({
        type: "text",
        content: "",
    })
}

function addBackImage() {
    block.value.fc_back_content.push({
        type: "image",
        content: "",
    })
}

function addBackText() {
    block.value.fc_back_content.push({
        type: "text",
        content: "",
    })
}

function deleteBlock() {
    $fetch(`${config.public.baseURL}/api/content_block/${block.value.id}`, {
        method: 'DELETE'
    }).then(response => {
        emit('delete');
    })
}

function saveBlock() {
    $fetch(`${config.public.baseURL}/api/content_block/${block.value.id}`, {
        method: 'PUT',
        body: { content_block: block.value }
    }).then(response => {
        console.log(`correctly saved content block ${block.value.id}`);
        emit('save');
    })
    editing.value = false;
}

function editBlock() {
    editing.value = true;
}

function toggleTestable() {
    block.value.testable = !block.value.testable;
}
</script>
