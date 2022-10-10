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

        <template v-for="contentBlock in contentBlocks">
            <component :is="getComponentFromType(contentBlock.type)"
                :contentBlock="contentBlock"
                @delete="refresh" />
        </template>

        <button @click="showCreateContentBlockModal = true" class="px-4 py-2 border rounded-lg text-sm">Create Content Block</button>
    </div>

    <!-- Create Content Block Modal -->
    <Teleport to="body">
        <Modal :show="showCreateContentBlockModal">
            <template #header>
                Create Content Block
            </template>
            <template #body>
                <p class="text-xs text-gray-600">Select a Content Block type.</p>
                <div class="flex mt-4">
                    <!-- Static Content Block -->
                    <div @click="createStaticContentBlock" class="p-2 border rounded-lg">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25H12" />
                        </svg>
                        <p class="text-xs text-gray-600">Static Text<br>& Images</p>
                    </div>
                    <!-- Multiple Choice Question Block -->
                    <div @click="createMCQContentBlock" class="p-2 border rounded-lg ml-2">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zM3.75 12h.007v.008H3.75V12zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm-.375 5.25h.007v.008H3.75v-.008zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z" />
                        </svg>
                        <p class="text-xs text-gray-600">Multiple-Choice<br>Question</p>
                    </div>
                </div>
            </template>
            <template #footer>
                <div class="flex w-full justify-between">
                    <button @click="showCreateContentBlockModal = false"
                        class="px-4 py-2 border rounded-lg border-blue">Cancel</button>
                </div>
            </template>
        </Modal>
    </Teleport>
    <!-- End Create Content Block -->

</template>

<script setup>
// We need to import the components given the use of "is"
import ContentBlockStatic from '@/components/contentBlock/Static.vue'
import ContentBlockMCQ from '@/components/contentBlock/MCQ.vue'
import { ref } from 'vue';
import { debounce } from 'lodash';


const config = useRuntimeConfig();
const props = defineProps(['section']);
const emit = defineEmits(['delete']);

const section = ref(props.section);
const updating = ref(false);
const showCreateContentBlockModal = ref(false);
const { data: contentBlocks, pending, refresh } = 
    await useFetch(`${config.public.baseURL}/api/section/${section.value.id}/content_blocks`, 
        {server: false, initialCache: false, key: section.value.id});

console.log(`section id: ${section.value.id}`);

function getComponentFromType(type) {
    switch (type) {
        case "static": 
            return ContentBlockStatic;
        case "mcq":
            return ContentBlockMCQ;
    }
}

function createMCQContentBlock() {
    createContentBlock("mcq");
}

function createStaticContentBlock() {
    createContentBlock("static");
}

function createContentBlock(type) {
    showCreateContentBlockModal.value = false;
    $fetch(`${config.public.baseURL}/api/content_block`, {
        method: 'POST',
        body: { section_id: section.value.id, type }
    }).then(response => {
        contentBlocks.value.push(response);
    })
}

function deleteSection() {
    $fetch(`${config.public.baseURL}/api/section/${section.value.id}`, {
        method: 'DELETE'
    }).then(response => {
        emit('delete');
    })
}

// Saves the section on title input
const handleInput = debounce(() => {
    console.log(section.value);
    $fetch(`${config.public.baseURL}/api/section/`, {
        method: 'PUT',
        body: { section: section.value }
    }).then(response => {
        console.log(`successfully updated ${section.value.id}`);
    })
}, 500)
</script>
