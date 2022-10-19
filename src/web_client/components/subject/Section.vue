<template>
    <div class="mt-4">
        <!-- Section Title -->
        <div class="flex justify-between">
            <input type="text" @input="handleInput" v-model="section.title" class="text-md text-semibold underline underline-offset-6 border-0 p-0 mb-4" placeholder="Optional Section Title" />
            <svg @click="deleteSection" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width={1.5} stroke="currentColor" class="gray-400 w-4 h-4 mt-1">
                <path strokeLinecap="round" strokeLinejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
            </svg>
        </div>
        <!-- End Section Title -->

        <template v-for="block in blocks">
            <component :is="getComponentFromType(block.type)"
                :block="block"
                @delete="refresh" />
        </template>

        <button @click="showCreateBlockModal = true" class="px-4 py-2 border rounded-lg text-sm">Create Content Block</button>
    </div>

    <!-- Create Content Block Modal -->
    <Teleport to="body">
        <Modal :show="showCreateBlockModal">
            <template #header>
                Create Content Block
            </template>
            <template #body>
                <p class="text-xs text-gray-600">Select a Content Block type.</p>
                <div class="flex flex-wrap mt-4">
                    <!-- Static Content Block -->
                    <div @click="createStaticBlock" class="p-2 border rounded-lg mr-2 mt-2">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25H12" />
                        </svg>
                        <p class="text-xs text-gray-600">Static Text<br>& Images</p>
                    </div>
                    <!-- Multiple Choice Question Block -->
                    <div @click="createMCQBlock" class="p-2 border rounded-lg mr-2 mt-2">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zM3.75 12h.007v.008H3.75V12zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm-.375 5.25h.007v.008H3.75v-.008zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z" />
                        </svg>
                        <p class="text-xs text-gray-600">Multiple-Choice<br>Question</p>
                    </div>
                    <!-- Single Answer Question Block -->
                    <div @click="createSAQBlock" class="p-2 border rounded-lg mr-2 mt-2">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z" />
                        </svg>
                        <p class="text-xs text-gray-600">Single-Answer<br>Question</p>
                    </div>
                    <!-- FlashCard Block -->
                    <div @click="createFCBlock" class="p-2 border rounded-lg mr-2 mt-2">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z" />
                        </svg>
                        <p class="text-xs text-gray-600">Flash-Card</p>
                    </div>
                    <!-- Fill In the Blank Block -->
                    <div @click="createFIBQBlock" class="p-2 border rounded-lg mr-2 mt-2">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 01-.825-.242m9.345-8.334a2.126 2.126 0 00-.476-.095 48.64 48.64 0 00-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0011.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155" />
                        </svg>
                        <p class="text-xs text-gray-600">Fill In the Blank<br>Question</p>
                    </div>
                </div>
            </template>
            <template #footer>
                <div class="flex w-full justify-between">
                    <button @click="showCreateBlockModal = false"
                        class="px-4 py-2 border rounded-lg border-blue">Cancel</button>
                </div>
            </template>
        </Modal>
    </Teleport>
    <!-- End Create Content Block -->

</template>

<script setup>
// We need to import the components given the use of "is"
import EditBlockStatic from '@/components/editBlock/Static.vue'
import EditBlockMCQ from '@/components/editBlock/MCQ.vue'
import EditBlockSAQ from '@/components/editBlock/SAQ.vue'
import EditBlockFC from '@/components/editBlock/FC.vue'
import EditBlockFIBQ from '@/components/editBlock/FIBQ.vue'

import { ref } from 'vue';
import { debounce } from 'lodash';

const props = defineProps(['section']);
const emit = defineEmits(['delete']);

const section = ref(props.section);
const updating = ref(false);
const showCreateBlockModal = ref(false);
const blocks = ref(props.section.blocks);

function getComponentFromType(type) {
    switch (type) {
        case "static": 
            return EditBlockStatic;
        case "mcq":
            return EditBlockMCQ;
        case "saq":
            return EditBlockSAQ;
        case "fc":
            return EditBlockFC;
        case "fib":
            return EditBlockFIBQ;
    }
}

function createMCQBlock() {
    createBlock("mcq");
}

function createStaticBlock() {
    createBlock("static");
}

function createSAQBlock() {
    createBlock("saq");
}

function createFCBlock() {
    createBlock("fc");
}

function createFIBQBlock() {
    createBlock("fibq");
}

function createBlock(type) {
    showCreateBlockModal.value = false;
    useSimpleFetch(`/api/content_block`, {
        method: 'POST',
        body: { section_id: section.value.id, type }
    }).then(response => {
        blocks.value.push(response);
    })
}

function deleteSection() {
    useSimpleFetch(`/api/section/${section.value.id}`, {
        method: 'DELETE'
    }).then(response => {
        emit('delete', section.id);
    })
}

// Saves the section on title input
const handleInput = debounce(() => {
    console.log(section.value);
    useSimpleFetch(`/api/section/`, {
        method: 'PUT',
        body: { section: section.value }
    }).then(response => {
        console.log(`successfully updated ${section.value.id}`);
    })
}, 500)
</script>
