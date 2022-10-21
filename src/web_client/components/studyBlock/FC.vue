<template>
<div class="border rounded-lg mt-2 mb-4">

    <!-- Front Content -->
    <div class="p-4">
        <h2>Front</h2>

        <template v-for="brick in block.fc_front_content">
            <div v-if="brick.type == 'text'" class="ml-5 mr-4 mb-4">
                <p>{{brick.content}}</p>
            </div>
            <div v-else>
                <div 
                    class="block w-4/5 h-20 border border-dashed rounded-lg ml-5 mr-4 mb-4">
                </div>
            </div>
        </template>
    </div>
    <!-- End Front Content -->


    <!-- Back Content -->
    <template v-if="showBack">
        <div class="p-4">
            <h2>Back</h2>

            <template v-for="brick in block.fc_back_content">
                <div v-if="brick.type == 'text'" class="ml-5 mr-4 mb-4">
                    <p>{{brick.content}}</p>
                </div>
                <div v-else>
                    <div 
                        class="block w-4/5 h-20 border border-dashed rounded-lg ml-5 mr-4 mb-4">
                    </div>
                </div>
            </template>
        </div>
    </template>

    <!-- End Back Content -->

    <!-- Block Controls -->
    <div class="flex text-xs border-t mt-4 py-2 justify-center"> 
        <div v-if="!showBack" @click="showBack = true" class="flex">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 5.25l-7.5 7.5-7.5-7.5m15 6l-7.5 7.5-7.5-7.5" />
            </svg>
            Reveal Back of Card
        </div>
        <div v-else @click="testBlock" class="flex">
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

const emit = defineEmits(['consume']);

const props = defineProps(['block']);
const block = ref(props.block);

const showBack = ref(false);

const { testBlock } = useStudyBlockHelpers(block, emit);
</script>
