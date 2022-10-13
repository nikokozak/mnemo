<template>
<div class="border rounded-lg mt-2 mb-4 pt-4">

    <!-- Inner Block Content -->

    <template v-for="brick in contentBlock.static_content">
        <div v-if="brick.type == 'text'" class="ml-5 mr-4 mb-4">
            <p class="text-sm">{{ brick.content }}</p>
        </div>
        <div v-else>
            <div 
                class="block w-4/5 h-20 border border-dashed rounded-lg ml-5 mr-4 mb-4">
            </div>
        </div>
    </template>

    <!-- End Inner Block Content -->

    <!-- Block Controls -->
    <div class="flex text-xs border-t mt-4 py-2 justify-center"> 
        <div class="flex">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 5.25l-7.5 7.5-7.5-7.5m15 6l-7.5 7.5-7.5-7.5" />
            </svg>
            Continue
        </div>
    </div>
    <!-- End Block Controls -->
</div>
</template>

<script setup>
import { ref } from 'vue';
const emit = defineEmits(['continue']);

const props = defineProps(['contentBlock']);
const contentBlock = ref(props.contentBlock);

function addImage() {
    contentBlock.value.static_content.push({
        type: "image",
        content: "",
    })
}

function addText() {
    contentBlock.value.static_content.push({
        type: "text",
        content: "",
    })
}
</script>
